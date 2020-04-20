//
//  WkWebViewController.m
//  aiWorks
//
//  Created by 김학철 on 2020/03/04.
//  Copyright © 2020 김학철. All rights reserved.
//

#import "WkWebViewController.h"
#import "AppDelegate.h"
#import "SysInfo.h"
#import "KafkaRefresh.h"
#import "UIImage+Utility.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface WkWebViewController () <WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, UIScrollViewDelegate/*, UINavigationControllerDelegate, UIImagePickerControllerDelegate*/>

@property (weak, nonatomic) IBOutlet UIView *baseView;
@property (nonatomic, strong) WKWebViewConfiguration *config;
@property (nonatomic, strong) WKUserContentController *wkContentCtrl;
@property (nonatomic, strong) WKWebView *createWebView;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *width;
@property (nonatomic, strong) NSString *height;

@end

@implementation WkWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setWebView];
}

- (void)setWebView {
    NSString *url = SERVER_URL;
    
    self.config = [[WKWebViewConfiguration alloc] init];
    
    self.wkContentCtrl = [[WKUserContentController alloc] init];
    
    WKProcessPool *wkProcessPool = [[WKProcessPool alloc] init];
    WKPreferences *wkPreferences = [[WKPreferences alloc] init];
    wkPreferences.javaScriptEnabled = YES;
    wkPreferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:[self getZoomDisableScript] injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    
    [_wkContentCtrl addUserScript:wkUScript];
    
    [_wkContentCtrl addScriptMessageHandler:self name:@"callbackHandler"];

    self.config.userContentController = _wkContentCtrl;
    _config.processPool = wkProcessPool;
    _config.preferences = wkPreferences;
    _config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    _config.allowsInlineMediaPlayback = NO;
    _config.mediaTypesRequiringUserActionForPlayback = NO;
    _config.allowsPictureInPictureMediaPlayback = NO;
    //    _config.applicationNameForUserAgent = @"APP_AIWORKS_IOS";
    
    self.wkWebView = [[WKWebView alloc] initWithFrame:_baseView.bounds configuration:_config];
    [_baseView addSubview:_wkWebView];
    
    _wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _wkWebView.opaque = NO;
    _wkWebView.backgroundColor = [UIColor clearColor];
    _wkWebView.allowsBackForwardNavigationGestures = YES;
    _wkWebView.UIDelegate = self;
    _wkWebView.navigationDelegate = self;
    
    _wkWebView.scrollView.zoomScale = 1.0;
    _wkWebView.scrollView.maximumZoomScale = 1.0;
    _wkWebView.scrollView.minimumZoomScale = 1.0;
    _wkWebView.scrollView.bouncesZoom = NO;
    _wkWebView.scrollView.contentInset = UIEdgeInsetsZero;
    [_wkWebView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    _wkWebView.multipleTouchEnabled = NO;
    _wkWebView.scrollView.showsHorizontalScrollIndicator = NO;
    _wkWebView.scrollView.showsVerticalScrollIndicator = NO;
    _wkWebView.scrollView.bounces = YES;
    _wkWebView.scrollView.delegate = self;
    _wkWebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    __weak typeof (self)weakSelf = self;
    [_wkWebView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable reuslt, NSError * _Nullable error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        NSString *userAgent = reuslt;
        NSString *newUserAgent = [userAgent stringByAppendingString:@" APP_AIWORKS_IOS"];
        strongSelf.wkWebView.customUserAgent = newUserAgent;
    }];
    
    
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [_wkWebView loadRequest:req];

    
    
//    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
//    NSString *htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
//    [_wkWebView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
//
    KafkaRefreshHandler headBlock = ^(void){
        [self.wkWebView reload];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.wkWebView.scrollView.headRefreshControl endRefreshing];
        });
    };
    
    [_wkWebView.scrollView bindHeadRefreshHandler:headBlock themeColor:[UIColor whiteColor] refreshStyle:KafkaRefreshStyleReplicatorWoody];
}

#pragma mark - custom method
- (NSString *)getMessageHandler {
    NSString *js = @"function nativeAppIOS(msg) { try { webkit.messageHandlers.callbackHandler.postMessage(msg);} catch(error) { alert(error);}}";
    return js;
}
- (NSString *)getChangeElement:(NSString *)type width:(NSString *)width height:(NSString *)height {
    NSMutableString *js = [NSMutableString string];
    //    [js appendString:@"function changeElement(type, width, height) {"];
    [js appendString:@"var workFile = document.getElementById('workFile');"];
    [js appendString:@"var div = workFile.nextSibling.nextSibling;"];
    [js appendString:@"console.log(div.tagName);"];
    [js appendString:@"var label = div.querySelector('label');"];
    [js appendString:@"label.removeAttribute('for');"];
    [js appendString:@"console.log(label.tagName);"];
    NSString *tmpStr = [NSString stringWithFormat:@"%@|%@|%@", type, width, height];
    [js appendString:[NSString stringWithFormat:@"label.onclick = function() {webkit.messageHandlers.callbackHandler.postMessage('%@');}", tmpStr]];
    //    [js appendString:@"}"];
    
    return js;
}

- (NSString *)getZoomDisableScript {
    NSString *jsString = @"var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable= 0');document.getElementsByTagName('head')[0].appendChild(meta);";
    
    return jsString;
}
- (NSString *)getCreateWebScript {
    NSString *jsString = @"var originalWindowClose=window.close;window.close=function(){var iframe=document.createElement('IFRAME');iframe.setAttribute('src','back://'),document.documentElement.appendChild(iframe);originalWindowClose.call(window)};";
    return jsString;
}

- (NSString *)getProjectTypeScript:(NSString *)type {
    //    project_type: String - 해당 프로젝트의 타입(텍스트, 이미지 및 비디오, 오디오) (‘T’ , ’I’ , ’A’)
    
    NSString *jsString = @"";
    if ([type isEqualToString:@"A"]) {
        jsString = @"var element = document.getElementById('workFile'); element.setAttribute('accept', 'video/*'); element.setAttribute('capture','');";
    }
    else if ([type isEqualToString:@"I"]) {
        jsString = @"document.getElementById('workFile').setAttribute('capture','');";
    }
    return jsString;
}

- (void)checkProjectType:(WKWebView *)webView {
    
    NSURL *url = webView.URL;
    if (url.query == nil || [url.query containsString:@"seq="] == NO) {
        return;
    }
    
    NSArray *arr = [url.query componentsSeparatedByString:@"&"];
    NSString *seqId = @"";
    for (NSString *str  in arr) {
        NSArray *params = [str componentsSeparatedByString:@"="];
        if ([[params firstObject] isEqualToString:@"seq"]) {
            seqId = [params lastObject];
            break;
        }
    }
    
    if (seqId.length == 0) {
        return;
    }
    
    NSString *infoUrl = [NSString stringWithFormat:@"%@://%@/project/getProjectDetailAtApp?seq=%@", url.scheme, url.host, seqId];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:infoUrl]];
    
    if (data == nil) {  //한번해서 못가져오는 케이스가 발생 두번 요청하면 데이터 가져옴
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:infoUrl]];
    }
    
    if (data == nil) {
        return;
    }
    
    NSError *error = nil;
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return;
    }
    
    BOOL isMobile = [[jsonDic objectForKey:@"mobile_only"] boolValue];
    NSString *project_type = [[jsonDic objectForKey:@"project_info"] objectForKey:@"project_type"];
    NSString *project_option = [[jsonDic objectForKey:@"project_info"] objectForKey:@"project_option"];
    
    
    //    NSString *width = @"";
    //    NSString *height = @"";
    //
    //    if ([project_option isEqual:[NSNull null]] == NO) {
    //        NSArray *arr = [project_option componentsSeparatedByString:@"*"];
    //        width = [arr firstObject];
    //        height = [arr lastObject];
    //    }
    //
    //    NSString *js = [self getChangeElement:project_type width:width height:height];
    //        [webView evaluateJavaScript:js completionHandler:nil];
    
    if (isMobile) {
        NSString *js = [self getProjectTypeScript:project_type];
        
        [webView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"== error: %@" ,error.localizedDescription);
            }
        }];
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURL *url = navigationAction.request.URL;
    NSLog(@"== url: %@", url);
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if ([url.host isEqualToString:@"www.aiworks.co.kr"]
            && ([url.scheme isEqualToString:@"http"]
                || [url.scheme isEqualToString:@"https"])) {
            
            decisionHandler(WKNavigationActionPolicyAllow);
        }
        else {
            [[AppDelegate instance] openUrl:url.absoluteString];
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences *))decisionHandler  API_AVAILABLE(ios(13.0)) {
    
    NSURL *url = navigationAction.request.URL;
    NSLog(@"== url: %@", url);
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if ([SERVER_URL hasSuffix:url.host]
            && ([url.scheme isEqualToString:@"http"]
                || [url.scheme isEqualToString:@"https"])) {
            
            decisionHandler(WKNavigationActionPolicyAllow, preferences);
        }
        else {
            [[AppDelegate instance] openUrl:url.absoluteString];
            decisionHandler(WKNavigationActionPolicyCancel, preferences);
        }
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow, preferences);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [[AppDelegate instance] startIndicator];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[AppDelegate instance] stopIndicator];
    });
    NSLog(@"== fun: %s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [[AppDelegate instance] stopIndicator];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    [self checkProjectType:webView];
    
    NSLog(@"== fun: %s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [[AppDelegate instance] stopIndicator];
    [self checkProjectType:webView];
    NSLog(@"== fun: %s", __FUNCTION__);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [[AppDelegate instance] stopIndicator];
    NSLog(@"== fun: %s", __FUNCTION__);
}

- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"== ui func : %s" , __PRETTY_FUNCTION__);
    
    WKUserContentController *userController = [[WKUserContentController alloc] init];
    // 화면에 보여지기 위해 addSubView 를 하므로 window.close() 시에 remove view 를 하도록 아래 소스를 document 시작시점에 inject 한다.
    
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:[self getCreateWebScript] injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    
    [userController addUserScript:userScript];
    
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    configuration.userContentController = userController;
    //    navigationAction.sourceFrame.request
    //    http://www.aiworks.co.kr/auth/openAuthPopup
    self.createWebView = [[WKWebView alloc] initWithFrame:_baseView.bounds configuration:configuration];
    _createWebView.allowsBackForwardNavigationGestures = YES;
    _createWebView.navigationDelegate = self;
    _createWebView.UIDelegate = self;
    
    [_baseView addSubview:_createWebView];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onclickedButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(_baseView.frame.size.width - 50, 0, 50, 50);
    btn.tag = 10000;
    [_createWebView addSubview:btn];
    return _createWebView;
}
- (void)onclickedButtonAction:(UIButton *)sender {
    if (sender.tag == 10000) {
        [_createWebView removeFromSuperview];
        self.createWebView = nil;
    }
}
- (void)webViewDidClose:(WKWebView *)webView {
    if ([webView isEqual:_createWebView]) {
        [self.createWebView removeFromSuperview];
        self.createWebView = nil;
    }
    NSLog(@"== ui func : %s" , __PRETTY_FUNCTION__);
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"== message: %@" , message);
//    if ([message.name isEqualToString:@"callbackHandler"]) {
//        NSString *param = message.body;
//        if (param.length > 0) {
//            NSArray *arr = [param componentsSeparatedByString:@"|"];
//            self.type = [arr firstObject];
//            if (arr.count == 3) {
//                self.width = [arr objectAtIndex:1];
//                self.height = [arr objectAtIndex:2];
//            }
//
//            if ([_type isEqualToString:@"I"]) {
//                [self openCamera:UIImagePickerControllerSourceTypeCamera];
//            }
//            else {
//                [self openCamera:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
//            }
//        }
//    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"== ui func : %s" , __PRETTY_FUNCTION__);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:NO completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"== ui func : %s" , __PRETTY_FUNCTION__);
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    
    [self presentViewController:alertController animated:NO completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertController.textFields.firstObject;
        completionHandler(textField.text);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(nil);
    }]];
    
    [self presentViewController:alertController animated:NO completion:nil];
    NSLog(@"== ui func : %s" , __PRETTY_FUNCTION__);
}

#pragma mark - UIScrollViewDelegate
//- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
//    [scrollView.pinchGestureRecognizer setEnabled:NO];
//}
//- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return nil;
//}
//
//- (void)openCamera:(UIImagePickerControllerSourceType)sourceType {
//    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
//    imgPicker.delegate = self;
//    imgPicker.sourceType = sourceType;
//    imgPicker.allowsEditing = NO;
//
//    if (sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
//        imgPicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
//        imgPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
//        imgPicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
//    }
//    [self presentViewController:imgPicker animated:NO completion:nil];
//}
//#pragma mark - UINavigationControllerDelegate,UIImagePickerControllerDelegate
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [picker dismissViewControllerAnimated:NO completion:nil];
//}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
//
//    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
//        UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
//        UIImage *resizeImg = img;
//        if (img != nil && _width.length > 0 && _height.length > 0) {
//            resizeImg = [img resizedImageWithBounds:CGSizeMake([_width floatValue], [_height floatValue])];
//        }
//
//        NSData *data = UIImagePNGRepresentation(resizeImg);
//        NSString *base64 = [data base64EncodedStringWithOptions:0];
//        NSString *js = [NSString stringWithFormat:@"drawCanvas(%@)", base64];
//        [_wkWebView evaluateJavaScript:js completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//            int k = 0;
//        }];
//    }
//    [picker dismissViewControllerAnimated:NO completion:nil];
//}
@end
