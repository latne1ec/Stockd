//
//  PackageCollectionViewCell.m
//  Stockd
//
//  Created by Alex Consel on 2016-07-12.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "PackageCollectionViewCell.h"

@implementation PackageCollectionViewCell

-(void) layoutSubviews{
    [super layoutSubviews];
    
    self.contentView.clipsToBounds = NO;
    self.containerView.clipsToBounds = NO;
    self.clipsToBounds = NO;
    
    double bottomBorderWidth = 2.0;
    
    _bottomLabelConstraint.constant = bottomBorderWidth+5;
    
    //Bottom border
    if (!_isLast){
        if (_bottomBorder == nil){
            _bottomBorder = [CALayer layer];
            _bottomBorder.frame = CGRectMake(0.0f, self.containerView.frame.size.height - bottomBorderWidth, self.containerView.frame.size.width, bottomBorderWidth);
            _bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
            [self.containerView.layer addSublayer:_bottomBorder];
        }else{
            _bottomBorder.frame = CGRectMake(0.0f, self.containerView.frame.size.height - bottomBorderWidth, self.containerView.frame.size.width, bottomBorderWidth);
        }
    }else{
        [_bottomBorder removeFromSuperlayer];
        _bottomBorder = nil;
    }
    
    if (_showTopLine){
        if (_topBorder == nil){
            _topBorder = [CALayer layer];
            _topBorder.frame = CGRectMake(0.0f, 0.0f, self.containerView.frame.size.width, bottomBorderWidth);
            _topBorder.backgroundColor = [UIColor whiteColor].CGColor;
            [self.containerView.layer addSublayer:_topBorder];
        }else{
            _topBorder.frame = CGRectMake(0.0f, 0.0f, self.containerView.frame.size.width, bottomBorderWidth);
        }
    }else{
        [_topBorder removeFromSuperlayer];
        _topBorder = nil;
    }
    
    //right border
    if (_isEven){
        if (_rightBorder == nil){
            _rightBorder = [CALayer layer];
            _rightBorder.frame = CGRectMake(self.containerView.frame.size.width-bottomBorderWidth/2, 0, bottomBorderWidth, self.containerView.frame.size.height);
            _rightBorder.backgroundColor = [UIColor whiteColor].CGColor;
            [self.containerView.layer addSublayer:_rightBorder];
        }else{
            _rightBorder.frame = CGRectMake(self.containerView.frame.size.width-bottomBorderWidth/2, 0, bottomBorderWidth, self.containerView.frame.size.height);
        }
    }else{
        [_rightBorder removeFromSuperlayer];
        _rightBorder = nil;
    }
    
    NSString *theImageName = _packageLabel.text;
    
    if (!_isOnlyName){
        theImageName = [_packageLabel.text substringFromIndex:2];
    }
    
    _packageImageView.image = [UIImage imageNamed: theImageName];
}

@end
