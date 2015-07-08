//
//  DrinksTableCell.h
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrinksTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *greenBkgView;

@property (weak, nonatomic) IBOutlet UILabel *packageNameLabel;

@end
