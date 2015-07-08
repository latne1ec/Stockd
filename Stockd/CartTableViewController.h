//
//  CartTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 7/7/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "CartTableCell.h"
#import "SubtotalTableCell.h"
#import "EditPackageTableViewController.h"
#import "PaymentTableViewController.h"
#import "TSMessage.h"
#import "ConfirmationTableViewController.h"

@interface CartTableViewController : UITableViewController <TSMessageViewProtocol>


@property (nonatomic, strong) NSArray *packages;
@property (nonatomic, strong) NSDictionary *items;


- (IBAction)getStockedTapped:(id)sender;
-(void)updateQuantitiesFor:(NSString*)packageName with:(NSMutableArray*)edited;

@end
