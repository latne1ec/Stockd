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


@interface ProfileTableViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *profilePicCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *addressCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *paymentCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;

@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;

- (IBAction)tappedProfilePic:(id)sender;

- (IBAction)showActionSheet:(id)sender;



@end
