//
//  InitialViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/29/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "InitialViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    CALayer *btn1 = [self.signupWithEmailButton layer];
    [btn1 setMasksToBounds:YES];
    [btn1 setCornerRadius:3.5f];
    [btn1 setBorderWidth:1.5f];
    [btn1 setBorderColor:[UIColor colorWithRed:0.737 green:0.298 blue:0.475 alpha:1].CGColor];
    
//    CALayer *btn2 = [self.loginButton layer];
//    [btn2 setMasksToBounds:YES];
//    [btn2 setCornerRadius:3.5f];
//    [btn2 setBorderWidth:1.5f];
//    [btn2 setBorderColor:[UIColor colorWithRed:0.941 green:0.353 blue:0.643 alpha:1].CGColor];
    
    if (![PFUser currentUser]) {
        
    }
    else {
        
        ProfileTableViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"];
        [self.navigationController pushViewController:pvc animated:NO];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationItem.hidesBackButton = YES;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [self.navigationController setNavigationBarHidden: YES animated:YES];

}



- (IBAction)facebookButtonTapped:(id)sender {
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:nil block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
        } else {
            NSLog(@"User logged in through Facebook!");
        }
    }];
    
}
@end
