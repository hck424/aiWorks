//
//  WkWebViewController.h
//  aiWorks
//
//  Created by 김학철 on 2020/03/04.
//  Copyright © 2020 김학철. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WkWebViewController : UIViewController
@property (strong, nonatomic) WKWebView *wkWebView;

@end

NS_ASSUME_NONNULL_END
