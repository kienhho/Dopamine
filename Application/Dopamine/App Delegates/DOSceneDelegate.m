//
//  SceneDelegate.m
//  Dopamine
//
//  Created by Lars Fröder on 23.09.23.
//

#import "DOSceneDelegate.h"
#import "DONavigationController.h"
#import "DOEnvironmentManager.h"
#import <libjailbreak/jbclient_xpc.h>
#import <UserNotifications/UserNotifications.h>

@interface DOSceneDelegate () <UNUserNotificationCenterDelegate>

@property(nonatomic) BOOL schedulingCompatibilityNotice;

@end

@implementation DOSceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    window.rootViewController = [[DONavigationController alloc] init];
    [window makeKeyAndVisible];
    self.window = window;
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
}

+ (void)relaunch
{
    UIWindowScene *windowScene = (UIWindowScene *)[[[UIApplication sharedApplication] connectedScenes] anyObject];
    DOSceneDelegate *instance = (DOSceneDelegate *)windowScene.delegate;

    [UIView animateWithDuration:0.3 animations:^{
        instance.window.alpha = 0;
    } completion:^(BOOL finished) {
        UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)instance.window.windowScene];
        window.rootViewController = [[DONavigationController alloc] init];
        [window makeKeyAndVisible];
        instance.window = window;
        instance.window.alpha = 0;
        [UIView animateWithDuration:0.3 animations:^{
            instance.window.alpha = 1;
        }];
    }];
}

- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![DOEnvironmentManager sharedManager].isJailbroken ||
            self.schedulingCompatibilityNotice ||
            jbclient_jbsettings_get_bool("wxCompatibilityNoticeAcknowledged") ||
            !jbclient_jbsettings_get_bool("wxCompatibilityUsed")) return;

        self.schedulingCompatibilityNotice = YES;
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (!granted || error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.schedulingCompatibilityNotice = NO;
                });
                return;
            }

            UNMutableNotificationContent *content = [UNMutableNotificationContent new];
            content.title = @"Executable Memory Compatibility";
            content.body = @"A jailbreak tweak or other software requested executable-memory compatibility while JIT was turned off. This behavior will be deprecated in a future version.";
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"wxCompatibilityNotice" content:content trigger:trigger];
            [center addNotificationRequest:request withCompletionHandler:^(NSError *scheduleError) {
                if (!scheduleError) {
                    jbclient_platform_jbsettings_set_bool("wxCompatibilityNoticeAcknowledged", true);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.schedulingCompatibilityNotice = NO;
                });
            }];
        }];
    });
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    completionHandler(UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionList);
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


@end
