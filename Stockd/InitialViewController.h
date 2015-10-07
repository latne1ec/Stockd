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
#import "TourViewController.h"

@interface InitialViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
- (IBAction)facebookButtonTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *signupWithEmailButton;


@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UILabel *stockdLabel;
@property (weak, nonatomic) IBOutlet UILabel *stockdTitle;

@property (weak, nonatomic) IBOutlet UILabel *labelOne;
@property (weak, nonatomic) IBOutlet UILabel *labelTwo;

@property (weak, nonatomic) IBOutlet UIView *videoBkg;

@property (weak, nonatomic) IBOutlet UILabel *alreadyHaveAccountLabel;
@property (weak, nonatomic) IBOutlet UILabel *i4TitleLabel;




@end
