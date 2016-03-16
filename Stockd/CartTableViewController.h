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
#import "ExtraItemTableCell.h"
#import "SubtotalTableCell.h"
#import "EditPackageTableViewController.h"
#import "PaymentTableViewController.h"
#import "TSMessage.h"
#import "ConfirmationTableViewController.h"
#import "PickSizeViewController.h"
#import "SlideNavigationController.h"
#import "UIViewController+ENPopUp.h"
#import "DeliveryInstructionsPopupViewController.h"

@interface CartTableViewController : UITableViewController <TSMessageViewProtocol, SlideNavigationControllerDelegate>

//@property (nonatomic, strong) NSDictionary *items;
@property (nonatomic, strong) NSString *orderNumber;
@property (nonatomic, strong) PFObject *order;
@property (nonatomic, strong) NSString *beerItem;
@property (nonatomic, strong) NSString *liquorItem;
@property (nonatomic) float finalTotal;
@property (nonatomic, strong) NSMutableDictionary *thePackage_itemsDictionary;
@property (nonatomic, strong) NSMutableDictionary *theExtraPackage_itemsDictionary;



@property (nonatomic) int packageSize;


- (IBAction)sizeButtonTapped:(id)sender;
- (IBAction)getStockedTapped:(id)sender;
-(void)initializeViewController;

-(void) removeEmptyPackages;


-(void)dismissViewAndGetStocked;


@end
