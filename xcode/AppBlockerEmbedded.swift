//
//  AppBlockerEmbedded.swift
//  HexitFresh
//
//  Native SwiftUI surface that handles permission onboarding and lets the user
//  choose which apps to shield. Locking now persists until the user manually
//  unlocks again—no timers or scheduled relocks involved.
//

import FamilyControls
import ManagedSettings
import SwiftUI
import UIKit

// MARK: - Root entry point presented inside the React Native bridge.

struct AppBlockerRootView: View {
  @StateObject private var authCenter = AuthorizationCenter.shared
  @State private var onboardingCompleted = false
  @State private var permissionsGranted = false

  var body: some View {
    Group {
      if authCenter.authorizationStatus == .approved && onboardingCompleted {
        AppBlockerControlView()
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

// MARK: - Main control surface: status, picker, and lock/unlock actions.

private struct AppBlockerControlView: View {
  @StateObject private var model = EmbeddedAppBlockerModel.shared
  @State private var isPickerPresented = false
  @State private var isLocked = EmbeddedAppBlockerModel.shared.isBlocking

  private var selectionCount: Int {
    model.selectionToDiscourage.applicationTokens.count
      + model.selectionToDiscourage.categoryTokens.count
      + model.selectionToDiscourage.webDomainTokens.count
  }

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          statusCard

          Button {
            isPickerPresented = true
          } label: {
            HStack(spacing: 12) {
              Text("📱")
                .font(.title2)
              VStack(alignment: .leading, spacing: 4) {
                Text(selectionCount > 0 ? "Edit Blocked Apps" : "Choose Apps to Block")
                  .font(.headline)
                Text("Pick apps, categories or websites to hide whenever locking is active.")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }
              Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue)
            )
          }
          .buttonStyle(.plain)

          Button(action: toggleLock) {
            HStack(spacing: 12) {
              Text(isLocked ? "🔓" : "🔒")
                .font(.title2)

              VStack(alignment: .leading, spacing: 4) {
                Text(isLocked ? "Unlock Apps" : "Lock Apps")
                  .font(.headline)
                Text(isLocked ? "All restrictions stay off until you lock them again."
                              : "Restrictions stay active until you manually unlock.")
                  .font(.subheadline)
                  .foregroundColor(.secondary)
              }

              Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
              RoundedRectangle(cornerRadius: 16)
                .fill(isLocked ? Color.orange : Color.red)
            )
          }
          .buttonStyle(.plain)
        }
        .padding(20)
      }
      .background(Color(.systemGray6).opacity(0.3))
      .navigationTitle("App Blocker")
      .navigationBarTitleDisplayMode(.inline)
    }
    .familyActivityPicker(isPresented: $isPickerPresented, selection: $model.selectionToDiscourage)
    .onAppear(perform: refreshLockState)
  }

  private var statusCard: some View {
    VStack(spacing: 18) {
      Text(isLocked ? "🔒" : "🔓")
        .font(.system(size: 70))

      VStack(spacing: 8) {
        Text(isLocked ? "Apps Locked" : "Apps Unlocked")
          .font(.title2.bold())
          .foregroundColor(isLocked ? .red : .green)

        Text(selectionCount > 0
             ? "\(selectionCount) item(s) configured for shielding."
             : "No apps selected yet — pick some to control what gets blocked.")
          .font(.subheadline)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal, 12)
      }
    }
    .padding(28)
    .frame(maxWidth: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 22)
        .fill(Color.white)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    )
  }

  private func toggleLock() {
    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
      if isLocked {
        model.unlockApps()
      } else {
        model.lockApps()
      }
      refreshLockState()
    }
  }

  private func refreshLockState() {
    isLocked = model.isBlocking
  }
}

// MARK: - Permission onboarding

private struct AppBlockerPermissionsView: View {
  let authCenter: AuthorizationCenter
  @Binding var onboardingCompleted: Bool
  @Binding var permissionsGranted: Bool

  @State private var isLoading = false
  @State private var showError = false
  @State private var animateShield = false
  @State private var animateCards = false

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

          Text("Grant Screen Time access so we can hide distracting apps whenever you press the lock button.")
            .font(.body)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .opacity(animateShield ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.8).delay(0.7), value: animateShield)
        }
      }

      HStack(spacing: 16) {
        FeatureCard(
          emoji: "🔒",
          title: "Manual Control",
          description: "Lock or unlock whenever you need—no timers involved."
        )

        FeatureCard(
          emoji: "📱",
          title: "Custom Lists",
          description: "Pick apps, categories, and websites to shield."
        )
      }
      .opacity(animateCards ? 1.0 : 0.0)
      .animation(.easeInOut(duration: 0.8).delay(0.9), value: animateCards)

      Spacer()

      VStack(spacing: 16) {
        Button(action: requestPermissions) {
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
              .fill(isLoading ? Color.gray : Color.blue)
          )
        }
        .disabled(isLoading)
        .buttonStyle(.plain)
        .scaleEffect(animateCards ? 1.0 : 0.94)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(1.1), value: animateCards)

        Text("We never read your personal Screen Time data—only the ability to hide the items you choose.")
          .font(.footnote)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .opacity(animateCards ? 0.85 : 0.0)
          .animation(.easeInOut(duration: 0.6).delay(1.3), value: animateCards)
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
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        animateShield = true
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
        animateCards = true
      }
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
          .fill(Color.white)
          .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
      )
    }
  }
}

// MARK: - Shared model (simple lock/unlock state + selection persistence)

@MainActor
final class EmbeddedAppBlockerModel: ObservableObject {
  static let shared = EmbeddedAppBlockerModel()

  let store = ManagedSettingsStore()

  @Published var selectionToDiscourage: FamilyActivitySelection
  @AppStorage("categoryTokensData", store: UserDefaults(suiteName: "group.HexitFresh")) private var categoryTokensData: Data?
  @AppStorage("applicationTokensData", store: UserDefaults(suiteName: "group.HexitFresh")) private var applicationTokensData: Data?
  @AppStorage("webDomainTokensData", store: UserDefaults(suiteName: "group.HexitFresh")) private var webDomainTokensData: Data?
  @AppStorage("appBlockerIsLocked", store: UserDefaults(suiteName: "group.HexitFresh")) private var isLockedFlag: Bool = false

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

  var isBlocking: Bool {
    isLockedFlag
  }

  func lockApps() {
    setShieldRestrictions()
    isLockedFlag = true
  }

  func unlockApps() {
    store.clearAllSettings()
    isLockedFlag = false
  }

  private func setShieldRestrictions() {
    applicationTokens = selectionToDiscourage.applicationTokens
    categoryTokens = selectionToDiscourage.categoryTokens
    webDomainTokens = selectionToDiscourage.webDomainTokens

    store.shield.applications = selectionToDiscourage.applicationTokens
    store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(selectionToDiscourage.categoryTokens)
    store.shield.webDomains = selectionToDiscourage.webDomainTokens
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

  private func decodeTokens<T: Decodable>(_ data: Data?) -> T? {
    guard let data else { return nil }
    return try? JSONDecoder().decode(T.self, from: data)
  }

  private func encodeTokens<T: Encodable>(_ tokens: T?) -> Data? {
    guard let tokens else { return nil }
    return try? JSONEncoder().encode(tokens)
  }
}
