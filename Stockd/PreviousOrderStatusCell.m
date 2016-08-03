//
//  PreviousOrderStatusCell.m
//  Stockd
//
//  Created by Evan Latner on 7/21/16.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "PreviousOrderStatusCell.h"

@implementation PreviousOrderStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) layoutSubviews{
    [super layoutSubviews];
    
    double bottomBorderWidth = 1.24;
    
    if (_bottomBorder == nil){
        _bottomBorder = [CALayer layer];
        _bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height - bottomBorderWidth, self.contentView.frame.size.width, bottomBorderWidth);
        _bottomBorder.backgroundColor = [[UIColor alloc] initWithRed:74.f/255.f green:230.f/255.f blue:175.f/255.f alpha:.5].CGColor;
        [self.contentView.layer addSublayer:_bottomBorder];
    }else{
        _bottomBorder.frame = CGRectMake(0.0f, self.contentView.frame.size.height - bottomBorderWidth, self.contentView.frame.size.width, bottomBorderWidth);
    }
}

@end
