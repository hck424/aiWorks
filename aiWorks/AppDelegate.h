//
//  AppDelegate.h
//  aiWorks
//
//  Created by 김학철 on 2020/02/29.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Utility.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UIView *loadingView;
+ (instancetype)instance;
- (void)startIndicator;
- (void)stopIndicator;
- (BOOL)isUpdateAvailable;
- (void)callMainViewController;
- (void)callIntroViewcontroller;
- (void)showUpdateAlertView;
- (void)openStoreProductViewControllerWithITunesItemIdentifier;
- (void)openUrl:(NSString *)url;
@end

