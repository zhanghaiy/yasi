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

#import "CheckSuccessViewController.h"
#import "CheckKeyWordViewController.h"

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
    
//    CheckSuccessViewController *sucVC = [[CheckSuccessViewController alloc]initWithNibName:@"CheckSuccessViewController" bundle:nil];
//    self.window.rootViewController = sucVC;
    
    if (![OralDBFuncs initializeDb])
    {
        NSLog(@"init DB fail");
    }
    
    [self.window makeKeyAndVisible];
    
    
    [ShareSDK registerApp:@"8d356e4e5501"];//字符串api20为您的ShareSDK的AppKey
    
    //添加新浪微博应用 注册网址 http://open.weibo.com
    [ShareSDK connectSinaWeiboWithAppKey:@"3675208550"
                               appSecret:@"85222ba5221740f0e88e06d1d70d3aa3"
                             redirectUri:@"http://www.sharesdk.cn"];
    //当使用新浪微博客户端分享的时候需要按照下面的方法来初始化新浪的平台 （注意：2个方法只用写其中一个就可以）
    //    [ShareSDK  connectSinaWeiboWithAppKey:@"3675208550"
    //                                appSecret:@"85222ba5221740f0e88e06d1d70d3aa3"
    //                              redirectUri:@"http://www.sharesdk.cn"
    //                              weiboSDKCls:[WeiboSDK class]];
    
    //添加QQ空间应用  注册网址  http://connect.qq.com/intro/login/
    [ShareSDK connectQZoneWithAppKey:@"1104357093"
                           appSecret:@"x0N9V31tskvdnZVi"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    //添加QQ应用  注册网址  http://mobile.qq.com/api/
    [ShareSDK connectQQWithQZoneAppKey:@"1104357093"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    //添加微信应用  http://open.weixin.qq.com
    [ShareSDK connectWeChatWithAppId:@"wxd6749498f9bd4d7b"
                           appSecret:@"c5dd23679427384d898266eab61d4cd7"
                           wechatCls:[WXApi class]];
    
    //添加人人网应用 注册网址  http://dev.renren.com
    [ShareSDK connectRenRenWithAppId:@"475358"
                              appKey:@"d9e110607f104e6fa045c534db84ad11"
                           appSecret:@"8801bce4058d45f9a1f0bfc52556ecc9"
                   renrenClientClass:[RennClient class]];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
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
