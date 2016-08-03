//
//  PreviousOrderStatusCell.h
//  Stockd
//
//  Created by Evan Latner on 7/21/16.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviousOrderStatusCell : UITableViewCell

@property (strong, nonatomic) CALayer *bottomBorder;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sliderIconImageView;

@end
