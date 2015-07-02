//
//  SignupTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/29/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "SignupTableViewController.h"
#import "JGActionSheet.h"
#define SOURCETYPE UIImagePickerControllerSourceTypeCamera


@interface SignupTableViewController () <JGActionSheetDelegate> {
    JGActionSheet *_currentAnchoredActionSheet;
    UIView *_anchorView;
    BOOL _anchorLeft;
    JGActionSheet *_simple;
}

@end

@implementation SignupTableViewController

#define iOS7 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)
#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@synthesize profilePicCell, profilePic, nameCell, emailCell,phoneCell, passwordCell;
@synthesize nameField, emailField, phoneNumberField, passwordField;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Nav Bar Color
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    
    UIImage *image = [UIImage imageNamed:@"YapHolderTwo.png"];

    
    self.tableView.tableFooterView = [UIView new];
    
    PFFile *defaultPic = [PFFile fileWithName:@"picture.png" data:UIImagePNGRepresentation(image)];
    self.currentUser = [PFUser currentUser];
    
    [self.currentUser setObject:defaultPic forKey:@"profilePic"];
    [self.currentUser saveInBackground];
    self.selectedImage = image;
    self.filePicture = [PFFile fileWithName:@"picture.png" data:UIImagePNGRepresentation(self.selectedImage)];
    [self.filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (error != nil) [ProgressHUD showError:@"Network error"];
    }];

    
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    self.nameField.delegate = self;
    self.emailField.delegate = self;
    self.phoneNumberField.delegate = self;
    self.passwordField.delegate = self;
    
    CALayer *btn4 = [self.signupButton layer];
    [btn4 setMasksToBounds:YES];
    [btn4 setCornerRadius:3.5f];
    [btn4 setBorderWidth:1.0f];
    [btn4 setBorderColor:[UIColor colorWithRed:0.941 green:0.353 blue:0.643 alpha:1].CGColor];
        

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self dismissKeyboard];
}

-(void)viewWillAppear:(BOOL)animated {
    
    profilePic.layer.cornerRadius = profilePic.frame.size.width / 2;
    profilePic.clipsToBounds = YES;
    
    //[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}


- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [nameField resignFirstResponder];
    [emailField resignFirstResponder];
    [passwordField resignFirstResponder];
    
    [TSMessage dismissActiveNotification];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) return profilePicCell;
    if (indexPath.row == 1) return nameCell;
    if (indexPath.row == 2) return emailCell;
    if (indexPath.row == 3) return phoneCell;
    
    if (indexPath.row == 4) {
        passwordCell.separatorInset = UIEdgeInsetsMake(0.f, 10000.0f, 0.f, 0.0f);
    }
    
    if (indexPath.row == 4) return passwordCell;
    
    return nil;
}



//*********************************************
// Present Action Sheet To Take Photo

- (IBAction)showActionSheet:(UIView *)anchor {
    
    [self dismissKeyboard];
    
    if (!_simple) {
        
        _simple = [JGActionSheet actionSheetWithSections:@[[JGActionSheetSection sectionWithTitle:@"Add Profile Picture" message:@"" buttonTitles:@[@"Take Photo", @"Choose From Library"] buttonStyle:JGActionSheetButtonStyleDefault]]];
        _simple.delegate = self;
        _simple.insets = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
        [_simple setOutsidePressBlock:^(JGActionSheet *sheet) {
            [sheet dismissAnimated:YES];
            
        }];
        
        __unsafe_unretained typeof(self) weakSelf = self;
        
        [_simple setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
            
            if (indexPath.row == 0) {
                
                if ([UIImagePickerController isSourceTypeAvailable:SOURCETYPE]) {
                    
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = weakSelf;
                    picker.allowsEditing = YES;
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    [weakSelf presentViewController:picker animated:NO completion:NULL];
                    [sheet dismissAnimated:NO];
                    
                }
                else {
                    //Cannot Take Photo -- Capturing photo's is not supported
                    //[sheet dismissAnimated:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Camera Not Available" message:@"Choose a photo from your library instead." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                    
                }
                
            }
            if (indexPath.row == 1) {
                
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = weakSelf;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [weakSelf presentViewController:picker animated:YES completion:NULL];
                [sheet dismissAnimated:NO];
            }
        }];
    }
    
    if (anchor && iPad) {
        _anchorView = anchor;
        _anchorLeft = YES;
        _currentAnchoredActionSheet = _simple;
        CGPoint p = (CGPoint){-5.0f, CGRectGetMidY(anchor.bounds)};
        p = [self.navigationController.view convertPoint:p fromView:anchor];
        [_simple showFromPoint:p inView:[[UIApplication sharedApplication] keyWindow] arrowDirection:JGActionSheetArrowDirectionRight animated:YES];
    }
    else {
        [_simple showInView:self.navigationController.view animated:YES];
    }
}
//*********************************************


-(void)dismissKeyboard {
    
    [self.nameField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.phoneNumberField resignFirstResponder];
    [self.passwordField resignFirstResponder];

}

//*********************************************
// Take Picture Or Select Image From Library

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.selectedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (self.selectedImage.size.width > 140) self.selectedImage = ResizeImage(self.selectedImage, 140, 140);
    
    self.filePicture = [PFFile fileWithName:@"picture.png" data:UIImagePNGRepresentation(self.selectedImage)];
    [self.filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (error != nil) [ProgressHUD showError:@"Network error"];
    }];
    
    profilePic.image = self.selectedImage;
    
    if (self.selectedImage.size.width > 40) self.selectedImage = ResizeImage(self.selectedImage, 40, 40);
    
    self.fileThumbnail = [PFFile fileWithName:@"thumbnail.png" data:UIImagePNGRepresentation(self.selectedImage)];
    [self.fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:@"Network error"];
     }];
    
    [picker dismissViewControllerAnimated:NO completion:NULL];
    
}
//*********************************************





//*********************************************
// Resize the Image Properly

UIImage* ResizeImage(UIImage *image, CGFloat width, CGFloat height) {
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//*********************************************



//*********************************************
// Take Picture Canceled

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:NO completion:NULL];
}
//*********************************************



//*********************************************
// Keyboard Button Actions

-(BOOL)textFieldShouldReturn:(UITextField*)textField; {
    
    if([nameField isFirstResponder]){
        [emailField becomeFirstResponder];
                
    }
    else if ([emailField isFirstResponder]){
        [phoneNumberField becomeFirstResponder];
    }
    else if ([phoneNumberField isFirstResponder]){
        [passwordField becomeFirstResponder];
    }
    else if ([passwordField isFirstResponder]) {
        [passwordField resignFirstResponder];
        [self signup:self];
    }
    return YES;
}
//*********************************************


//*********************************************
// Format Phone Number As It's Entered

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([self.phoneNumberField isFirstResponder]) {
        
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray *components = [newString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [components componentsJoinedByString:@""];
    
    NSUInteger length = decimalString.length;
    BOOL hasLeadingOne = length > 0 && [decimalString characterAtIndex:0] == '1';
    
    if (length == 0 || (length > 10 && !hasLeadingOne) || (length > 11)) {
        textField.text = decimalString;
        return NO;
    }
    
    NSUInteger index = 0;
    NSMutableString *formattedString = [NSMutableString string];
    
    if (hasLeadingOne) {
        [formattedString appendString:@"1 "];
        index += 1;
    }
    if (length - index > 3) {
        NSString *areaCode = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"(%@) ",areaCode];
        index += 3;
    }
    if (length - index > 3) {
        NSString *prefix = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"%@-",prefix];
        index += 3;
    }
    
    NSString *remainder = [decimalString substringFromIndex:index];
    [formattedString appendString:remainder];
    
    textField.text = formattedString;
    
    return NO;
    }
    else {
        return YES;
    }
}
//*********************************************





//*********************************************
// Signup the Current User

- (IBAction)signup:(id)sender {
    
    NSString *name = [self.nameField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
     NSString *phone = [self.phoneNumberField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([name length] == 0) {
    
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:@"Please enter your name"
                                        type:TSMessageNotificationTypeError];
        
    }
    else if ([email length] == 0) {
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:@"Please enter your email"
                                        type:TSMessageNotificationTypeError];
    }
    else if ([phone length] < 10) {
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:@"Please enter a valid mobile number"
                                        type:TSMessageNotificationTypeError];
    }
    
    else if ([password length] == 0) {
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:@"Please enter a password"
                                        type:TSMessageNotificationTypeError];
    }
    
    
    else {
        
        [ProgressHUD show:nil Interaction:NO];
        PFUser *newUser = [PFUser user];
        newUser.username = email;
        newUser.password = password;
        newUser.email = email;
        
        [newUser setObject:name forKey:@"fullName"];
        [newUser setObject:self.filePicture forKey:@"profilePic"];
        [newUser setObject:phone forKey:@"mobileNumber"];
        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [ProgressHUD dismiss];
                
                if (error.userInfo.count >= 3) {
                    [TSMessage showNotificationWithTitle:nil
                                                subtitle:@"Something went wrong, try again"
                                                    type:TSMessageNotificationTypeError];
                    
                }
                else {
                    [TSMessage showNotificationWithTitle:nil
                                                subtitle:[error.userInfo objectForKey:@"error"]
                                                    type:TSMessageNotificationTypeError];
                }
            }
            else {
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                [currentInstallation saveInBackground];
                
               //Pop to Home View Controller
                
                [ProgressHUD dismiss];
                /////Pop To Main View Controller
                ProfileTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"];
                UINavigationController *navigationController =
                [[UINavigationController alloc] initWithRootViewController:destViewController];
                UIBarButtonItem *newBackButton =
                [[UIBarButtonItem alloc] initWithTitle:@""
                                                 style:UIBarButtonItemStyleBordered
                                                target:nil
                                                action:nil];
                [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
                [self.navigationController presentViewController:navigationController animated:YES completion:^{
                }];

            }
        }];
    }
}
//*********************************************

- (IBAction)addPhotoButtonTapped:(id)sender {
}
@end
