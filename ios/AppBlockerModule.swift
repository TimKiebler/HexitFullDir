//
//  AppBlockerModule.swift
//  HexitFresh
//
//  Native module that bridges lock/unlock actions and permission helpers for React Native callers.
//

import FamilyControls
import Foundation
import React

@objc(AppBlockerModule)
final class AppBlockerModule: NSObject {
  @objc
  static func requiresMainQueueSetup() -> Bool {
    true
  }

  @objc
  func lockApps(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      EmbeddedAppBlockerModel.shared.lockApps()
      resolve(nil)
    }
  }

  @objc
  func unlockApps(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      EmbeddedAppBlockerModel.shared.unlockApps()
      resolve(nil)
    }
  }

  @objc
  func requestScreenTimePermission(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      do {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        resolve(self.authorizationStatusString(AuthorizationCenter.shared.authorizationStatus))
      } catch {
        reject(
          "request_failed",
          "Failed to request Screen Time permission.",
          error
        )
      }
    }
  }

  @objc
  func getScreenTimeAuthorizationStatus(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
    Task { @MainActor in
      resolve(self.authorizationStatusString(AuthorizationCenter.shared.authorizationStatus))
    }
  }

  private func authorizationStatusString(_ status: AuthorizationStatus) -> String {
    switch status {
    case .notDetermined:
      return "notDetermined"
    case .denied:
      return "denied"
    case .approved:
      return "approved"
    @unknown default:
      return "unknown"
    }
  }
}
