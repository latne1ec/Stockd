//
//  PreviousOrdersViewController.h
//  Stockd
//
//  Created by Alex Consel on 2016-02-22.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SlideNavigationController.h"
#import "ProgressHUD.h"
#import "DateTools.h"
#import "PreviousOrderCell.h"


@interface PreviousOrdersViewController : UITableViewController <SlideNavigationControllerDelegate>

@property (nonatomic, strong) UILabel *noPreviousOrders;


@end
