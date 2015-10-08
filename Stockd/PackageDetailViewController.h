//
//  PackageDetailViewController.h
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ItemTableCell.h"
#import "DrinksTableViewController.h"
#import "FoodTableViewController.h"
#import "CartTableViewController.h"

@interface PackageDetailViewController : UITableViewController

@property (nonatomic, strong) NSString *packageName;
@property (nonatomic, strong) NSString *packageType;


- (IBAction)incrementQuantityButtonTapped:(id)sender;

- (IBAction)decrementQuantityButtonTapped:(id)sender;


@end
