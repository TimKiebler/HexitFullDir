#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(FamilyControlsModule, NSObject)
RCT_EXTERN_METHOD(requestAuthorization:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
@end
