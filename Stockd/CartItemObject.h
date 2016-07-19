//
//  CartItemObject.h
//  Stockd
//
//  Created by Alex Consel on 2015-10-08.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CartItemObject : NSObject

//@property (nonatomic, strong) NSString *itemID;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSString *itemDetail;
@property int itemQuantity;
@property float itemPrice;
@property Boolean hasBeenModified;
@property NSString* imageURLString;

-(id) initItem: (NSString*)name_ detail:(NSString*)detail_ quantity:(int)quantity_ price:(float)price_ imageURLString:(NSString*)imageURLString_;

-(void)increaseQuantity;
-(void)decreaseQuantity;
-(void) resetQuantity:(int) newQuantity;

@end
