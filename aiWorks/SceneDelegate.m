#import "SceneDelegate.h"
#import "UIView+Utility.h"
#import "WkWebViewController.h"
#import "AppDelegate.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

+ (SceneDelegate *)instance {
    if (@available(iOS 13.0, *)) {
        return (SceneDelegate *)[[UIApplication sharedApplication].connectedScenes allObjects].firstObject.delegate;
    } else {
        return nil;
    }
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)) {
    
    if (@available(iOS 13.0, *)) {
        
        self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
        [AppDelegate instance].window = self.window;
        [[AppDelegate instance] callIntroViewcontroller];
    }
}


- (void)sceneDidDisconnect:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
    
}


- (void)sceneWillEnterForeground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
    if ([[AppDelegate instance] isUpdateAvailable]) {
        [[AppDelegate instance] showUpdateAlertView];
    }
}


- (void)sceneDidEnterBackground:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}

@end
