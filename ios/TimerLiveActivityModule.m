// TimerLiveActivityModule.m
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(TimerLiveActivityModule, NSObject)

RCT_EXTERN_METHOD(start:(NSString *)title
                  durationSeconds:(nonnull NSNumber *)durationSeconds)

RCT_EXTERN_METHOD(stop)

@end
