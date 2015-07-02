//
//  TourViewController.h
//  Stockd
//
//  Created by Carlos on 7/1/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InitialViewController.h"
#import "SlideNavigationController.h"

@interface TourViewController : UIViewController <UIScrollViewDelegate, SlideNavigationControllerDelegate>


- (BOOL)slideNavigationControllerShouldDisplayLeftMenu;
- (BOOL)slideNavigationControllerShouldDisplayRightMenu;


@end
