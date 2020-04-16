//
//  ChartboostRouter.h
//  MoPubSDK
//
//  Copyright (c) 2015 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MoPub.h"
#endif

#if __has_include(<Chartboost/Chartboost+Mediation.h>)
    #import <Chartboost/Chartboost+Mediation.h>
#else
    #import "Chartboost+Mediation.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface ChartboostRouter : NSObject
+ (CHBMediation *)mediation;
+ (void)setLoggingLevel:(MPBLogLevel)loggingLevel;
+ (void)setDataUseConsentWithMopubConfiguration;
+ (void)startWithParameters:(NSDictionary *)parameters completion:(void(^)(BOOL))completion;
@end

NS_ASSUME_NONNULL_END
