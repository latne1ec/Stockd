//
//  OrderOneTableViewCell.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell/MGSwipeTableCell.h"
#import "MGSwipeTableCell/MGSwipeButton.h"

@interface OrderOneTableViewCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UIImageView *sliderIconImageView;

@property (weak, nonatomic) IBOutlet UILabel *orderTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (strong, nonatomic) CALayer *bottomBorder;

@end
