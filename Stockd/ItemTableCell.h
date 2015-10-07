//
//  ItemTableCell.h
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemQuantityLabel;

@property (weak, nonatomic) IBOutlet UILabel *itemDetailLabel;

@property (weak, nonatomic) IBOutlet UIButton *decrementButton;

@property (weak, nonatomic) IBOutlet UIButton *incrementButton;

@property (weak, nonatomic) IBOutlet UILabel *itemPriceLabel;

@end
