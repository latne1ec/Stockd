//
//  EditItemsTableCell.h
//  Stockd
//
//  Created by Evan Latner on 7/7/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditItemsTableCell : UITableViewCell
{
    UILabel *itemQuantityLabel;
}

@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *itemDetailLabel;

@property (strong, nonatomic) IBOutlet UILabel *itemQuantityLabel;

@property (weak, nonatomic) IBOutlet UIButton *decrementButton;
@property (weak, nonatomic) IBOutlet UIButton *incrementButton;

@property (weak, nonatomic) IBOutlet UILabel *itemPriceLabel;


@end
