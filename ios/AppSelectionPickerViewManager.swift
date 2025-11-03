//
//  AppSelectionPickerViewManager.swift
//  HexitFresh
//
//  RCTViewManager exposing the FamilyActivityPicker to React Native.
//

import Foundation
import React

@objc(AppSelectionPickerViewManager)
final class AppSelectionPickerViewManager: RCTViewManager {
  override static func requiresMainQueueSetup() -> Bool {
    true
  }

  override func view() -> UIView! {
    AppSelectionPickerHostingView()
  }
}
