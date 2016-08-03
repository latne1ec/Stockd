//
//  OrderOneTableViewCell.m
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "OrderOneTableViewCell.h"

@implementation OrderOneTableViewCell

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
    
    _orderButton.layer.cornerRadius = 5;
    _orderButton.clipsToBounds = true;
    
    double bottomBorderWidth = 1.4;
    
    if (_bottomBorder == nil){
        _bottomBorder = [CALayer layer];
        _bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height - bottomBorderWidth, self.contentView.frame.size.width, bottomBorderWidth);
        _bottomBorder.backgroundColor = [[UIColor alloc] initWithRed:74.f/255.f green:230.f/255.f blue:175.f/255.f alpha:.6].CGColor;
        [self.contentView.layer addSublayer:_bottomBorder];
    }else{
        _bottomBorder.frame = CGRectMake(0.0f, self.contentView.frame.size.height - bottomBorderWidth, self.contentView.frame.size.width, bottomBorderWidth);
    }
}

@end
