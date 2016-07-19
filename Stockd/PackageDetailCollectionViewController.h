//
//  PackageDetailCollectionViewController.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ItemCollectionViewCell.h"
#import "DrinksCollectionViewController.h"
#import "FoodCollectionViewController.h"
#import "CartTableViewController.h"

@interface PackageDetailCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSString *packageName;
@property (nonatomic, strong) NSString *packageType;


- (IBAction)incrementQuantityButtonTapped:(id)sender;

- (IBAction)decrementQuantityButtonTapped:(id)sender;


@end
