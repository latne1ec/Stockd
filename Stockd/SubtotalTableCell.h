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

@property (weak, nonatomic) IBOutlet UIButton *sizeButton;


@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *taxesLabel;

@property (weak, nonatomic) IBOutlet UILabel *finalTotalLabel;

@property (weak, nonatomic) IBOutlet UILabel *discountLabel;

@end
