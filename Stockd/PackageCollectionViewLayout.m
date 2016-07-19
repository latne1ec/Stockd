//
//  PackageCollectionViewLayout.m
//  Stockd
//
//  Created by Alex Consel on 2016-07-15.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "PackageCollectionViewLayout.h"

@implementation PackageCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.minimumLineSpacing = 0.0;
        self.minimumInteritemSpacing = 0.0;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
}

- (CGSize)itemSize
{
    NSInteger numberOfColumns = 2;
    
    CGFloat itemWidth = (CGRectGetWidth(self.collectionView.frame))/ numberOfColumns;
    
    if (_isEdit){
        return CGSizeMake(itemWidth, itemWidth/1.1);
    }else{
        return CGSizeMake(itemWidth, itemWidth/1.5);
    }
}

@end
