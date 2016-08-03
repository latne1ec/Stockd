//
//  FeesTableViewCell.h
//  Stockd
//
//  Created by Evan Latner on 7/20/16.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceFeeLabel;

@end
