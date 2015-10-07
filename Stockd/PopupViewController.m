//
//  PopupViewController.m
//  Stockd
//
//  Created by Evan Latner on 8/19/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "PopupViewController.h"
#import "UIViewController+ENPopUp.h"
#import "AlcoholPolicyViewController.h"
#import "ProgressHUD.h"

@interface PopupViewController ()

@property (nonatomic) int this;


@end

@implementation PopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _this = 1;
    
    
    self.monthTextField.delegate = self;
    self.dayTextField.delegate = self;
    self.yearTextField.delegate = self;
    
    UIColor *white = [UIColor colorWithWhite:1.0 alpha:1.0];
    
    [self.monthTextField setValue:white forKeyPath:@"_placeholderLabel.textColor"];
    [self.dayTextField setValue:white forKeyPath:@"_placeholderLabel.textColor"];
    [self.yearTextField setValue:white forKeyPath:@"_placeholderLabel.textColor"];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.submitButton.enabled = NO;
    [self.submitButton setTintColor:[UIColor lightGrayColor]];
    
    
    //[self.monthTextField becomeFirstResponder];
}

- (IBAction)submitButtonTapped:(id)sender {
    
 
   if (self.monthTextField.text.length < 1) {
       
       [self showAlert];
       
   }
   else if (self.dayTextField.text.length < 1) {
       
       [self showAlert];
   }
    
   else if (self.yearTextField.text.length < 4) {
       
       [self showAlert];
   }
    
   else {
       
    NSString *DOB = [NSString stringWithFormat:@"%@/%@/%@", self.monthTextField.text,self.dayTextField.text,self.yearTextField.text];
       [ProgressHUD show:nil];
    [[PFUser currentUser] setObject:DOB forKey:@"userDOB"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
        if (error) {
            
            [ProgressHUD showError:@"Network Error"];
            
        }
        else {
            [ProgressHUD dismiss];
            [self.monthTextField resignFirstResponder];
            [self.dayTextField resignFirstResponder];
            [self.yearTextField resignFirstResponder];
            
            [self dismissPopUpViewController];
        }
    }];
   }
}

-(void)showAlert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter a valid date of birth." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([self.monthTextField isFirstResponder]) {
        
        if([string length]>0){
            if([textField.text length]>1) {
                [self.dayTextField becomeFirstResponder];
                [self.dayTextField setText:string];
                return NO;
            }
        }
    }

    if ([self.dayTextField isFirstResponder]) {
        
        if([string length]>0){
            if([textField.text length]>1 && [string characterAtIndex:0]!=5){
                
                [self.yearTextField becomeFirstResponder];
                [self.yearTextField setText:string];
                return NO;
            }
        }
    }
    
    if ([self.yearTextField isFirstResponder]) {
        
        if (self.yearTextField.text.length > 2) {
        

            [self.submitButton setEnabled:YES];
            
            _this = 100;
            
            [self.submitButton setTintColor:[UIColor whiteColor]];
            
        }
        
        if([string length]>0){
            if([textField.text length]>3){
                
                [self.submitButton setEnabled:YES];
                
                _this = 100;
                
                [self.submitButton setTintColor:[UIColor whiteColor]];

                return NO;
            }
        }
    }
    
    return YES;
}


- (UIView*)topView {
    UIViewController *recentView = self;
    while (recentView.parentViewController != nil) {
        recentView = recentView.parentViewController;
    }
    return recentView.view;
}


- (IBAction)fallBackButtonTapped:(id)sender {
    
    NSLog(@"Tapped");
    
    if (_this == 1) {
        
        NSLog(@"SHOWING ALERT");
        
        [self showAlert];
        
    }
}
@end
