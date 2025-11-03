//
//  AppBlockerModule.swift
//  HexitFresh
//
//  Native module that bridges lock/unlock actions for React Native callers.
//

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
}
