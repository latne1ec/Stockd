//
//  EditItemsTableCell.m
//  Stockd
//
//  Created by Evan Latner on 7/7/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "EditItemsTableCell.h"

@implementation EditItemsTableCell

@synthesize itemQuantityLabel;

- (void)awakeFromNib {
    // Initialization code
    self.itemPriceLabel.minimumScaleFactor = 0.5;
    self.itemPriceLabel.adjustsFontSizeToFitWidth = YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
