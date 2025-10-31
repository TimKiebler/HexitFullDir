//
//  AppBlockerApp.swift
//  AppBlocker
//

import SwiftUI
import FamilyControls

@main
struct AppBlockerApp: App {
    @StateObject private var authCenter = AuthorizationCenter.shared
    @State private var onboardingCompleted = false
    @State private var permissionsGranted = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authCenter.authorizationStatus == .approved && onboardingCompleted {
                    ContentView()
                } else {
                    PermissionsView(
                        authCenter: authCenter,
                        onboardingCompleted: $onboardingCompleted,
                        permissionsGranted: $permissionsGranted
                    )
                }
            }
            .onAppear {
                // Check initial authorization status
                if authCenter.authorizationStatus == .approved {
                    onboardingCompleted = true
                    permissionsGranted = true
                }
            }
        }
    }
}
