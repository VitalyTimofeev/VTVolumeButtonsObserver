//
//  AppDelegate.m
//  VTVolumeButtonsObserver
//
//  Created by Vitaly Timofeev on 05/06/15.
//  Copyright (c) 2015 Vitaly Timofeev. All rights reserved.
//

#import "AppDelegate.h"
#import "VTVolumeButtonsObserver.h"

@interface AppDelegate ()

@property (strong, nonatomic) VTVolumeButtonsObserver *observer;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *viewController = [UIViewController new];
    UILabel *promptLabel = [UILabel new];
    promptLabel.translatesAutoresizingMaskIntoConstraints = NO;
    promptLabel.text = @"Push volume buttons!";
    promptLabel.textAlignment = NSTextAlignmentCenter;
    [viewController.view addSubview:promptLabel];
    [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[promptLabel]|" options:kNilOptions metrics:nil views:@{@"promptLabel" : promptLabel}]];
    [viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[promptLabel]|" options:kNilOptions metrics:nil views:@{@"promptLabel" : promptLabel}]];
    viewController.view.backgroundColor = [UIColor whiteColor];
    window.rootViewController = viewController;
    self.window = window;
    [self.window makeKeyAndVisible];
    
    __weak typeof (self) welf = self;
    self.observer = [VTVolumeButtonsObserver observerWithUpButtonBlock:^{
        [welf showAlertWithUpButton:YES];
    } downButtonBlock:^{
        [welf showAlertWithUpButton:NO];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        welf.observer = nil;
    });
    
    return YES;
}

- (void)showAlertWithUpButton:(BOOL)isUpButton
{
    [[[UIAlertView alloc] initWithTitle:(isUpButton ? @"Up" : @"Down") message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
