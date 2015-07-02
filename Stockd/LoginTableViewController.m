//
//  LoginTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/29/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "LoginTableViewController.h"

@interface LoginTableViewController ()

@end

@implementation LoginTableViewController

@synthesize emailCell, passwordCell, emailTextfield, passwordTextfield, resetPasswordCell;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    
    self.tableView.tableFooterView = [UIView new];
    
    self.emailTextfield.delegate = self;
    self.passwordTextfield.delegate = self;
    
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    CALayer *btn4 = [self.loginButton layer];
    [btn4 setMasksToBounds:YES];
    [btn4 setCornerRadius:3.5f];
    [btn4 setBorderWidth:1.0f];
    [btn4 setBorderColor:[UIColor colorWithRed:0.941 green:0.353 blue:0.643 alpha:1].CGColor];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self dismissKeyboard];
}

-(void)dismissKeyboard {
    
    [self.emailTextfield resignFirstResponder];
    [self.passwordTextfield resignFirstResponder];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [emailTextfield becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [emailTextfield resignFirstResponder];
    [passwordTextfield resignFirstResponder];
    
    [TSMessage dismissActiveNotification];
    
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField; {
    
    if([emailTextfield isFirstResponder]){
        
        [passwordTextfield becomeFirstResponder];
    }
    else if ([passwordTextfield isFirstResponder]){
        
        [passwordTextfield resignFirstResponder];
        [self login:self];
    }
    
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) return emailCell;
    if (indexPath.row == 1) return passwordCell;
    
    if (indexPath.row == 2) {
        resetPasswordCell.separatorInset = UIEdgeInsetsMake(0.f, 10000.0f, 0.f, 0.0f);
    }
    
    if (indexPath.row == 2) return resetPasswordCell;
    
    return nil;
}

#pragma mark - Login

- (IBAction)login:(id)sender {
    
    NSString *email = [self.emailTextfield.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordTextfield.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([email length] == 0) {
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:@"Please enter your email"
                                        type:TSMessageNotificationTypeError];
        
    }
    else if ([password length] == 0) {
//        [TSMessage showNotificationWithTitle:nil
//                                    subtitle:@"Please enter your password"
//                                        type:TSMessageNotificationTypeError];
        [ProgressHUD showError:@"Please enter a password"];
    }
    else {
        [ProgressHUD show:nil];
        [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                
                [ProgressHUD dismiss];
                if (error.userInfo.count >= 3) {
                    [TSMessage showNotificationWithTitle:nil
                                                subtitle:@"something went wrong, try again"
                                                    type:TSMessageNotificationTypeError];
                    
                }
                else {
                    [TSMessage showNotificationWithTitle:nil
                                                subtitle:[error.userInfo objectForKey:@"error"]
                                                    type:TSMessageNotificationTypeError];
                }
            }
            else {
                [ProgressHUD dismiss];
                
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                [currentInstallation setObject:[PFUser currentUser] forKey:@"user"];
                [currentInstallation saveInBackground];
                
                /////Pop To Main View Controller
                ProfileTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"];
                UINavigationController *navigationController =
                [[UINavigationController alloc] initWithRootViewController:destViewController];
                UIBarButtonItem *newBackButton =
                [[UIBarButtonItem alloc] initWithTitle:@""
                                                 style:UIBarButtonItemStyleBordered
                                                target:nil
                                                action:nil];
                [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
                [self.navigationController presentViewController:navigationController animated:YES completion:^{
                }];

            }
        }];
    }
}



- (IBAction)forgotPasswordTapped:(id)sender {
    
    PasswordResetViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PasswordReset"];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:destViewController];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
    [self.navigationController presentViewController:navigationController animated:YES completion:^{
    }];

    
    
}

@end
