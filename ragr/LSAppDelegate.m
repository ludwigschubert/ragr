//
//  LSAppDelegate.m
//  ragr
//
//  Created by Ludwig Schubert on 10.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LSAppDelegate.h"

#import "LSViewController.h"
#import "NRGridView.h"

@implementation LSAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self customizeUI];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
 
    self.viewController = [[LSViewController alloc] init];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)customizeUI {
    @try {        
        
        UIColor *textColor = [UIColor blackColor];
        UIColor *shadowColor = [UIColor whiteColor];
        NSValue *offsetValue = [NSValue valueWithUIOffset:UIOffsetMake(0, 1)];
        UIFont *textFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
        NSDictionary *titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             textFont,
                                             UITextAttributeFont,
                                             textColor,
                                             UITextAttributeTextColor, 
                                             shadowColor,
                                             UITextAttributeTextShadowColor,
                                             offsetValue,
                                             UITextAttributeTextShadowOffset, nil];
        [[UINavigationBar appearance] setTitleTextAttributes:titleTextAttributes];
        [[UIBarButtonItem appearance] setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
        
        UIEdgeInsets buttonInsets = UIEdgeInsetsMake(0, 12, 0, 12);
        UIImage *barItemImageNormal = [UIImage imageNamed:@"btn_normal"];
        UIImage *barItemImageNormalResizeable = [barItemImageNormal resizableImageWithCapInsets:buttonInsets];
        [[UIBarButtonItem appearance] setBackgroundImage:barItemImageNormalResizeable 
                                                forState:UIControlStateNormal 
                                              barMetrics:UIBarMetricsDefault];
        
        UIImage *barItemImagePressed = [UIImage imageNamed:@"btn_pressed"];
        UIImage *barItemImagePressedResizeable = [barItemImagePressed resizableImageWithCapInsets:buttonInsets];
        [[UIBarButtonItem appearance] setBackgroundImage:barItemImagePressedResizeable 
                                                forState:UIControlStateHighlighted 
                                              barMetrics:UIBarMetricsDefault];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Customizing UI Failed. Maybe Images are corrupt/wrongly named?");
    }
}

- (void) unreachable
{
    [NRGridView class]; //This prevents Linker from removing this class
}

@end
