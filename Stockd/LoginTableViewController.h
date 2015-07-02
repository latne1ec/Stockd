//
//  LoginTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 6/29/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgressHUD.h"
#import <Parse/Parse.h>
#import "TSMessageView.h"
#import "PasswordResetViewController.h"
#import "ProfileTableViewController.h"



@interface LoginTableViewController : UITableViewController <UITextFieldDelegate, TSMessageViewProtocol>

@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UITableViewCell *resetPasswordCell;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
- (IBAction)forgotPasswordTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)login:(id)sender;


@end
