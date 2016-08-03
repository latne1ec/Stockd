//
//  OrderView.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"
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

#import "AddPackagesCollectionViewController.h"
#import "OrderOneTableViewCell.h"
#import "OrderTwoTableViewCell.h"
#import "OrderThreeTableViewCell.h"
#import "OrderFourTableViewCell.h"
#import "OrderFiveTableViewCell.h"
#import "FeesTableViewCell.h"
#import "JustPlacedOrderViewCell.h"
#import "PreviousOrderStatusCell.h"
#import "CZPicker.h"

@interface OrderView : UIView <UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,TSMessageViewProtocol, CZPickerViewDataSource, CZPickerViewDelegate>

@property CGPoint initialPosition;
@property Boolean isUp;
@property UITableView *tableView;

@property (nonatomic) float subtotal;
@property (nonatomic) float taxes;
@property (nonatomic) int discount;
@property (nonatomic) int theZeroSignal;
@property (nonatomic) int BOOZE;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSArray* packageKeys;
@property (nonatomic, strong) NSArray* extraKeys;
@property (nonatomic, strong) NSString *packageSizeString;
@property (nonatomic) BOOL isPastOrder;
@property (nonatomic) BOOL onAddPackagesScreen;
@property (nonatomic) BOOL justPlacedOrder;
@property (nonatomic, strong) NSMutableArray *zipcodes;
@property (nonatomic) BOOL canOrder;

@property (nonatomic, strong) NSMutableDictionary* pastOrderPackage_itemsDictionary;
@property (nonatomic, strong) NSMutableDictionary* pastOrderExtraPackage_itemsDictionary;

@property (nonatomic) NSDate* pastDeliveryDate;
@property (nonatomic) NSString* pastDeliveryDay;

@property (nonatomic) NSDate* deliveryDate;
@property (nonatomic) NSString* deliveryDay;

@property (nonatomic, strong) NSMutableDictionary *itemsDictionary;

@property (nonatomic) PFObject *previousOrder;

@property (nonatomic) AddPackagesCollectionViewController * parentViewController;

@property (nonatomic, strong) NSString *orderNumber;
@property (nonatomic, strong) PFObject *order;
@property (nonatomic, strong) NSString *beerItem;
@property (nonatomic, strong) NSString *liquorItem;
@property (nonatomic) float finalTotal;
@property (nonatomic, strong) NSMutableDictionary *thePackage_itemsDictionary;
@property (nonatomic, strong) NSMutableDictionary *theExtraPackage_itemsDictionary;

@property (nonatomic) int packageSize;

@property (nonatomic, assign) CGFloat lastContentOffset;

-(void) removeEmptyPackages;
-(void) update;
-(void) initializeViewController;

@end
