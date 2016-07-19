//
//  ConfirmationTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/8/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "ConfirmationTableViewController.h"
#import "ProfileTableViewController.h"
#import "InitialViewController.h"
#import "AppDelegate.h"
#import "AddPackagesCollectionViewController.h"

@interface ConfirmationTableViewController ()

@property (nonatomic, strong) NSString *shareMessage;
@property (nonatomic, strong) AppDelegate *appDelegate;



@end

@implementation ConfirmationTableViewController

@synthesize firstCell, secondCell, thirdCell, fourthCell;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    
    self.title = @"Stockd";
    
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
    
    CALayer *btn = [self.homeButton layer];
    [btn setMasksToBounds:YES];
    [btn setCornerRadius:5.0f];
    
    CALayer *btn2 = [self.inviteFriendsButton layer];
    [btn2 setMasksToBounds:YES];
    [btn2 setCornerRadius:5.0f];
    
    
    NSString *streetName = [[PFUser currentUser] objectForKey:@"streetName"];
    NSString *cityName = [[PFUser currentUser] objectForKey:@"userCity"];
    NSString *zipCode = [[PFUser currentUser] objectForKey:@"zipCode"];
    
    self.streetNameLabel.text = [[PFUser currentUser] objectForKey:@"address"];
    //self.cityStateZipLabel.text = [NSString stringWithFormat:@"%@, %@", cityName, zipCode];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"$%.02f", _subtotal];

    
    [self getShareMessage];
    
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
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.navigationItem setHidesBackButton:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem setHidesBackButton:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) return firstCell;
    if (indexPath.row == 1) return secondCell;
    if (indexPath.row == 2) return thirdCell;
    if (indexPath.row == 3) {
        fourthCell.separatorInset = UIEdgeInsetsMake(0.f, 10000.0f, 0.f, 0.0f);
    }
    
    if (indexPath.row == 3) return fourthCell;
    
    return nil;
}

- (IBAction)inviteFriendsTapped:(id)sender {
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText]) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            controller.body = self.shareMessage;
            controller.messageComposeDelegate = self;
            //[controller.navigationBar setTintColor:[UIColor blackColor]];
            [[controller navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
            
            [self presentViewController:controller animated:YES completion:^{
                
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                
            }];
        });
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
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)homeButtonTapped:(id)sender {
    
    if ([_appDelegate package_itemsDictionary] !=nil) {
        [[_appDelegate package_itemsDictionary] removeAllObjects];
    }
    
    if ([_appDelegate extraPackage_itemsDictionary] !=nil) {
        [[_appDelegate extraPackage_itemsDictionary] removeAllObjects];
    }

    AddPackagesCollectionViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddPackages"];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];
    
    [self.navigationController pushViewController:destViewController animated:NO];
    
    [CATransaction commit];
    
}
@end
