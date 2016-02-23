//
//  CartTableCell.h
//  Stockd
//
//  Created by Evan Latner on 7/7/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell/MGSwipeTableCell.h"
#import "MGSwipeTableCell/MGSwipeButton.h"

@interface CartTableCell : MGSwipeTableCell


@property (weak, nonatomic) IBOutlet UILabel *packageNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *packageItems;

@property (weak, nonatomic) IBOutlet UILabel *packagePriceLabel;

@property (weak, nonatomic) IBOutlet UIButton *lockIconButton;



@end
