//
//  FoodCollectionViewController.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-18.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "TSMessage.h"

@interface FoodCollectionViewController : UICollectionViewController <SlideNavigationControllerDelegate, TSMessageViewProtocol>
{
    NSString *tappedMenu;
}


@property(nonatomic,strong) NSString *tappedMenu;

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu;
- (BOOL)slideNavigationControllerShouldDisplayRightMenu;

@end
