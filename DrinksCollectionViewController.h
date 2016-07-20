//
//  DrinksCollectionViewController.h
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"
#import "TSMessage.h"

@interface DrinksCollectionViewController : UICollectionViewController <SlideNavigationControllerDelegate, TSMessageViewProtocol>

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu;
- (BOOL)slideNavigationControllerShouldDisplayRightMenu;

@end
