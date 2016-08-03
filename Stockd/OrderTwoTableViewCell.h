//
//  OrderTwoTableViewCell.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell/MGSwipeTableCell.h"
#import "MGSwipeTableCell/MGSwipeButton.h"

@interface OrderTwoTableViewCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UIImageView *sliderIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *orderTitleLabel;

@property (strong, nonatomic) CALayer *bottomBorder;

@end
