//
//  InitialViewController.h
//  Stockd
//
//  Created by Evan Latner on 6/29/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "ProfileTableViewController.h"


@interface InitialViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
- (IBAction)facebookButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *signupWithEmailButton;


@property (weak, nonatomic) IBOutlet UIButton *loginButton;


@end
