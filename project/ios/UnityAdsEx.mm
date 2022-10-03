/*
 *
 * Created by Robin Schaafsma
 * https:/\/byrobingames.github.io
 *
 */
#include <hx/CFFI.h>
#include <UnityAdsEx.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UnityAds/UnityAds.h>
#import <UnityAds/UADSMetaData.h>


using namespace unityads;

extern "C" void sendUnityAdsEvent(const char* event);

@interface UnityAdsController : NSObject <UnityAdsInitializationDelegate, UnityAdsLoadDelegate, UnityAdsShowDelegate, UADSBannerViewDelegate>
{
    UIViewController *root;
    UADSBannerView *bannerView;
    NSLayoutConstraint *bannerHorizontalConstraint;
    NSLayoutConstraint *bannerVerticalConstraint;

    BOOL initialized;
    BOOL showedVideo;
    BOOL showedRewarded;
    BOOL bottom;
    BOOL bannerLoaded;
    
    //UADSMetaData *gdprConsentMetaData;
}

- (id)initWithID:(NSString*)appID testModeOn:(BOOL)testMode debugModeOn:(BOOL)debugMode;
- (void)showVideoAdWithPlacementID:(NSString*)videoPlacementId;
- (void)showRewardedAdWithPlacementID:(NSString*)videoPlacementId andTitle:(NSString*)title withMsg:(NSString*)msg;
- (BOOL)canShowUnityAds:(NSString*)placementId;
- (BOOL)isSupportedUnityAds;
- (void)showBannerAdWithPlacementID:(NSString*)bannerPlacentId;
- (void)hideBannerAd;
- (void)setBannerPosition:(NSString*)position;
//- (void)setUsersConsent:(BOOL)isGranted;

@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, assign) BOOL showedVideo;
@property (nonatomic, assign) BOOL showedRewarded;
@property (nonatomic, assign) BOOL bottom;
@property (nonatomic, assign) BOOL bannerLoaded;

@end

@implementation UnityAdsController

@synthesize initialized;
@synthesize showedVideo;
@synthesize showedRewarded;
@synthesize bottom;
@synthesize bannerLoaded;

- (id)initWithID:(NSString*)ID testModeOn:(BOOL)testMode debugModeOn:(BOOL)debugMode
{
    self = [super init];
    NSLog(@"UnityAds Init");
    if(!self) return nil;
    
    [UnityAds setDebugMode:debugMode];
    [UnityAds initialize:ID testMode:testMode initializationDelegate:self];

    return self;
}


- (void)showVideoAdWithPlacementID:(NSString*)videoPlacementId
{
    if (!initialized)
    {
        NSLog(@"UnityAds isn't initialized yet");
        return;
    }

    showedVideo = YES;
    showedRewarded = NO;
    
    [UnityAds load:videoPlacementId loadDelegate:self];    
}


- (void)showRewardedAdWithPlacementID:(NSString*)rewardPlacementId andTitle:(NSString*)title withMsg:(NSString*)msg
{
    if (!initialized)
    {
        NSLog(@"UnityAds isn't initialized yet");
        return;
    }

    showedVideo = NO;
    showedRewarded = YES;
    
    if ([title length] >0)
    {
        UIAlertController* alert=   [UIAlertController
                                      alertControllerWithTitle:title
                                      message:msg
                                      preferredStyle:UIAlertControllerStyleAlert];
    
        UIAlertAction* discard = [UIAlertAction
                                  actionWithTitle:@"Discard"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action)
                                  {
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                      //nothing to do..
                                  }];
    
        UIAlertAction* view =   [UIAlertAction
                                 actionWithTitle:@"Watch"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                               
                                     NSLog(@"UnityAds show start ");
                                     [UnityAds load:rewardPlacementId loadDelegate:self];
                                 }];
    
        [alert addAction:discard];
        [alert addAction:view];
    
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
    }else{
    
        NSLog(@"UnityAds show start ");
        [UnityAds load:rewardPlacementId loadDelegate:self];
    }
}

- (BOOL)canShowUnityAds:(NSString*)placementId
{
    return initialized;
}

- (BOOL)isSupportedUnityAds
{
    return [UnityAds isSupported];
}

-(void)showBannerAdWithPlacementID:(NSString*)bannerPlacentId
{
    if (!initialized)
    {
        NSLog(@"UnityAds isn't initialized yet");
        return;
    }

    if(!bannerLoaded){
        if(bannerView){
            bannerView.delegate = nil;
        }
        bannerView = [[UADSBannerView alloc] initWithPlacementId: bannerPlacentId size: CGSizeMake(320, 50)];
        bannerView.delegate = self;
        bannerView.translatesAutoresizingMaskIntoConstraints = NO;
        [bannerView load];
    }
}

-(void)hideBannerAd
{
    if (!initialized)
    {
        NSLog(@"UnityAds isn't initialized yet");
        return;
    }

    if(bannerLoaded){
        [bannerView removeFromSuperview];
        bannerView = nil;
        
        bannerLoaded = NO;
        sendUnityAdsEvent("bannerdidhide");
    }
}

-(void)setBannerPosition:(NSString*)position
{
    if (!initialized)
    {
        NSLog(@"UnityAds isn't initialized yet");
        return;
    }

    if(!root) return;
    if(!bannerLoaded) return;
    
    bottom=[position isEqualToString:@"BOTTOM"];
    
    if (bottom) // Reposition the adView to the bottom of the screen
    {
        if (@available(ios 11.0, *)) {
            [self positionBannerViewAtBottomOfSafeArea];
        } else {
            [self positionBannerViewAtBottomOfView];
        }
    }else // Reposition the adView to the top of the screen
    {
        if (@available(ios 11.0, *)) {
            [self positionBannerViewAtTopOfSafeArea];
        } else {
            [self positionBannerViewAtTopOfView];
        }
    }
}

-(void)positionBannerViewAtTopOfSafeArea NS_AVAILABLE_IOS(11.0)
{
    // Position the banner. Stick it to the top of the Safe Area.
    // Centered horizontally.
    UILayoutGuide *guide = root.view.safeAreaLayoutGuide;
    if(bannerHorizontalConstraint && bannerVerticalConstraint)
    {
        [NSLayoutConstraint deactivateConstraints:@[bannerHorizontalConstraint,bannerVerticalConstraint]];
    }
    bannerHorizontalConstraint=[bannerView.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor];
    bannerVerticalConstraint=[bannerView.topAnchor constraintEqualToAnchor:guide.topAnchor];
    [NSLayoutConstraint activateConstraints:@[bannerHorizontalConstraint,bannerVerticalConstraint]];
}

-(void)positionBannerViewAtBottomOfSafeArea NS_AVAILABLE_IOS(11.0)
{
    // Position the banner. Stick it to the bottom of the Safe Area.
    // Centered horizontally.
    UILayoutGuide *guide = root.view.safeAreaLayoutGuide;
    if(bannerHorizontalConstraint && bannerVerticalConstraint)
    {
        [NSLayoutConstraint deactivateConstraints:@[bannerHorizontalConstraint,bannerVerticalConstraint]];
    }
    bannerHorizontalConstraint=[bannerView.centerXAnchor constraintEqualToAnchor:guide.centerXAnchor];
    bannerVerticalConstraint=[bannerView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor];
    [NSLayoutConstraint activateConstraints:@[bannerHorizontalConstraint,bannerVerticalConstraint]];
}

-(void)positionBannerViewAtTopOfView
{
    if(bannerHorizontalConstraint && bannerVerticalConstraint)
    {
        [root.view removeConstraints:@[bannerHorizontalConstraint,bannerVerticalConstraint]];
    }
    bannerHorizontalConstraint=[NSLayoutConstraint constraintWithItem:bannerView
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:root.view
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1
                                                             constant:0];
    bannerVerticalConstraint=[NSLayoutConstraint constraintWithItem:bannerView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:root.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1
                                                           constant:0];
    [root.view addConstraints:@[bannerHorizontalConstraint,bannerVerticalConstraint]];
}

-(void)positionBannerViewAtBottomOfView
{
    if(bannerHorizontalConstraint && bannerVerticalConstraint)
    {
        [root.view removeConstraints:@[bannerHorizontalConstraint,bannerVerticalConstraint]];
    }
    bannerHorizontalConstraint=[NSLayoutConstraint constraintWithItem:bannerView
                                                            attribute:NSLayoutAttributeCenterX
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:root.view
                                                            attribute:NSLayoutAttributeCenterX
                                                           multiplier:1
                                                             constant:0];
    bannerVerticalConstraint=[NSLayoutConstraint constraintWithItem:bannerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:root.bottomLayoutGuide
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1
                                                           constant:0];
    [root.view addConstraints:@[bannerHorizontalConstraint,bannerVerticalConstraint]];
}
    
/*-(void)setUsersConsent:(BOOL)isGranted
{
    if(gdprConsentMetaData == NULL)
    {
        gdprConsentMetaData = [[UADSMetaData alloc] init];
    }
    
    if([gdprConsentMetaData hasData])
    {
        [gdprConsentMetaData clearData];
    }
    
    NSLog(@"UnityAds SetConsent:  %@", @(isGranted));
    
    [gdprConsentMetaData set:@"gdpr.consent" value:@(isGranted)];
    [gdprConsentMetaData commit];
}*/

#pragma mark - UnityAdsInitializationDelegate

- (void)initializationComplete {
    initialized = YES;
}

- (void)initializationFailed: (UnityAdsInitializationError)error withMessage: (NSString *)message {
    NSLog(@"UnityAds ERROR: %ld - %@",(long)error, message);
}

#pragma mark - UnityAdsLoadDelegate

- (void)unityAdsAdLoaded:(NSString *)placementId {
    NSLog(@"unityAdsReady");
    if (showedVideo) {
        sendUnityAdsEvent("videodidfetch");
    }else if (showedRewarded){
        sendUnityAdsEvent("rewardeddidfetch");
    }
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    [UnityAds show:window.rootViewController placementId:placementId showDelegate:self];
}

- (void)unityAdsAdFailedToLoad:(NSString *)placementId withError:(UnityAdsLoadError)error withMessage:(NSString *)message {
    NSLog(@"UnityAds ERROR: %ld - %@",(long)error, message);
    if (showedVideo) {
        sendUnityAdsEvent("videofailedtofetch");
    }else if (showedRewarded){
        sendUnityAdsEvent("rewardedfailedtofetch");
    }
}

#pragma mark - UnityAdsShowDelegate

- (void)unityAdsShowStart:(NSString *)placementId {
    NSLog(@"unityAdsDidShow");
    if (showedVideo) {
        sendUnityAdsEvent("videodidshow");
    }else if (showedRewarded){
        sendUnityAdsEvent("rewardeddidshow");
    }
}

- (void)unityAdsShowComplete:(NSString *)placementId withFinishState:(UnityAdsShowCompletionState)state {
    
    NSLog(@"unityAdsDidHide");
    /*if (showedVideo) {
        sendUnityAdsEvent("videoclosed");
    }else if (showedRewarded){
        sendUnityAdsEvent("rewardedclosed");
    }*/
    
    switch (state) {
        case kUnityShowCompletionStateSkipped:
            //stateString = @"SKIPPED";
            if (showedVideo) {
                sendUnityAdsEvent("videoisskipped");
            }else if (showedRewarded){
                sendUnityAdsEvent("rewardedisskipped");
            }
            break;
        case kUnityShowCompletionStateCompleted:
            //stateString = @"COMPLETED";
            if (showedVideo) {
                sendUnityAdsEvent("videocompleted");
            }else if (showedRewarded){
                sendUnityAdsEvent("rewardedcompleted");
            }
            break;
        default:
            break;
    }
}

- (void)unityAdsShowFailed: (NSString *)placementId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
    NSLog(@"UnityAds ERROR: %ld - %@",(long)error, message);
    if (showedVideo) {
        sendUnityAdsEvent("videofailedtoshow");
    }else if (showedRewarded){
        sendUnityAdsEvent("rewardedfailedtoshow");
    }
}

- (void)unityAdsShowClick: (NSString *)placementId {
    if (showedVideo) {
        sendUnityAdsEvent("videodidclick");
    }else if (showedRewarded){
        sendUnityAdsEvent("rewardeddidclick");
    }
}

#pragma mark - UADSBannerViewDelegate

-(void)bannerViewDidClick:(UADSBannerView *)bannerView {
    sendUnityAdsEvent("bannerdidclick");
}

-(void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)error {
    NSLog(@"UnityAdsBannerDidError: %@", [error localizedDescription]);
    bannerLoaded = NO;
    sendUnityAdsEvent("bannerdiderror");
}

-(void)bannerViewDidLoad:(UADSBannerView *)bannerView {
    
    root = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [root.view addSubview:bannerView];

    bannerLoaded = YES;
    [self setBannerPosition:@"TOP"];

    sendUnityAdsEvent("bannerdidshow");
}

@end

namespace unityads {
	
	static UnityAdsController *unityAdsController;
    UADSMetaData *gdprConsentMetaData;
    
	void init(const char *__appID, bool testMode, bool debugMode){
        
        if(unityAdsController == NULL)
        {
            unityAdsController = [[UnityAdsController alloc] init];
        }
        
        NSString *appID = [NSString stringWithUTF8String:__appID];

        [unityAdsController initWithID:appID testModeOn:(BOOL)testMode debugModeOn:(BOOL)debugMode];
    }
    
    void showVideo(const char *__videoPlacementId)
    {
        NSString *videoPlacementId = [NSString stringWithUTF8String:__videoPlacementId];
        
        if(unityAdsController != NULL) [unityAdsController showVideoAdWithPlacementID:videoPlacementId];
    }
    
    void showRewarded(const char *__rewardPlacementId,const char *__title,const char *__msg)
    {
        NSString *rewardPlacementId = [NSString stringWithUTF8String:__rewardPlacementId];
        NSString *title = [NSString stringWithUTF8String:__title];
        NSString *msg = [NSString stringWithUTF8String:__msg];
        
        if(unityAdsController != NULL) [unityAdsController showRewardedAdWithPlacementID:rewardPlacementId andTitle:title withMsg:msg];
    }
    
    bool unityCanShow(const char *__placementId)
    {
         NSString *placementId = [NSString stringWithUTF8String:__placementId];
        
        if(unityAdsController == NULL) return false;
        
        return [unityAdsController canShowUnityAds:placementId];
    }
    
    bool unityIsSupported()
    {
        if(unityAdsController == NULL) return false;
        
        return [unityAdsController isSupportedUnityAds];
    }
    
    void showBanner(const char *__bannerPlacementId)
    {
        NSString *bannerPlacementId = [NSString stringWithUTF8String:__bannerPlacementId];
        
        if(unityAdsController != NULL) [unityAdsController showBannerAdWithPlacementID:bannerPlacementId];
    }
    
    void hideBanner()
    {
        if(unityAdsController != NULL) [unityAdsController hideBannerAd];
    }
    
    void moveBanner(const char *__position)
    {
        NSString *position = [NSString stringWithUTF8String:__position];
        
        if(unityAdsController != NULL) [unityAdsController setBannerPosition:position];
    }
    
    void setUnityConsent(bool isGranted)
    {
        if(gdprConsentMetaData == NULL)
        {
            gdprConsentMetaData = [[UADSMetaData alloc] init];
        }
        
        if([gdprConsentMetaData hasData])
        {
            [gdprConsentMetaData clearData];
        }
        
        [gdprConsentMetaData set:@"gdpr.consent" value:@(isGranted)];
        [gdprConsentMetaData commit];
        
        [[NSUserDefaults standardUserDefaults] setBool:isGranted forKey:@"gdpr_consent_unityads"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"UnityAds SetConsent:  %@", @(isGranted));
    }
    
    bool getUnityConsent()
    {
        return [[NSUserDefaults standardUserDefaults] boolForKey:@"gdpr_consent_unityads"];
    }
    
}
