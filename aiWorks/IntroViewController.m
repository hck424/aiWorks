//
//  IntroViewController.m
//  aiWorks
//
//  Created by 김학철 on 2020/03/05.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "IntroViewController.h"
#import "AppDelegate.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[AppDelegate instance] isUpdateAvailable]) {
        [[AppDelegate instance] showUpdateAlertView];
    }
    else {
        [[AppDelegate instance] callMainViewController];
    }
}

@end
