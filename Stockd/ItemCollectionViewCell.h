//
//  ItemCollectionViewCell.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageViewer;
@property (weak, nonatomic) IBOutlet UILabel *itemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *incrementButton;
@property (weak, nonatomic) IBOutlet UIButton *decrementButton;
@property (weak, nonatomic) IBOutlet UILabel *itemQuantityLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLabelConstraint;

@property (strong, nonatomic) CALayer *topBorder;
@property (strong, nonatomic) CALayer *bottomBorder;
@property (strong, nonatomic) CALayer *leftBorder;
@property (strong, nonatomic) CALayer *rightBorder;

@property NSString* theImageURL;

@property Boolean showTopLine;
@property Boolean isLast;
@property Boolean isEven;

@end
