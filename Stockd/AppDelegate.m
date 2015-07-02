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

#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

NSString * const StripePublishableKey = @"pk_live_OudB0BOII1ZayE7nENWn3qpr";


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //Parse Keys
    [Parse setApplicationId:@"CYM8KYF8jzPvy9usbmgAZouY1X1t3WbWLErZzxgc"
                  clientKey:@"56dirzgs3IEhiIrV6AWu898rTmNIyUBf79vWwbE8"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [PFImageView class];
    
    //Stripe Keys
    [Stripe setDefaultPublishableKey:StripePublishableKey];
    
    //Status Bar
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //Nav Bar Color
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.937 green:0.204 blue:0.733 alpha:1]];
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor colorWithRed:0.937 green:0.204 blue:0.733 alpha:1], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    
    
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




@end
