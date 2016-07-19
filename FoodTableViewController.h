//
//  FoodTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TSMessage.h"
#import "FoodTableCell.h"
#import "ProgressHUD.h"
#import "SlideNavigationController.h"
#import "PackageDetailViewController.h"

@interface FoodTableViewController : UITableViewController <SlideNavigationControllerDelegate>
{
    NSString *tappedMenu;
}


@property(nonatomic,strong) NSString *tappedMenu;

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu;
- (BOOL)slideNavigationControllerShouldDisplayRightMenu;

@end
