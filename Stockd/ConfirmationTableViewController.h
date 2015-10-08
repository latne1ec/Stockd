//
//  ConfirmationTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 7/8/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MessageUI/MessageUI.h"


@interface ConfirmationTableViewController : UITableViewController <MFMessageComposeViewControllerDelegate>



@property (weak, nonatomic) IBOutlet UITableViewCell *firstCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *secondCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *thirdCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *fourthCell;
@property (nonatomic) float subtotal;
@property (weak, nonatomic) IBOutlet UILabel *streetNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateZipLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteFriendsButton;

- (IBAction)inviteFriendsTapped:(id)sender;

- (IBAction)homeButtonTapped:(id)sender;

@end
