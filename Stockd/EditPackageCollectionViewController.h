//
//  EditPackageCollectionViewController.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ItemCollectionViewCell.h"
#import "UpdateCartCollectionReusableView.h"

@interface EditPackageCollectionViewController : UICollectionViewController
{
    id parent;
    int packageSize;
}

@property (nonatomic, strong) NSString *packageName;
@property (nonatomic) int packageSize;
@property (nonatomic, strong) id parent;
//@property (nonatomic, strong) NSArray *itemsToEdit;
@property (nonatomic, strong) NSString *beerItem;
@property (nonatomic, strong) NSString *liquorItem;

@property (nonatomic, strong) NSMutableDictionary *thePackage_itemsDictionary;
@property (nonatomic, strong) NSMutableDictionary *theExtraPackage_itemsDictionary;

- (IBAction)decrementQuantity:(id)sender;
- (IBAction)incrementQuantity:(id)sender;

- (IBAction)updateCartTapped:(id)sender;

-(BOOL) checkValidBeerLimit;
@end
