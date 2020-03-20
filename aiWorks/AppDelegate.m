//
//  AppDelegate.m
//  aiWorks
//
//  Created by 김학철 on 2020/02/29.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "AppDelegate.h"
#import "IntroViewController.h"
#import "SysInfo.h"
#import <StoreKit/StoreKit.h>
#import "KafkaRefresh.h"
@import Firebase;

@interface AppDelegate () <SKStoreProductViewControllerDelegate>

@end

@implementation AppDelegate

+ (instancetype)instance {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[KafkaRefreshDefaults standardRefreshDefaults] setHeadDefaultStyle:KafkaRefreshStyleAnimatableRing];
    [FIRApp configure];
    
    if (@available(ios 13.0, *)) {
    }
    else {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [self callIntroViewcontroller];
    }
    return YES;
}

- (BOOL)isUpdateAvailable {
    
    NSString *bundleId = [SysInfo getBundleIdentifier];
    
    NSString *url = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?bundleId=%@", bundleId];
    NSError *error;
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingMappedIfSafe error:&error];
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSArray *result = [jsonDic objectForKey:@"results"];
    
    if (result.count > 0) {
        NSDictionary *itemDic = [result firstObject];
        NSString *newVersion = [itemDic objectForKey:@"version"];
        BOOL isUpdate = [SysInfo isUpdatable:newVersion];
        return isUpdate;
    }
    
    return NO;
}

- (void)showUpdateAlertView {
    UIViewController *viewController = [AppDelegate instance].window.rootViewController;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"업데이트 안내" message:@"새로운 버전이 업데이트 해주시기 바립니다."  preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"앱스토어로 이동" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openStoreProductViewControllerWithITunesItemIdentifier];
        [alert dismissViewControllerAnimated:NO completion:nil];
    }]];
    [viewController presentViewController:alert animated:NO completion:nil];
}

- (void)openStoreProductViewControllerWithITunesItemIdentifier {
    NSString *iTunesItemIdentifier = @"1502943729";
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    storeViewController.delegate = self;
    
    NSNumber *identifier = [NSNumber numberWithInteger:[iTunesItemIdentifier integerValue]];
    
    NSDictionary *parameters = @{ SKStoreProductParameterITunesItemIdentifier:identifier };
    UIViewController *viewController = [AppDelegate instance].window.rootViewController;
    [storeViewController loadProductWithParameters:parameters
                                   completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            [viewController presentViewController:storeViewController
                                         animated:YES
                                       completion:nil];
        }
        else {
            NSLog(@"SKStoreProductViewController: %@", error);
        }
    }];
}

- (void)callIntroViewcontroller {
    IntroViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"IntroViewController"];
    
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
}

- (void)callMainViewController {
    self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WkWebViewController"];
    [self.window makeKeyAndVisible];
}

#pragma mark - SKStoreProductViewControllerDelegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"== applicationWillEnterForeground");
    if (@available(ios 13.0, *)) {
    }
    else {
        if ([self isUpdateAvailable]) {
            [self showUpdateAlertView];
        }
    }
}

- (void)startIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loadingView == nil) {
            self.loadingView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        }
        
        [self.window addSubview:self.loadingView];
        [self.loadingView startAnimationWithRaduis:25];
    });
}
- (void)stopIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loadingView) {
            [self.loadingView stopAnimation];
        }
        [self.loadingView removeFromSuperview];
    });
}
- (void)openUrl:(NSString *)urlStr {
    NSString *encodingUrl = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:encodingUrl];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}

#pragma mark - UISceneSession lifecycle
- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    if (@available(iOS 13.0, *)) {
        return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    } else {
        return nil;
    }
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

@end
