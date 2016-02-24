//
//  AddPackagesTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PackageTableCell.h"
#import "SubtotalTableCell.h"
#import "ProgressHUD.h"
#import "CartButton.h"
#import "CartTableViewController.h"
#import "SlideNavigationController.h"



@interface AddPackagesTableViewController : UITableViewController <SlideNavigationControllerDelegate>


@property (nonatomic, strong) PFFile *picture;
@property (nonatomic, strong) NSString *orderNumber;
@property (nonatomic, strong) PFObject *order;

@property (nonatomic, strong) NSMutableArray *food;
@property (nonatomic, strong) NSArray *drinks;

@property (nonatomic) int packageSize;

@property (nonatomic, strong) NSString *packageType;




@end
