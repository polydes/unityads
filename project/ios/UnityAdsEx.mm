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

@interface UnityAdsController : NSObject <UnityAdsDelegate, UADSBannerViewDelegate>
{
    UIViewController *viewController;
    UIViewController *root;
    UADSBannerView *bannerView;
    NSLayoutConstraint *bannerHorizontalConstraint;
    NSLayoutConstraint *bannerVerticalConstraint;

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

@property (nonatomic, assign) BOOL showedVideo;
@property (nonatomic, assign) BOOL showedRewarded;
@property (nonatomic, assign) BOOL bottom;
@property (nonatomic, assign) BOOL bannerLoaded;

@end

@implementation UnityAdsController

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
    [UnityAds addDelegate:self];
    [UnityAds initialize:ID testMode:testMode];

    return self;
}


- (void)showVideoAdWithPlacementID:(NSString*)videoPlacementId
{
    showedVideo = YES;
    showedRewarded = NO;
    
    if ([UnityAds isReady:videoPlacementId]) {
            
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        viewController = [[UIViewController alloc] init];
        [window addSubview: viewController.view];
        //[window.rootViewController presentViewController:viewController animated:YES completion:^(void)
        //{
         //   [UnityAds show:viewController placementId:videoPlacementId];
        //}];
        [UnityAds show:viewController placementId:videoPlacementId];
        
    }
    
        
}


- (void)showRewardedAdWithPlacementID:(NSString*)rewardPlacementId andTitle:(NSString*)title withMsg:(NSString*)msg
{
    showedVideo = NO;
    showedRewarded = YES;
    
    if ([UnityAds isReady:rewardPlacementId])
    {
    
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
                                         UIWindow* window = [UIApplication sharedApplication].keyWindow;
                                         viewController = [[UIViewController alloc] init];
                                         [window addSubview: viewController.view];
                                         //[window.rootViewController presentViewController:viewController animated:YES completion:^(void)
                                          //{
                                          //    [UnityAds show:viewController placementId:rewardPlacementId];
                                          //}];
                                         [UnityAds show:viewController placementId:rewardPlacementId];
                                     }];
        
            [alert addAction:discard];
            [alert addAction:view];
        
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
        }else{
        
            NSLog(@"UnityAds show start ");
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            viewController = [[UIViewController alloc] init];
            [window addSubview: viewController.view];
            //[window.rootViewController presentViewController:viewController animated:YES completion:^(void)
            //{
            //    [UnityAds show:viewController placementId:rewardPlacementId];
            //}];
            [UnityAds show:viewController placementId:rewardPlacementId];
        }
    }
}

- (BOOL)canShowUnityAds:(NSString*)placementId
{
    return [UnityAds isReady: placementId];
}

- (BOOL)isSupportedUnityAds
{
    return [UnityAds isSupported];
}

-(void)showBannerAdWithPlacementID:(NSString*)bannerPlacentId
{
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
    if(bannerLoaded){
        [bannerView removeFromSuperview];
        bannerView = nil;
        
        bannerLoaded = NO;
        sendUnityAdsEvent("bannerdidhide");
    }
}

-(void)setBannerPosition:(NSString*)position
{
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

#pragma mark - UnityAdsSDK Delegate

- (void)unityAdsReady:(NSString *)placementId {
    NSLog(@"unityAdsReady");
    sendUnityAdsEvent("adisfetch");
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    NSLog(@"UnityAds ERROR: %ld - %@",(long)error, message);
    sendUnityAdsEvent("adfailedtofetch");
}

- (void)unityAdsDidStart:(NSString *)placementId {
    NSLog(@"unityAdsDidShow");
    if (showedVideo) {
        sendUnityAdsEvent("videodidshow");
    }else if (showedRewarded){
        sendUnityAdsEvent("rewardeddidshow");
    }
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    
    [viewController dismissViewControllerAnimated:YES completion:^(void)
     {
         UIWindow *window = [UIApplication sharedApplication].keyWindow;
         [viewController.view removeFromSuperview];
         [window makeKeyAndVisible];
     }];
    
    NSLog(@"unityAdsDidHide");
    /*if (showedVideo) {
        sendUnityAdsEvent("videoclosed");
    }else if (showedRewarded){
        sendUnityAdsEvent("rewardedclosed");
    }*/
    
    switch (state) {
        case kUnityAdsFinishStateError:
            //stateString = @"ERROR";
            break;
        case kUnityAdsFinishStateSkipped:
            //stateString = @"SKIPPED";
            sendUnityAdsEvent("videoisskipped");
            break;
        case kUnityAdsFinishStateCompleted:
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
