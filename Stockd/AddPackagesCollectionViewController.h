//
//  AddPackagesCollectionViewController.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-12.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "PackageCollectionViewCell.h"
#import "SubtotalTableCell.h"
#import "ProgressHUD.h"
#import "CartButton.h"
#import "CartTableViewController.h"
#import "SlideNavigationController.h"

@interface AddPackagesCollectionViewController : UICollectionViewController <TSMessageViewProtocol>
@property (nonatomic, strong) PFFile *picture;
@property (nonatomic, strong) NSString *orderNumber;
@property (nonatomic, strong) PFObject *order;

@property (nonatomic, strong) NSMutableArray *food;
@property (nonatomic, strong) NSArray *drinks;

@property (nonatomic) int packageSize;

@property (nonatomic, strong) NSString *packageType;
@end
