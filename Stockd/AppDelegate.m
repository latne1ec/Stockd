//
//  AppDelegate.m
//  Stockd
//
//  Created by Evan Latner on 6/29/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <Stripe/Stripe.h>
#import "Animation.h"

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

NSString * const StripePublishableKey = @"pk_live_OudB0BOII1ZayE7nENWn3qpr";


@interface AppDelegate ()
@property(nonatomic) int alreadyShowed;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    _alreadyShowed = 0;
    //Parse Keys
    [Parse setApplicationId:@"CYM8KYF8jzPvy9usbmgAZouY1X1t3WbWLErZzxgc"
                  clientKey:@"56dirzgs3IEhiIrV6AWu898rTmNIyUBf79vWwbE8"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [PFImageView class];
    
    //Stripe Keys
    [Stripe setDefaultPublishableKey:StripePublishableKey];
    
    LeftMenuViewController *leftMenu = [[LeftMenuViewController alloc] init];
    
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    
    if([UIScreen mainScreen].bounds.size.height <= 568.0) {
        //iPhone 5
        [SlideNavigationController sharedInstance].portraitSlideOffset = 200.0f;
    }
    else {
        [SlideNavigationController sharedInstance].portraitSlideOffset = 240.0f;
    }
    
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(-15, 0, 30, 30)];
    [button setImage:[UIImage imageNamed:@"stockdMenu"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"stockdMenu"] forState:UIControlStateHighlighted];
    [button addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [SlideNavigationController sharedInstance].leftBarButtonItem = leftBarButtonItem;
    
    [[SlideNavigationController sharedInstance] enableTapGestureToCloseMenu:YES];
    
    _package_itemsDictionary = [[NSMutableDictionary alloc] init];
    _extraPackage_itemsDictionary = [[NSMutableDictionary alloc] init];
    _packageSize = 1;
    
    
    return YES;
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}
- (void)applicationWillTerminate:(UIApplication *)application {
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                annotation:annotation];
}

-(void)showAnimation {
    if(_alreadyShowed==0) {
            
        _alreadyShowed = 1;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    Animation *animation = [[Animation alloc] initWithFrame:CGRectMake(0,0,screenRect.size.width,screenRect.size.height)];
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:animation];
    [animation load];
        
    }
}

@end
