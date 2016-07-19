//
//  PackageHeaderView.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-16.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageHeaderView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) CALayer *topBorder;
@property (strong, nonatomic) CALayer *bottomBorder;

@end
