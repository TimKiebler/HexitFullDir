//
//  PermissionsView.swift
//  AppBlocker
//

import SwiftUI
import FamilyControls

struct PermissionsView: View {
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
            
            // Header Section
            VStack(spacing: 24) {
                // Main Icon
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
            
            // Features Section
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
            
            // Permission Button
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
                    case .denied:
                        showError = true
                    case .notDetermined:
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
}

struct FeatureCard: View {
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

#Preview {
    PermissionsView(
        authCenter: AuthorizationCenter.shared,
        onboardingCompleted: .constant(false),
        permissionsGranted: .constant(false)
    )
} 
