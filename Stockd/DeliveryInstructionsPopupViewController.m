//
//  DeliveryInstructionsPopupViewController.m
//  Stockd
//
//  Created by Evan Latner on 2/22/16.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "DeliveryInstructionsPopupViewController.h"
#import "CartTableViewController.h"

@interface DeliveryInstructionsPopupViewController ()

@end

@implementation DeliveryInstructionsPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.instructionsTextField.delegate = self;
    self.instructionsTextField.layer.cornerRadius = 4;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"currentDeliveryInstructions"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSString *instruct = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDeliveryInstructions"];
    
    NSLog(@"view did load instruct: %@", instruct);
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    
    self.instructionsTextField.text = @"";
}

- (UIView*)topView {
    UIViewController *recentView = self;
    while (recentView.parentViewController != nil) {
        recentView = recentView.parentViewController;
    }
    return recentView.view;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    if ([self.instructionsTextField.text containsString:@"Add any special delivery"]) {
        
    } else {
        
        [[NSUserDefaults standardUserDefaults] setObject:self.instructionsTextField.text forKey:@"currentDeliveryInstructions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString *instruct = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDeliveryInstructions"];
        
        NSLog(@"instruct: %@", instruct);
   
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasShownDeliveryInstructions"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (IBAction)fallBackButtonTapped:(id)sender {
        
}

@end
