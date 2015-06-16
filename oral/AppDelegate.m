//
//  AppDelegate.m
//  oral
//
//  Created by cocim01 on 15/5/14.
//  Copyright (c) 2015年 keximeng. All rights reserved.
//

#import "AppDelegate.h"
#import "TopicMainViewController.h"
#import "LogInViewController.h"
#import "OralDBFuncs.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([OralDBFuncs getCurrentUserName])
    {
        [OralDBFuncs updateUserLastLoginTimeStamp:[OralDBFuncs getCurrentUserName]];
        TopicMainViewController *rootVC = [[TopicMainViewController alloc]init];
        UINavigationController *topicNvc = [[UINavigationController alloc]initWithRootViewController:rootVC];
        topicNvc.navigationBarHidden = YES;
        self.window.rootViewController = topicNvc;
    }
    else
    {
         LogInViewController *logInVC = [[LogInViewController alloc]initWithNibName:@"LogInViewController" bundle:nil];
         self.window.rootViewController = logInVC;
    }
    
//     NSString *str = [NSString stringWithFormat:@"%@%@?userId=%@&teacherName=%@&change=0",kBaseIPUrl,kSelectTeacherUrl,[OralDBFuncs getCurrentUserID],@"林大"];
//    NSLog(@"%@",str);
//    http://114.215.172.72:80/yasi/teacher/selectTeacherInfoById.do?userId=FF3E0ED4D67A4294A55A7D7A7CC41785&teacherName=林大&change=0
    
    if (![OralDBFuncs initializeDb])
    {
        NSLog(@"init DB fail");
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
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
