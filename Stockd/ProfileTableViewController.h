//
//  ProfileTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "InitialViewController.h"
#import "AddressTableViewController.h"
#import "PaymentTableViewController.h"
#import "PhoneTableViewController.h"
#import "EmailTableViewController.h"
#import "SlideNavigationController.h"
#import "TSMessage.h"
#import "KAProgressLabel.h"
#import "MessageUI/MessageUI.h"





@interface ProfileTableViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SlideNavigationControllerDelegate, TSMessageViewProtocol, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *profilePicCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *addressCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paymentCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *inviteFriendsCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;

@property (weak, nonatomic) IBOutlet KAProgressLabel *circleView;


- (IBAction)tappedProfilePic:(id)sender;

- (IBAction)showActionSheet:(id)sender;

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu;
- (BOOL)slideNavigationControllerShouldDisplayRightMenu;

-(void)addressMessage;
-(void)paymentMessage;
-(void)phoneMessage;
-(void)emailMessage;



@end
