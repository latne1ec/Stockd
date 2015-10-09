//
//  CartItemObject.m
//  Stockd
//
//  Created by Alex Consel on 2015-10-08.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "CartItemObject.h"

@implementation CartItemObject

-(id) initItem: (NSString*)name_ detail:(NSString*)detail_ quantity:(int)quantity_ price:(float)price_{
    if (self = [super init]){
        _itemName = name_;
        _itemDetail = detail_;
        _itemQuantity = quantity_;
        _itemPrice = price_;
    }
    return self;
}

-(void)increaseQuantity{
    _itemQuantity++;
}

-(void)decreaseQuantity{
    if (_itemQuantity > 0){
        _itemQuantity--;
    }
}

@end
