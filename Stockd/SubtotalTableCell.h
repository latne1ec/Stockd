//
//  SubtotalTableCell.h
//  Stockd
//
//  Created by Evan Latner on 7/7/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubtotalTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *getStockdButton;

@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;


@end
