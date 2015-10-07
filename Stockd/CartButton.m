//
//  CartButton.m
//  Stockd
//
//  Created by Evan Latner on 7/25/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "CartButton.h"

@interface CartButton()

@property(nonatomic,strong) UILabel *label;

@end

@implementation CartButton


-(void)changeNumber:(int)number
{
    [UIView animateWithDuration:0.25 animations:^{
        
        if (number>0) {
            
        _label.transform = CGAffineTransformMakeScale(1.3, 1.3);
        _label.text = [NSString stringWithFormat:@"%d",number];
        }
        
    } completion:^(BOOL finished) {
        _label.transform = CGAffineTransformMakeScale(1.0, 1.0);
        
    }];
    
    if(number>0){
        _label.textColor = [UIColor whiteColor];
        _label.hidden = NO;
    } else {
        _label.textColor = [UIColor colorWithWhite:1.0 alpha:1.3f];
        _label.hidden = YES;
    }
}

-(void)load{
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 54/2.0f, 51/2.0f)];
    img.image = [UIImage imageNamed:@"cartIconYo"];
    img.backgroundColor = [UIColor clearColor];
    [self addSubview:img];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(-15, -5, 25, 25)];
    _label.text = @"0";
    _label.font = [UIFont boldSystemFontOfSize:12.0f];
    _label.textColor = [UIColor colorWithWhite:1.0 alpha:1.3f];
    _label.textAlignment = NSTextAlignmentCenter;
    _label.layer.cornerRadius = _label.frame.size.height/2.0f;
    _label.layer.masksToBounds = YES;
        _label.backgroundColor = [UIColor redColor];
    [self addSubview:_label];
    _label.hidden = YES;
}

@end
