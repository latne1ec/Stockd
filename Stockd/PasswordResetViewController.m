//
//  PasswordResetViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/29/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "PasswordResetViewController.h"

@interface PasswordResetViewController ()

@end

@implementation PasswordResetViewController

@synthesize emailCell, emailTextfield, resetCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelPink"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    self.emailTextfield.delegate = self;
    
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [emailTextfield becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [emailTextfield resignFirstResponder];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) return emailCell;
    
    if (indexPath.row == 1) {
        resetCell.separatorInset = UIEdgeInsetsMake(0.f, 10000.0f, 0.f, 0.0f);
    }

    
    if (indexPath.row == 1) return resetCell;
    
    return nil;
}

- (IBAction)resetPasswordTapped:(id)sender {
    
    NSString *email = [self.emailTextfield.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
        if (error) {
            
            [TSMessage showNotificationWithTitle:@"" subtitle:@"Email address not found" type:TSMessageNotificationTypeError];
            
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Sent" message:@"A password reset link has been sent to your email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            CATransition *transition = [CATransition animation];
            [transition setType:kCATransitionFade];
            [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];
            InitialViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"InitialVC"];
            [self.navigationController pushViewController:ivc animated:NO];
            [CATransaction commit];
            
            
            
        }
        
    }];


    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField; {
    
    if([emailTextfield isFirstResponder]){
        [emailTextfield resignFirstResponder];
        [self resetPasswordTapped:self];
    }
    
    return YES;
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    [self dismissKeyboard];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)dismissKeyboard {
    
    [self.emailTextfield resignFirstResponder];
    
}



@end
