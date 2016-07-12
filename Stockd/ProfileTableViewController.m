//
//  ProfileTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "JGActionSheet.h"
#import "AppDelegate.h"
#import "UserAddressTableViewController.h"
#import "AddressViewController.h"

#define SOURCETYPE UIImagePickerControllerSourceTypeCamera


@interface ProfileTableViewController () <JGActionSheetDelegate> {
    JGActionSheet *_currentAnchoredActionSheet;
    UIView *_anchorView;
    BOOL _anchorLeft;
    JGActionSheet *_simple;
}

@property (nonatomic, strong) NSString *shareMessage;

@property (nonatomic, strong) AddressViewController *avc;



@end

@implementation ProfileTableViewController

#define iOS7 (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0)
#define iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@synthesize profilePicCell, addressCell, paymentCell, phoneCell, emailCell, inviteFriendsCell, logoutCell;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.circleView.backgroundColor = [UIColor clearColor];
    self.circleView.trackWidth = 13;
    self.circleView.progressWidth = 13;
    self.circleView.roundedCornersWidth = 13;
    self.circleView.trackColor = [UIColor colorWithRed:0.945 green:0.412 blue:0.612 alpha:1];
    self.circleView.progressColor = [UIColor colorWithRed:0.345 green:0.882 blue:0.761 alpha:1];
    self.circleView.labelVCBlock = ^(KAProgressLabel *label){
        //self.pLabel1.startLabel.text = [NSString stringWithFormat:@"%.f",self.pLabel1.progress*100];
    };
    self.circleView.isEndDegreeUserInteractive = NO;
    
    
    
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
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                            [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                                            shadow, NSShadowAttributeName,
                                                                                            [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    float limiter = 5.0f;
    int level = (int)floorf(([[[PFUser currentUser] objectForKey:@"karmaScore"] intValue])/limiter)+1;
    NSLog(@"Level: %d", level);
    
    self.levelLabel.text = [NSString stringWithFormat:@"Karma Level %d",level];
    
     [self selectAnimate:nil];
    [self getShareMessage];
    
    NSString *birthDate = [[PFUser currentUser] objectForKey:@"userDOB"];
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    int time = [todayDate timeIntervalSinceDate:[dateFormatter dateFromString:birthDate]];
    int allDays = (((time/60)/60)/24);
    //int days = allDays%365;
    //int years = (allDays-days)/365;
    
    NSLog(@"User BDAY: %@", birthDate);
    
    NSLog(@"Days: %d", allDays);
    
    if (allDays >= 7670) {
        NSLog(@"User is over 21");
    }
    else {
        
        NSLog(@"User is NOT 21");
    }
    
    
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

-(void)getShareMessage {
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        
        if (error) {
            
            [ProgressHUD showError:@"Network Error"];
        }
        else {
            [ProgressHUD dismiss];
            self.shareMessage = config[@"shareMessage"];
            NSLog(@"Yay! The message is %@!",self.shareMessage);
        }
    }];
}


-(void)viewWillAppear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    [self slideNavigationControllerShouldDisplayLeftMenu];
    [self slideNavigationControllerShouldDisplayRightMenu];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    
    //Nav Bar Color
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [_currentAnchoredActionSheet dismissAnimated:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == 0) return profilePicCell;
    if (indexPath.row == 1) return addressCell;
    if (indexPath.row == 2) return paymentCell;
    if (indexPath.row == 3) return phoneCell;
    if (indexPath.row == 4) return emailCell;
    if (indexPath.row == 5) return inviteFriendsCell;
    if (indexPath.row == 6) return logoutCell;
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 1) {
        
        AddressViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressVC"];
        
        destViewController.parent = self;
        NSLog(@"Tapped Address");
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Address Info"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
        NSLog(@"Here");
        [self.navigationController presentViewController:navigationController animated:YES completion:^{
            NSLog(@"Presenting");
        }];
        
        
    }
    
    if (indexPath.row == 2) {
        
        PaymentTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Payment"];
        destViewController.parent = self;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Payment Info"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{
        }];
    }
    
    if (indexPath.row == 3) {
        
        PhoneTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Phone"];
        destViewController.parent = self;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Contact Info"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{
        }];
    }

    if (indexPath.row == 4) {
        
        EmailTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Email"];
        destViewController.parent = self;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Email Info"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{
        }];
    }
    
    if (indexPath.row == 5) {
     
        [self inviteFriends];
    }
    
    if (indexPath.row == 6) {
        
        [self logout];
    }
}

- (IBAction)homeButtonTapped:(id)sender {
    
}


-(void)inviteFriends {
    
    
    NSArray *objectsToShare = @[self.shareMessage];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:^{
        
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                               fontWithName:@"BELLABOO-Regular" size:17], NSFontAttributeName,
                                    [UIColor blackColor], NSForegroundColorAttributeName, nil];
        
        
        [[UINavigationBar appearance] setTintColor:[UIColor blueColor]];
        [[UINavigationBar appearance] setTitleTextAttributes:attributes];
        
    }];
    
    [activityVC setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
        if (completed) {
            [self updateUserKarmaScore];
        }
    }];
}


-(void)updateUserKarmaScore {
    
    if ([[[PFUser currentUser] objectForKey:@"invitedFriends"] isEqualToString:@"YES"]) {
        //ALREADY SHARED
        NSLog(@"already shared");
    }
    else {
        //UPDATE SCORE
        NSLog(@"updated score!");
        [PFAnalytics trackEvent:@"SMSInviteSent"];
        [[PFUser currentUser] setObject:@"YES" forKey:@"invitedFriends"];
        [[PFUser currentUser] incrementKey:@"karmaScore" byAmount:[NSNumber numberWithInt:5]];
        [[PFUser currentUser] saveInBackground];
        
        NSNumber *score = [[PFUser currentUser] objectForKey:@"karmaScore"];
        
        if ([score intValue] >=5) {
            [[PFUser currentUser] incrementKey:@"karmaCash" byAmount:[NSNumber numberWithInt:10]];
            [[PFUser currentUser] saveInBackground];
        }
        
        [self performSelector:@selector(selectAnimate:) withObject:nil afterDelay:0.5];
    }
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    if (result == MessageComposeResultCancelled) {
        
        [PFAnalytics trackEvent:@"SMSInviteCancelled"];
        NSLog(@"Canceled");
        
        
    } else if (result == MessageComposeResultSent) {
        
        if ([[[PFUser currentUser] objectForKey:@"invitedFriends"] isEqualToString:@"YES"]) {
            NSLog(@"Already Shared");
        }
        else {
            NSLog(@"Update Score");
        [PFAnalytics trackEvent:@"SMSInviteSent"];
        [[PFUser currentUser] setObject:@"YES" forKey:@"invitedFriends"];
        [[PFUser currentUser] incrementKey:@"karmaScore" byAmount:[NSNumber numberWithInt:5]];
        [[PFUser currentUser] saveInBackground];
            
            NSNumber *score = [[PFUser currentUser] objectForKey:@"karmaScore"];
            
            if ([score intValue] >=5) {
                NSLog(@"HERERER");
                [[PFUser currentUser] incrementKey:@"karmaCash" byAmount:[NSNumber numberWithInt:10]];
                [[PFUser currentUser] saveInBackground];
            }
            
        [self performSelector:@selector(selectAnimate:) withObject:nil afterDelay:0.5];
            
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    [[SlideNavigationController sharedInstance] setEnableSwipeGesture:NO];
    
    if (!_simple) {
        
        _simple = [JGActionSheet actionSheetWithSections:@[[JGActionSheetSection sectionWithTitle:@"Add Profile Picture" message:@"" buttonTitles:@[@"Take Photo", @"Choose From Library"] buttonStyle:JGActionSheetButtonStyleDefault]]];
        _simple.delegate = self;
        _simple.insets = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
        [_simple setOutsidePressBlock:^(JGActionSheet *sheet) {
            [sheet dismissAnimated:YES];
            
            [[SlideNavigationController sharedInstance] setEnableSwipeGesture:YES];
            
        }];
        
        __unsafe_unretained typeof(self) weakSelf = self;
        
        [_simple setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *indexPath) {
            
            [[SlideNavigationController sharedInstance] setEnableSwipeGesture:YES];
            
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
    
    //UIControl *sender = [[UIControl alloc] init];
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


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
   
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    [[SlideNavigationController sharedInstance] setEnableSwipeGesture:YES];
}



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
    InitialViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InitialVC"];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];
    //navigationController.navigationBar.hidden = YES;
    [PFUser logOut];
    [self.navigationController pushViewController:destViewController animated:NO];
    [CATransaction commit];

}
- (IBAction)tappedProfilePic:(id)sender {
}

-(void)addressMessage {
    
    [TSMessage showNotificationInViewController:self.navigationController
                                          title:@"Success"
                                       subtitle:@"Saved Address Info"
                                          image:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:^{}
                                     atPosition:TSMessageNotificationPositionNavBarOverlay
                           canBeDismissedByUser:YES];
}

-(void)paymentMessage {
    
    [TSMessage showNotificationInViewController:self.navigationController
                                          title:@"Success"
                                       subtitle:@"Saved Payment Info"
                                          image:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:^{}
                                     atPosition:TSMessageNotificationPositionNavBarOverlay
                           canBeDismissedByUser:YES];
}

-(void)phoneMessage {
    
    [TSMessage showNotificationInViewController:self.navigationController
                                          title:@"Success"
                                       subtitle:@"Saved Phone Info"
                                          image:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:^{}
                                     atPosition:TSMessageNotificationPositionNavBarOverlay
                           canBeDismissedByUser:YES];
}

-(void)emailMessage {
    
    [TSMessage showNotificationInViewController:self.navigationController
                                          title:@"Success"
                                       subtitle:@"Saved Email Info"
                                          image:nil
                                           type:TSMessageNotificationTypeSuccess
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:^{}
                                     atPosition:TSMessageNotificationPositionNavBarOverlay
                           canBeDismissedByUser:YES];
}


- (IBAction)selectAnimate:(id)sender
{
 
    float limiter = 5.0f;
    int level = (int)floorf(([[[PFUser currentUser] objectForKey:@"karmaScore"] intValue])/limiter)+1;
    NSLog(@"Level: %d", level);
    self.levelLabel.text = [NSString stringWithFormat:@"Karma Level %d",level];
    
    
    self.circleView.progress = 0;
    int kar = [[[PFUser currentUser] objectForKey:@"karmaScore"] intValue];
    
    
    int karma = kar;
    float progress;
    if(karma>0){
        progress = (karma%5)/5.0f;
        
        if (progress == 0) {
            progress = 1;
        }
    } else {
        progress = 0;
    }
    
    [self.circleView setProgress:(progress) timing:TPPropertyAnimationTimingEaseInEaseOut duration:1 delay:.2];
}


-(IBAction) trackWidthSliderValueChanged:(UISlider *)sender {
    [self.circleView setTrackWidth:sender.value];
}

-(IBAction) progressWidthSliderValueChanged:(UISlider *)sender {
    [self.circleView setProgressWidth:sender.value];
}

-(IBAction)roundedCornersWidthSliderValueChanged:(UISlider *)sender {
    [self.circleView setRoundedCornersWidth:sender.value];
}



@end
