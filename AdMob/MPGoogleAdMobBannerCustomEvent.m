//
//  MPGoogleAdMobBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPGoogleAdMobBannerCustomEvent.h"
#import "GoogleAdMobAdapterConfiguration.h"
#import <CoreLocation/CoreLocation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "MPGoogleAdMobBannerCustomEvent.h"
#if __has_include("MoPub.h")
#import "MPLogging.h"
#endif

@interface MPGoogleAdMobBannerCustomEvent () <GADBannerViewDelegate>

@property(nonatomic, strong) GADBannerView *adBannerView;

@end

@implementation MPGoogleAdMobBannerCustomEvent

- (id)init {
  self = [super init];
  if (self) {
    self.adBannerView = [[GADBannerView alloc] initWithFrame:CGRectZero];
    self.adBannerView.delegate = self;
  }
  return self;
}

- (void)dealloc {
  self.adBannerView.delegate = nil;
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
    [self requestAdWithSize:size customEventInfo:info adMarkup:nil];
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
  
  self.adBannerView.frame = [self frameForCustomEventInfo:size];
  self.adBannerView.adUnitID = [info objectForKey:@"adUnitID"];
  self.adBannerView.rootViewController = [self.delegate viewControllerForPresentingModalView];
    
  GADRequest *request = [GADRequest request];
  if ([self.localExtras objectForKey:@"contentUrl"] != nil) {
      NSString *contentUrl = [self.localExtras objectForKey:@"contentUrl"];
      if ([contentUrl length] != 0) {
          request.contentURL = contentUrl;
      }
  }

  CLLocation *location = self.delegate.location;
  if (location) {
    [request setLocationWithLatitude:location.coordinate.latitude
                           longitude:location.coordinate.longitude
                            accuracy:location.horizontalAccuracy];
  }

  // Here, you can specify a list of device IDs that will receive test ads.
  // Running in the simulator will automatically show test ads.
  if ([self.localExtras objectForKey:@"testDevices"]) {
    request.testDevices = self.localExtras[@"testDevices"];
  }

  if ([self.localExtras objectForKey:@"tagForChildDirectedTreatment"]) {
    [GADMobileAds.sharedInstance.requestConfiguration tagForChildDirectedTreatment:self.localExtras[@"tagForChildDirectedTreatment"]];
  }

  if ([self.localExtras objectForKey:@"tagForUnderAgeOfConsent"]) {
    [GADMobileAds.sharedInstance.requestConfiguration
     tagForUnderAgeOfConsent:self.localExtras[@"tagForUnderAgeOfConsent"]];
  }
  
  request.requestAgent = @"MoPub";

  // Consent collected from the MoPub’s consent dialogue should not be used to set up Google's
  // personalization preference. Publishers should work with Google to be GDPR-compliant.

  NSString *npaValue = GoogleAdMobAdapterConfiguration.npaString;

  if (npaValue.length > 0) {
    GADExtras *extras = [[GADExtras alloc] init];
    extras.additionalParameters = @{@"npa": npaValue};
    [request registerAdNetworkExtras:extras];
  }
    
  // Cache the network initialization parameters
  [GoogleAdMobAdapterConfiguration updateInitializationParameters:info];
  MPLogAdEvent([MPLogEvent adLoadAttemptForAdapter:NSStringFromClass(self.class) dspCreativeId:nil dspName:nil], [self getAdNetworkId]);
  [self.adBannerView loadRequest:request];
}

- (CGRect)frameForCustomEventInfo:(CGSize)size {
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    if (height >= GAD_SIZE_120x600.height && width >= GAD_SIZE_120x600.width) {
        return CGRectMake(0, 0, GAD_SIZE_120x600.width, GAD_SIZE_120x600.height);
    } else if (height >= GAD_SIZE_300x250.height && width >= GAD_SIZE_300x250.width) {
        return CGRectMake(0, 0, GAD_SIZE_300x250.width, GAD_SIZE_300x250.height);
    } else if (height >= GAD_SIZE_320x100.height && width >= GAD_SIZE_320x100.width) {
        return CGRectMake(0, 0, GAD_SIZE_320x100.width, GAD_SIZE_320x100.height);
    } else if (height >= GAD_SIZE_728x90.height && width >= GAD_SIZE_728x90.width) {
        return CGRectMake(0, 0, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height);
    } else if (height >= GAD_SIZE_468x60.height && width >= GAD_SIZE_468x60.width) {
        return CGRectMake(0, 0, GAD_SIZE_468x60.width, GAD_SIZE_468x60.height);
    } else if (height >= GAD_SIZE_320x50.height && width >= GAD_SIZE_320x50.width) {
        return CGRectMake(0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height);
    } else {
        return CGRectMake(0, 0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height);
    }
}

#pragma mark GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
  MPLogAdEvent([MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
  MPLogAdEvent([MPLogEvent adShowAttemptForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
  MPLogAdEvent([MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);
    
  [self.delegate bannerCustomEvent:self didLoadAd:self.adBannerView];
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
 
  NSString *failureReason = [NSString stringWithFormat: @"Google AdMob Banner failed to load with error: %@", error.localizedDescription];
  NSError *mopubError = [NSError errorWithCode:MOPUBErrorAdapterInvalid localizedDescription:failureReason];

  MPLogAdEvent([MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:mopubError], [self getAdNetworkId]);
  [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView {
  [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView {
  [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView {
  MPLogAdEvent([MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)], [self getAdNetworkId]);

  [self.delegate bannerCustomEventWillLeaveApplication:self];
}

- (NSString *) getAdNetworkId {
    return (self.adBannerView) ? self.adBannerView.adUnitID : @"";
}

@end
