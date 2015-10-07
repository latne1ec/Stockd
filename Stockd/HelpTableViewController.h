//
//  HelpTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 7/2/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TourViewController.h"
#import "SlideNavigationController.h"
#import <MessageUI/MessageUI.h>
#import "TSMessage.h"




@interface HelpTableViewController : UITableViewController <SlideNavigationControllerDelegate, MFMailComposeViewControllerDelegate, TSMessageViewProtocol>


@property (weak, nonatomic) IBOutlet UITableViewCell *firstCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *secondCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *thirdCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *fourthCell;



- (BOOL)slideNavigationControllerShouldDisplayLeftMenu;
- (BOOL)slideNavigationControllerShouldDisplayRightMenu;


@end
