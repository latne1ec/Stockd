//
//  EditPackageTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 7/7/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "EditItemsTableCell.h"
#import "UpdateCartTableCell.h"

@interface EditPackageTableViewController : UITableViewController
{
    id parent;
    int packageSize;
}

@property (nonatomic, strong) NSString *packageName;
@property (nonatomic) int packageSize;
@property (nonatomic, strong) id parent;
@property (nonatomic, strong) NSArray *itemsToEdit;
@property (nonatomic, strong) NSString *beerItem;
@property (nonatomic, strong) NSString *liquorItem;



- (IBAction)decrementQuantity:(id)sender;
- (IBAction)incrementQuantity:(id)sender;


- (IBAction)updateCartTapped:(id)sender;

@end
