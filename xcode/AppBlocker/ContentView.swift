//
//  ContentView.swift
//  AppBlocker
//

import SwiftUI
import FamilyControls

struct ContentView: View {
    @StateObject private var model = AppBlockerModel.shared
    @State private var isDiscouragedPresented = false
    @State private var isLocked = false
    @State private var unlockTimeRemaining: TimeInterval = 0
    @State private var timer: Timer?
    @State private var pulseAnimation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        // Main Status Card
                        VStack(spacing: 20) {
                            // Status Emoji
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
                    
                    // App Selection Card
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
                    
                    // Action Button
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
        // Check if apps are currently locked
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
        unlockTimeRemaining = 30 * 60 // 30 minutes in seconds
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if unlockTimeRemaining > 0 {
                unlockTimeRemaining -= 1
            } else {
                stopUnlockTimer()
                // Re-lock apps
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

#Preview {
    ContentView()
}
