//
//  PackageCollectionViewCell.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-12.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *packageImageView;
@property (weak, nonatomic) IBOutlet UILabel *packageLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLabelConstraint;

@property (strong, nonatomic) CALayer *topBorder;
@property (strong, nonatomic) CALayer *bottomBorder;
@property (strong, nonatomic) CALayer *leftBorder;
@property (strong, nonatomic) CALayer *rightBorder;

@property Boolean isOnlyName;
@property Boolean showTopLine;
@property Boolean isLast;
@property Boolean isEven;

@end
