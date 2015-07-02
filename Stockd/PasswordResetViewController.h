//
//  PasswordResetViewController.h
//  Stockd
//
//  Created by Evan Latner on 6/29/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PasswordResetViewController : UITableViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;

@property (weak, nonatomic) IBOutlet UITableViewCell *resetCell;
@property (weak, nonatomic) IBOutlet UIButton *resetPasswordButton;
- (IBAction)resetPasswordTapped:(id)sender;
@end
