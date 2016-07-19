//
//  ItemCollectionViewCell.m
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "ItemCollectionViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation ItemCollectionViewCell

-(void) layoutSubviews{
    [super layoutSubviews];
    
    self.contentView.clipsToBounds = NO;
    self.containerView.clipsToBounds = NO;
    self.clipsToBounds = NO;
    
    double bottomBorderWidth = 4.0;
    
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
    
    _itemQuantityLabel.layer.shadowRadius  = 1.5f;
    _itemQuantityLabel.layer.shadowColor   = [UIColor blackColor].CGColor;
    _itemQuantityLabel.layer.shadowOffset  = CGSizeMake(0.0f, 0.0f);
    _itemQuantityLabel.layer.shadowOpacity = 0.9f;
    _itemQuantityLabel.layer.masksToBounds = NO;
    
    
    _itemImageViewer.clipsToBounds = YES;
    [_itemImageViewer.layer setCornerRadius:5.0f];
    
    [_itemImageViewer sd_setImageWithURL:[NSURL URLWithString:_theImageURL]
                        placeholderImage:[UIImage imageNamed:@"whiteBkg@2x"]];
    
    /*NSString *theImageName = _packageLabel.text;
    
    if (!_isOnlyName){
        theImageName = [_packageLabel.text substringFromIndex:2];
    }
    
    _packageImageView.image = [UIImage imageNamed: theImageName];*/
}

@end
