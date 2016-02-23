//
//  PreviousOrderCell.h
//  Stockd
//
//  Created by Alex Consel on 2016-02-22.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreviousOrderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deliveryDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end
