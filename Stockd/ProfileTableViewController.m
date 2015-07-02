//
//  ProfileTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "JGActionSheet.h"
#define SOURCETYPE UIImagePickerControllerSourceTypeCamera


@interface ProfileTableViewController () <JGActionSheetDelegate> {
    JGActionSheet *_currentAnchoredActionSheet;
    UIView *_anchorView;
    BOOL _anchorLeft;
    JGActionSheet *_simple;
}


@end

@implementation ProfileTableViewController

#define iOS7 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)
#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@synthesize profilePicCell, addressCell, paymentCell, phoneCell, emailCell, logoutCell;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([PFUser currentUser]) {
        
    }
    else {
        
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];

        InitialViewController *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"InitialVC"];
        [self.navigationController pushViewController:tvc animated:NO];
        
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];

    }
    
    PFFile *profilePicture = [[PFUser currentUser] objectForKey:@"profilePic"];
    
    PFImageView *ImageView = (PFImageView*)self.profilePic;
    ImageView.image = [UIImage imageNamed:@"YapHolder"];
    ImageView.file = profilePicture;
    [ImageView loadInBackground];
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2;
    self.profilePic.clipsToBounds = YES;
    
    self.tableView.tableFooterView = [UIView new];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"initialBkg"]];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialBkg"]];
    [self.tableView setBackgroundView:imageView];
    

    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                             forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.layer.masksToBounds = YES;
    self.tableView.clipsToBounds = YES;
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    self.navigationController.navigationItem.hidesBackButton = YES;
    

    
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}



-(void)viewWillAppear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.navigationController.navigationItem.hidesBackButton = YES;

}

-(void)viewWillDisappear:(BOOL)animated {
    
    
    //Nav Bar Color
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"whiteBkg"] forBarMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.937 green:0.204 blue:0.733 alpha:1]];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == 0) return profilePicCell;
    if (indexPath.row == 1) return addressCell;
    if (indexPath.row == 2) return paymentCell;
    if (indexPath.row == 3) return phoneCell;
    if (indexPath.row == 4) return emailCell;
    if (indexPath.row == 5) return logoutCell;
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 1) {
        
        AddressTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Address"];
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Address Info"
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{
        }];
    }
    
    if (indexPath.row == 2) {
        
        PaymentTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Payment"];
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Payment Info"
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{
        }];
    }
    
    if (indexPath.row == 3) {
        
        PhoneTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Phone"];
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Contact Info"
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{
        }];
    }

    if (indexPath.row == 4) {
        
        EmailTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Email"];
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Email Info"
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{
        }];
    }
    
    if (indexPath.row == 5) {
        
        [self logout];
    }


}

- (IBAction)homeButtonTapped:(id)sender {
    
    
}

//*********************************************
// Log Out the Current User

- (void)logout {
    
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0] animated:NO];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log out" message:@"Are you sure you want to log out?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
    alertView.tag = 55;
    alertView.delegate = self;
}
//*********************************************





//*********************************************
// Actions Methods For Logout Button

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
    if (alertView.tag == 55) {
        
        if (buttonIndex == 0) {
            
        }
        else if (buttonIndex == 1) {
            
            [PFUser logOut];
            
            [self logoutButtonTapped:self];
            
        }
    }
}
//*********************************************


//*********************************************
// Present Action Sheet To Take Photo

- (IBAction)showActionSheet:(UIView *)anchor {
    
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
                    [weakSelf presentViewController:picker animated:YES completion:NULL];
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
                [weakSelf presentViewController:picker animated:YES completion:^{

                    [[UIApplication sharedApplication] setStatusBarHidden:NO];
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                    
                    picker.navigationBar.barTintColor = [UIColor colorWithRed:0.941 green:0.353 blue:0.663 alpha:1];
                    
 
                }];
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


//*********************************************
// User Finished Taking Photo

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIControl *sender = [[UIControl alloc] init];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    
    if (image.size.width > 140) image = ResizeImage2(image, 140, 140);
    
    PFFile *filePicture = [PFFile fileWithName:@"picture.png" data:UIImagePNGRepresentation(image)];
    [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        //if (error != nil) [ProgressHUD showError:@"Network error."];
    }];
    
    self.profilePic.image = image;
    
    PFUser *user = [PFUser currentUser];
    [user setObject:filePicture forKey:@"profilePic"];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error ) {
            
            [self.tableView reloadData];
            
        }
    }];
    
    [picker dismissViewControllerAnimated:NO completion:NULL];
}
//*********************************************





//*********************************************
// Resize the Image

UIImage* ResizeImage2(UIImage *image, CGFloat width, CGFloat height) {
    
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
//*********************************************







- (IBAction)logoutButtonTapped:(id)sender {
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];
    [PFUser logOut];
    //Nav Bar Color
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"whiteBkg"] forBarMetrics:UIBarMetricsDefault];

    InitialViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"InitialVC"];
    [self.navigationController pushViewController:ivc animated:NO];
    [CATransaction commit];

}
- (IBAction)tappedProfilePic:(id)sender {
}
@end
