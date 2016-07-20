//
//  OrderFourTableViewCell.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell/MGSwipeTableCell.h"
#import "MGSwipeTableCell/MGSwipeButton.h"

@interface OrderFourTableViewCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UILabel *orderTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderPriceLabel;

@property (strong, nonatomic) CALayer *bottomBorder;

@end
