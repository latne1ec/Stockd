//
//  DrinksTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "DrinksTableCell.h"
#import "SlideNavigationController.h"
#import "PackageDetailViewController.h"
#import "ProgressHUD.h"

@interface DrinksTableViewController : UITableViewController <SlideNavigationControllerDelegate>


- (BOOL)slideNavigationControllerShouldDisplayLeftMenu;
- (BOOL)slideNavigationControllerShouldDisplayRightMenu;

@end
