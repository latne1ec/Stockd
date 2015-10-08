//
//  AlcoholPolicyViewController.h
//  Stockd
//
//  Created by Evan Latner on 8/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlcoholPolicyViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *continueButton;

- (IBAction)continueButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *textview;

-(void)showPopup;



@end
