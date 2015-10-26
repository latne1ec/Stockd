//
//  AppDelegate.h
//  Stockd
//
//  Created by Evan Latner on 6/29/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "LeftMenuViewController.h"
#import "CartItemObject.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSMutableDictionary *package_itemsDictionary;
@property (nonatomic, strong) NSMutableDictionary *extraPackage_itemsDictionary;

@property (nonatomic) int packageSize;




-(void)showAnimation;



@end

