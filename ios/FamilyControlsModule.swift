import Foundation
import FamilyControls
import React

@objc(FamilyControlsModule)
class FamilyControlsModule: NSObject {

  @objc(requestAuthorization:rejecter:)
  func requestAuthorization(_ resolve: @escaping RCTPromiseResolveBlock,
                            rejecter reject: @escaping RCTPromiseRejectBlock) {

    AuthorizationCenter.shared.requestAuthorization { result in
      switch result {
      case .success:
        resolve(true)
      case .failure(let error):
        reject("E_FAMILY_CONTROLS_AUTH", error.localizedDescription, error)
      }
    }
  }

  @objc
  static func requiresMainQueueSetup() -> Bool { false }
}
