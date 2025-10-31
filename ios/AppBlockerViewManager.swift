//
//  AppBlockerViewManager.swift
//  HexitFresh
//
//  RCTViewManager that exposes the AppBlocker SwiftUI view to React Native.
//

import Foundation
import React

@objc(AppBlockerViewManager)
final class AppBlockerViewManager: RCTViewManager {
  override static func requiresMainQueueSetup() -> Bool {
    true
  }

  override func view() -> UIView! {
    AppBlockerHostingView()
  }
}
