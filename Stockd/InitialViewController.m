//
//  InitialViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/29/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "InitialViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ProfileTableViewController.h"
#import "AddPackagesCollectionViewController.h"



@interface InitialViewController ()

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) AVPlayerItem *avPlayerItem;
@property (nonatomic, strong) AVAsset *avAsset;

@property (nonatomic) int fbLogin;



@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _fbLogin = 0;
    
    if([UIScreen mainScreen].bounds.size.height < 568.0) {
        NSLog(@"iPhone 4");
        self.i4TitleLabel.hidden = NO;
                
    }
    
    CALayer *btn1 = [self.signupWithEmailButton layer];
    [btn1 setMasksToBounds:YES];
    [btn1 setCornerRadius:3.5f];
    [btn1 setBorderWidth:1.5f];
    //[btn1 setBorderColor:[UIColor colorWithRed:0.937 green:0.204 blue:0.733 alpha:1].CGColor];
    [btn1 setBorderColor:[UIColor whiteColor].CGColor];
        
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"hasRanApp"] isEqualToString:@"yes"]) {
        
        if ([PFUser currentUser]) {
            ProfileTableViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"];
            [self.navigationController pushViewController:pvc animated:NO];
            //Nav Bar Back Button Color
            [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
            
            NSLog(@"Yoooo");
        }
        else {
            
        }
        
    }
    else {
        TourViewController *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Tour"];
        [self.navigationController pushViewController:tvc animated:NO];
    }
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"whiteBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    //self.stockdLabel.textColor = [UIColor colorWithRed:0.937 green:0.204 blue:0.733 alpha:1];
    self.stockdLabel.textColor = [UIColor whiteColor];
    
  
//NSURL *url=[[NSURL alloc] initWithString:@"https://s3-us-west-2.amazonaws.com/storiesbucket/photos/4DC0A1C1-69BE-4FD6-A1EF-C25357B67DCA.mp4"];

    
//    AVAsset *asset = [AVAsset assetWithURL:url];
//    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
//    self.avPlayer = [AVPlayer playerWithPlayerItem:playerItem];
//    AVPlayerLayer *avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
//    
//    avPlayerLayer.frame = self.view.bounds;
//    [self.videoBkg.layer addSublayer:avPlayerLayer];
//    [self.view addSubview:self.videoBkg];
//    //[avPlayer play];
//    [self.avPlayer setMuted:YES];
//    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:self.avPlayerItem];
//    
//    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
//    

    
//    
//    [self.videoBkg addSubview:self.loginButton];
//    [self.videoBkg addSubview:self.facebookButton];
//    [self.videoBkg addSubview:self.signupWithEmailButton];
//    [self.videoBkg addSubview:self.alreadyHaveAccountLabel];
//    [self.videoBkg addSubview:self.stockdLabel];
//    [self.videoBkg addSubview:self.labelOne];
//    [self.videoBkg addSubview:self.labelTwo];
//    
//    self.view.alpha = 0.0;
//    
//    [UIView animateWithDuration:2.0
//                     animations:^{
//                        
//                         self.view.alpha = 0;
//                     }
//                     completion:^(BOOL finished){
//                         [UIView animateWithDuration:1.0
//                                          animations:^{
//                                              self.view.alpha = 1.0;
//                                          }
//                                          completion:^(BOOL finished){
//                                            
//                                          }];
//                     }];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}


-(void)viewWillAppear:(BOOL)animated {
    
    [self.avPlayer play];
    
    self.navigationController.navigationItem.hidesBackButton = YES;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [self.navigationController setNavigationBarHidden: YES animated:YES];
    [self.view addSubview:self.videoBkg];
    
    self.videoBkg.bounds = CGRectZero;
}

-(void)viewDidAppear:(BOOL)animated {
   
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    if (_fbLogin == 0) {
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.937 green:0.204 blue:0.733 alpha:1]];
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor colorWithRed:0.937 green:0.204 blue:0.733 alpha:1], NSForegroundColorAttributeName,
                                                                     shadow, NSShadowAttributeName,
                                                                     [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
        
    }
    else {
        NSLog(@"FACEBOOK LOGIN");
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                               fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName,
                                    [UIColor whiteColor], NSForegroundColorAttributeName, nil];
        [self.navigationController.navigationBar setTitleTextAttributes:attributes];
        self.navigationController.navigationBarHidden = NO;
    }
    
}


- (IBAction)facebookButtonTapped:(id)sender {
    
    NSArray *permissionsArray = @[ @"email"];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            
            [ProgressHUD show:nil Interaction:NO];
            NSLog(@"User signed up and logged in through Facebook!Here :%@", user);
            
            [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
             startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 
                 if (!error) {

                     NSString *newString = [result objectForKey:@"id"];
                     
                     NSString *picUrl = [NSString stringWithFormat:@"https://graph.facebook.com/\%@/picture?type=large&return_ssl_resources=1", newString];
                     
                     UIImage *profilePic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:picUrl]]];
                     PFFile *pic = [PFFile fileWithName:@"picture.png" data:UIImagePNGRepresentation(profilePic)];

                     _fbLogin = 5;
                     
                     NSLog(@"fetched user:%@  and Email : %@", result,result[@"email"]);
                     //UIImage *image = [UIImage imageNamed:@"addPhotoPink"];
                     [[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"fullName"];
                     [[PFUser currentUser] setObject:[result objectForKey:@"email"] forKey:@"username"];
                     [[PFUser currentUser] setObject:[result objectForKey:@"email"] forKey:@"email"];
                     //PFFile *defaultPic = [PFFile fileWithName:@"picture.png" data:UIImagePNGRepresentation(image)];
                     [[PFUser currentUser] setObject:pic forKey:@"profilePic"];
                     [[PFUser currentUser] saveInBackground];
                     [self pushToCamera];
                 }
             }];
            
        } else {
            [ProgressHUD show:nil Interaction:NO];
            _fbLogin = 5;
            NSLog(@"User logged in through Facebook! Email");
            [self pushToCamera];
           
        }
    }];
}

-(void)pushToCamera {

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
    [currentInstallation saveInBackground];
    
    /////Pop To Main View Controller

    AddPackagesCollectionViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddPackages"];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:destViewController];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];
    
    
    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
    [self.navigationController pushViewController:destViewController animated:NO];
    
    [CATransaction commit];

       [ProgressHUD dismiss];
}


@end
