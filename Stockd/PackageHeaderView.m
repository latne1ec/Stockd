//
//  PackageHeaderView.m
//  Stockd
//
//  Created by Alex Consel on 2016-07-16.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "PackageHeaderView.h"

@implementation PackageHeaderView

-(void)layoutSubviews{
    [super layoutSubviews];
    
    double bottomBorderWidth = 2.0;
    
    if (_bottomBorder == nil){
        _bottomBorder = [CALayer layer];
        _bottomBorder.frame = CGRectMake(0.0f, self.containerView.frame.size.height - bottomBorderWidth, self.containerView.frame.size.width, bottomBorderWidth);
        _bottomBorder.backgroundColor = [UIColor whiteColor].CGColor;
        [self.containerView.layer addSublayer:_bottomBorder];
    }else{
        _bottomBorder.frame = CGRectMake(0.0f, self.containerView.frame.size.height - bottomBorderWidth, self.containerView.frame.size.width, bottomBorderWidth);
    }
    
    if (_topBorder == nil){
        _topBorder = [CALayer layer];
        _topBorder.frame = CGRectMake(0.0f, 0, self.containerView.frame.size.width, bottomBorderWidth);
        _topBorder.backgroundColor = [UIColor whiteColor].CGColor;
        [self.containerView.layer addSublayer:_topBorder];
    }else{
        _topBorder.frame = CGRectMake(0.0f, 0, self.containerView.frame.size.width, bottomBorderWidth);
    }
}

@end
