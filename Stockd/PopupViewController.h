//
//  PopupViewController.h
//  Stockd
//
//  Created by Evan Latner on 8/19/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface PopupViewController : UIViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *monthTextField;

@property (weak, nonatomic) IBOutlet UITextField *dayTextField;

@property (weak, nonatomic) IBOutlet UITextField *yearTextField;

- (IBAction)submitButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (weak, nonatomic) IBOutlet UIButton *fallbackButton;

- (IBAction)fallBackButtonTapped:(id)sender;


@end
