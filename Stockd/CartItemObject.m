//
//  CartItemObject.m
//  Stockd
//
//  Created by Alex Consel on 2015-10-08.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "CartItemObject.h"
#import "AppDelegate.h"

@implementation CartItemObject

-(id) initItem: (NSString*)name_ detail:(NSString*)detail_ quantity:(int)quantity_ price:(float)price_ imageURLString:(NSString*)imageURLString_{
    if (self = [super init]){
        _itemName = name_;
        _itemDetail = detail_;
        _itemQuantity = quantity_;
        _itemPrice = price_;
        _imageURLString = imageURLString_;
        _hasBeenModified = false;
    }
    return self;
}

-(void)increaseQuantity{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    _itemQuantity++;
    if (_itemQuantity == appDelegate.packageSize){
        _hasBeenModified = false;
    }else{
        _hasBeenModified = true;
    }
    
}

-(void)decreaseQuantity{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (_itemQuantity > 0){
        _itemQuantity--;
        _hasBeenModified = true;
    }
    
    if (_itemQuantity == appDelegate.packageSize){
        _hasBeenModified = false;
    }else{
        _hasBeenModified = true;
    }
}

-(void) resetQuantity:(int) newQuantity{
    _itemQuantity = newQuantity;
    _hasBeenModified = false;
}

@end
