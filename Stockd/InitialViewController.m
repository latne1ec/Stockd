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
    
    //Nav Bar Color
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.937 green:0.204 blue:0.733 alpha:1]];
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor colorWithRed:0.937 green:0.204 blue:0.733 alpha:1], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
//                                                  forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = [UIImage new];
//    self.navigationController.navigationBar.translucent = NO;
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationItem.hidesBackButton = YES;
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [self.navigationController setNavigationBarHidden: YES animated:YES];
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];


}

-(void)viewWillDisappear:(BOOL)animated {
    
    
    //Nav Bar Color
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    //[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.937 green:0.204 blue:0.733 alpha:1]];
    
    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setTranslucent:NO];
    
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
