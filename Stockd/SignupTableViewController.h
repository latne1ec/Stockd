//
//  SignupTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 6/29/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TSMessageView.h"
#import "ProgressHUD.h"
#import "ProfileTableViewController.h"


@interface SignupTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, TSMessageViewProtocol>

@property (weak, nonatomic) IBOutlet UITableViewCell *profilePicCell;

@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (nonatomic, strong) PFUser *currentUser;
@property (weak, nonatomic) IBOutlet UITableViewCell *nameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *addressCell;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITableViewCell *phoneCell;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;

@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (nonatomic, strong) PFFile *filePicture;
@property (nonatomic, strong) PFFile *fileThumbnail;
@property (nonatomic, strong) UIImage *selectedImage;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;

@property (weak, nonatomic) IBOutlet UIButton *signupButton;



- (IBAction)addPhotoButtonTapped:(id)sender;

- (IBAction)showActionSheet:(id)sender;

- (IBAction)signup:(id)sender;

@end
