//
//  IronSourceUtils.h
//
#import <Foundation/Foundation.h>
#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPInterstitialCustomEvent.h"
#endif

@interface IronSourceUtils : NSObject

+ (BOOL)isEmpty:(id)value;
+ (NSError *)createErrorWith:(NSString *)description
                   andReason:(NSString *)reason
               andSuggestion:(NSString *)suggestion;
+ (NSString *)getMoPubSdkVersion;

@end

