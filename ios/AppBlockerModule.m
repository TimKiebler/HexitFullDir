//
//  AppBlockerModule.m
//  HexitFresh
//
//  Objective-C shim that exports the Swift native module to React Native.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(AppBlockerModule, NSObject)

RCT_EXTERN_METHOD(lockApps:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(unlockApps:(RCTPromiseResolveBlock)resolve
                    rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(requestScreenTimePermission:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getScreenTimeAuthorizationStatus:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getSelectionSummary:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)

@end
