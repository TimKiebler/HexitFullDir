//
//  AppBlockerEmbedded.swift
//  HexitFresh
//
//  This file hosts a SwiftUI reimplementation of the existing AppBlocker
//  experience so we can surface it inside React Native via a native view.
//

import Foundation
import SwiftUI
import UIKit
import FamilyControls
import ManagedSettings
import DeviceActivity

// MARK: - Root view that switches between onboarding and the main content.

struct AppBlockerRootView: View {
  @StateObject private var authCenter = AuthorizationCenter.shared
  @State private var onboardingCompleted = false
  @State private var permissionsGranted = false

  var body: some View {
    Group {
      if authCenter.authorizationStatus == .approved && onboardingCompleted {
        AppBlockerContentView()
      } else {
        AppBlockerPermissionsView(
          authCenter: authCenter,
          onboardingCompleted: $onboardingCompleted,
          permissionsGranted: $permissionsGranted
        )
      }
    }
    .onAppear {
      if authCenter.authorizationStatus == .approved {
        onboardingCompleted = true
        permissionsGranted = true
      }
    }
  }
}

// MARK: - SwiftUI views copied from the standalone AppBlocker app.

private struct AppBlockerContentView: View {
  @StateObject private var model = EmbeddedAppBlockerModel.shared
  @State private var isDiscouragedPresented = false
  @State private var isLocked = false
  @State private var unlockTimeRemaining: TimeInterval = 0
  @State private var timer: Timer?
  @State private var pulseAnimation = false

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          VStack(spacing: 16) {
            VStack(spacing: 20) {
              Text(isLocked ? "🔒" : "🔓")
                .font(.system(size: 80))
                .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(), value: pulseAnimation)

              VStack(spacing: 8) {
                Text(isLocked ? "Apps Locked" : "Apps Unlocked")
                  .font(.title2.bold())
                  .foregroundColor(isLocked ? .red : .green)

                if unlockTimeRemaining > 0 {
                  VStack(spacing: 4) {
                    Text("⏰ " + formattedTime(unlockTimeRemaining))
                      .font(.headline.monospacedDigit())
                      .foregroundColor(.orange)
                      .padding(.horizontal, 16)
                      .padding(.vertical, 8)
                      .background(
                        Capsule()
                          .fill(.orange.opacity(0.1))
                      )
                  }
                }
              }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
            )
          }

          VStack(spacing: 16) {
            HStack {
              Text("📱")
                .font(.title)

              VStack(alignment: .leading, spacing: 4) {
                Text("Selected Apps")
                  .font(.headline)

                Text("\(model.selectionToDiscourage.applicationTokens.count + model.selectionToDiscourage.categoryTokens.count) apps blocked")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }

              Spacer()

              Text("\(model.selectionToDiscourage.applicationTokens.count + model.selectionToDiscourage.categoryTokens.count)")
                .font(.title2.bold())
                .foregroundColor(.blue)
            }

            Button {
              isDiscouragedPresented = true
            } label: {
              HStack {
                Text("➕")
                  .font(.title3)
                Text("Choose Apps")
                  .font(.headline)
              }
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 16)
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(.blue)
              )
            }
            .buttonStyle(.plain)
          }
          .padding(20)
          .background(
            RoundedRectangle(cornerRadius: 20)
              .fill(.white)
              .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
          )

          Button {
            if isLocked {
              unlockApps()
            } else {
              lockApps()
            }
          } label: {
            HStack(spacing: 12) {
              Text(isLocked ? "🔓" : "🔒")
                .font(.title2)

              VStack(alignment: .leading, spacing: 4) {
                Text(isLocked ? "Unlock for 30 Minutes" : "Lock Apps Now")
                  .font(.headline)
                Text(isLocked ? "Temporary access" : "Block selected apps")
                  .font(.subheadline)
              }

              Spacer()
            }
            .foregroundColor(.white)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 20)
                .fill(isLocked ? .orange : .red)
            )
          }
          .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
      }
      .background(Color(.systemGray6).opacity(0.3))
      .navigationTitle("App Blocker")
      .navigationBarTitleDisplayMode(.inline)
    }
    .familyActivityPicker(isPresented: $isDiscouragedPresented, selection: $model.selectionToDiscourage)
    .onAppear {
      pulseAnimation = true
      checkLockStatus()
    }
  }

  private func checkLockStatus() {
    let hasActiveRestrictions = ((model.store.shield.applications?.isEmpty) == nil) ||
      ((model.store.shield.webDomains?.isEmpty) == nil)
    isLocked = hasActiveRestrictions
  }

  private func lockApps() {
    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
      model.lockApps()
      isLocked = true
      stopUnlockTimer()
    }
  }

  private func unlockApps() {
    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
      model.unlockApps()
      isLocked = false
      startUnlockTimer()
    }
  }

  private func startUnlockTimer() {
    unlockTimeRemaining = 30 * 60

    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
      if unlockTimeRemaining > 0 {
        unlockTimeRemaining -= 1
      } else {
        stopUnlockTimer()
        DispatchQueue.main.async {
          lockApps()
        }
      }
    }
  }

  private func stopUnlockTimer() {
    timer?.invalidate()
    timer = nil
    unlockTimeRemaining = 0
  }

  private func formattedTime(_ timeInterval: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    return formatter.string(from: timeInterval) ?? "00:00"
  }
}

private struct AppBlockerPermissionsView: View {
  let authCenter: AuthorizationCenter
  @Binding var onboardingCompleted: Bool
  @Binding var permissionsGranted: Bool

  @State private var isLoading = false
  @State private var showError = false
  @State private var animateShield = false
  @State private var animateApps = false

  var body: some View {
    VStack(spacing: 32) {
      Spacer()

      VStack(spacing: 24) {
        Text("🛡️")
          .font(.system(size: 100))
          .scaleEffect(animateShield ? 1.0 : 0.8)
          .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: animateShield)

        VStack(spacing: 12) {
          Text("Welcome to App Blocker")
            .font(.largeTitle.bold())
            .foregroundColor(.primary)
            .scaleEffect(animateShield ? 1.0 : 0.9)
            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.5), value: animateShield)

          Text("Take control of your digital wellness by blocking distracting apps when you need to focus.")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .opacity(animateShield ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.8).delay(0.7), value: animateShield)
        }
      }

      VStack(spacing: 16) {
        HStack(spacing: 16) {
          FeatureCard(
            emoji: "📱",
            title: "Block Apps",
            description: "Choose which apps to restrict"
          )

          FeatureCard(
            emoji: "⏰",
            title: "Timed Unlock",
            description: "30-minute temporary access"
          )
        }

        HStack(spacing: 16) {
          FeatureCard(
            emoji: "🌙",
            title: "Daily Schedule",
            description: "Automatic daily blocking"
          )

          FeatureCard(
            emoji: "🎯",
            title: "Stay Focused",
            description: "Boost your productivity"
          )
        }
      }
      .opacity(animateApps ? 1.0 : 0.0)
      .animation(.easeInOut(duration: 0.8).delay(0.9), value: animateApps)

      Spacer()

      VStack(spacing: 16) {
        Button {
          requestPermissions()
        } label: {
          HStack {
            if isLoading {
              ProgressView()
                .scaleEffect(0.8)
                .foregroundColor(.white)
            } else {
              Text("✅")
                .font(.title2)
            }

            Text(isLoading ? "Requesting Permission..." : "Grant Screen Time Permission")
              .font(.headline)
          }
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 16)
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(isLoading ? .gray : .blue)
          )
        }
        .disabled(isLoading)
        .buttonStyle(.plain)
        .scaleEffect(animateApps ? 1.0 : 0.9)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.1), value: animateApps)

        Text("App Blocker needs Screen Time permission to manage app restrictions on your device.")
          .font(.footnote)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .opacity(animateApps ? 0.8 : 0.0)
          .animation(.easeInOut(duration: 0.6).delay(1.3), value: animateApps)
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 40)
    }
    .padding(.horizontal, 20)
    .background(Color(.systemGray6).opacity(0.3))
    .alert("Screen Time Permission Required", isPresented: $showError) {
      Button("Open Settings") {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(settingsUrl)
        }
      }
      Button("Cancel", role: .cancel) { }
    } message: {
      Text("Screen Time permission is required for App Blocker to function. Please enable it in Settings.")
    }
    .onAppear {
      startAnimations()
    }
  }

  private func startAnimations() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      animateShield = true
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
      animateApps = true
    }
  }

  private func requestPermissions() {
    isLoading = true

    Task {
      do {
        try await authCenter.requestAuthorization(for: .individual)

        await MainActor.run {
          isLoading = false

          switch authCenter.authorizationStatus {
          case .approved:
            permissionsGranted = true
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
              onboardingCompleted = true
            }
          case .denied, .notDetermined:
            showError = true
          @unknown default:
            showError = true
          }
        }
      } catch {
        await MainActor.run {
          isLoading = false
          showError = true
        }
      }
    }
  }

  private struct FeatureCard: View {
    let emoji: String
    let title: String
    let description: String

    var body: some View {
      VStack(spacing: 12) {
        Text(emoji)
          .font(.system(size: 32))

        VStack(spacing: 4) {
          Text(title)
            .font(.headline)
            .fontWeight(.semibold)

          Text(description)
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
        }
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 20)
      .padding(.horizontal, 12)
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(.white)
          .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
      )
    }
  }
}

// MARK: - Shared model copied from the standalone target.

@MainActor
final class EmbeddedAppBlockerModel: ObservableObject {
  static let shared = EmbeddedAppBlockerModel()

  let store = ManagedSettingsStore()
  private let center = DeviceActivityCenter()

  @Published var selectionToDiscourage: FamilyActivitySelection
  @AppStorage("categoryTokensData", store: UserDefaults(suiteName: "group.HexitFresh")) private var categoryTokensData: Data?
  @AppStorage("applicationTokensData", store: UserDefaults(suiteName: "group.HexitFresh")) private var applicationTokensData: Data?
  @AppStorage("webDomainTokensData", store: UserDefaults(suiteName: "group.HexitFresh")) private var webDomainTokensData: Data?

  private let lockScheduleName = DeviceActivityName("lock")
  private let unlockScheduleName = DeviceActivityName("unlock")

  private init() {
    selectionToDiscourage = FamilyActivitySelection()

    if let applicationTokens = applicationTokens {
      selectionToDiscourage.applicationTokens = applicationTokens
    }

    if let categoryTokens = categoryTokens {
      selectionToDiscourage.categoryTokens = categoryTokens
    }

    if let webDomainTokens = webDomainTokens {
      selectionToDiscourage.webDomainTokens = webDomainTokens
    }
  }

  private var categoryTokens: Set<ActivityCategoryToken>? {
    get { decodeTokens(categoryTokensData) }
    set { categoryTokensData = encodeTokens(newValue) }
  }

  private var applicationTokens: Set<ApplicationToken>? {
    get { decodeTokens(applicationTokensData) }
    set { applicationTokensData = encodeTokens(newValue) }
  }

  private var webDomainTokens: Set<WebDomainToken>? {
    get { decodeTokens(webDomainTokensData) }
    set { webDomainTokensData = encodeTokens(newValue) }
  }

  func setShieldRestrictions() {
    applicationTokens = selectionToDiscourage.applicationTokens
    categoryTokens = selectionToDiscourage.categoryTokens
    webDomainTokens = selectionToDiscourage.webDomainTokens

    store.shield.applications = selectionToDiscourage.applicationTokens
    store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selectionToDiscourage.categoryTokens)
    store.shield.webDomains = selectionToDiscourage.webDomainTokens
  }

  func setShieldRestrictionsFromStorage() {
    store.shield.applications = applicationTokens
    store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(categoryTokens ?? [])
    store.shield.webDomains = webDomainTokens
  }

  func lockApps() {
    setShieldRestrictions()
    startDailyLockSchedule()
  }

  func unlockApps() {
    store.clearAllSettings()
    scheduleRelock()
  }

  func stopMonitoring() {
    center.stopMonitoring([lockScheduleName, unlockScheduleName])
    store.clearAllSettings()
  }

  private func startDailyLockSchedule() {
    let schedule = DeviceActivitySchedule(
      intervalStart: DateComponents(hour: 0, minute: 0),
      intervalEnd: DateComponents(hour: 23, minute: 59),
      repeats: true
    )

    do {
      try center.startMonitoring(lockScheduleName, during: schedule)
    } catch {
      print("Failed to start daily lock schedule: \(error)")
    }
  }

  private func scheduleRelock() {
    let now = Date()
    guard
      let relockTime = Calendar.current.date(byAdding: .minute, value: 30, to: now),
      let relockEnd = Calendar.current.date(byAdding: .minute, value: 1, to: relockTime)
    else { return }

    let startComponents = Calendar.current.dateComponents([.hour, .minute], from: relockTime)
    let endComponents = Calendar.current.dateComponents([.hour, .minute], from: relockEnd)

    let schedule = DeviceActivitySchedule(
      intervalStart: startComponents,
      intervalEnd: endComponents,
      repeats: false
    )

    do {
      try center.startMonitoring(unlockScheduleName, during: schedule)
    } catch {
      print("Failed to schedule relock: \(error)")
    }
  }

  private func decodeTokens<T: Decodable>(_ data: Data?) -> T? {
    guard let data else { return nil }
    return try? JSONDecoder().decode(T.self, from: data)
  }

  private func encodeTokens<T: Encodable>(_ tokens: T?) -> Data? {
    guard let tokens else { return nil }
    return try? JSONEncoder().encode(tokens)
  }
}
