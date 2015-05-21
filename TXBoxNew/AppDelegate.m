//
//  AppDelegate.m
//  TXBoxNew
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "AppDelegate.h"
#import "TXSqliteOperate.h"

@interface AppDelegate ()<UIAlertViewDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //创建数据库
    TXSqliteOperate *sqlite = [[TXSqliteOperate alloc] init];
    [sqlite createTable:CALL_RECORDS_TABLE_NAME];
    
    //修改导航栏的sytle
    [self changeNavigationBarStyle];
    
    usDefaults = [NSUserDefaults standardUserDefaults];
    [usDefaults setValue:@"0" forKey:call_divert];//呼转状态
    /*
    //提示绑定拇机号码
    if (![[usDefaults valueForKey:@"isSetting"] intValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否绑定拇机号码？" delegate:self cancelButtonTitle:@"以后再说" otherButtonTitles:@"确定", nil];
        alert.delegate = self;
        alert.alertViewStyle =UIAlertViewStylePlainTextInput;
        [alert show];

    }
    */
    
    //注册LeanCloud
    //[AVOSCloud setApplicationId:@"" clientKey:@""];
        
    
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        VCLog(@"sure,set number:13698006536");
        //保存拇机号码 muji_bind_number
        [usDefaults setValue:@"13698006536" forKey:@"muji_bind_number"];
        //保存isSetting状态
        [usDefaults setValue:@"1" forKey:@"isSetting"];
    }
}
-(void) changeNavigationBarStyle
{
    //背景颜色
    [[UINavigationBar appearance] setBarTintColor:RGBACOLOR(35, 35, 35, 1)];
    //背景图片
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bg.png"] forBarMetrics:UIBarMetricsDefault];
    
    //设置返回按钮字体颜色
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    //设置返回按钮图片
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back_btn.png"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back_btn.png"]];
    
    
    /**
     * 可以使用导航栏的titleTextAttributes属性来定制导航栏的文字风格。
     * 在text attributes字典中使用如下一些key，可以指定字体、文字颜色、文字阴影色以及文字阴影偏移量：
     * UITextAttributeFont – 字体key
     * UITextAttributeTextColor – 文字颜色key
     * UITextAttributeTextShadowColor – 文字阴影色key
     * UITextAttributeTextShadowOffset – 文字阴影偏移量key
     */
    
    //修改导航栏标题的字体
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes:  [NSDictionary dictionaryWithObjectsAndKeys:                                                         [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,   shadow, NSShadowAttributeName,[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    
    //修改导航栏标题为图片
    //self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appcoda-logo.png"]];
    
    /**
     * 1.修改状态栏的风格
     *   在Info表中插入一个新的key
     *   名字为View controller-based status bar appearance，并将其值设置为NO
     *   [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
     * 2.直接在每个需要的viewContor中 -(UIStatusBarStyle)preferredStatusBarStyle {    return UIStatusBarStyleLightContent;   }
     */
    
    //修改状态栏的风格
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //隐藏状态栏
    /**
     - (BOOL)prefersStatusBarHidden{
        
     return YES;
     }
     
     */
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    
    [self beingBackgroundUpdateTask];
    // 在这里加上你需要长久运行的代码
    [self endBackgroundUpdateTask];
}

- (void)beingBackgroundUpdateTask
{
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void)endBackgroundUpdateTask
{
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //保存isSetting状态
    [usDefaults setValue:@"1" forKey:@"isSetting"];
}

@end
