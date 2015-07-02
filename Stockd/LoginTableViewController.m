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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
       
}

-(void)viewWillAppear:(BOOL)animated {
    
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
    
}

- (void)keyboardWillShow:(NSNotification *)notification
{    
    UIEdgeInsets contentInsets;
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        contentInsets = UIEdgeInsetsMake(0.0, 0.0, (40), 0.0);
    }
    
    self.tableView.contentInset = contentInsets;
    //self.tableView.scrollIndicatorInsets = contentInsets;
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
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
        [TSMessage showNotificationWithTitle:nil
                                    subtitle:@"Please enter your password"
                                        type:TSMessageNotificationTypeError];
    }
    else {
        [ProgressHUD show:nil];
        [PFUser logInWithUsernameInBackground:email password:password block:^(PFUser *user, NSError *error) {
            if (error) {
                
                [ProgressHUD dismiss];
                if (error.userInfo.count >= 3) {
                    NSLog(@"Here");
                    if ([[error.userInfo objectForKey:@"error"] isEqualToString:@"invalid login parameters"]) {
                        [TSMessage showNotificationWithTitle:nil
                                                    subtitle:@"invalid username/password combination"
                                                        type:TSMessageNotificationTypeError];
                        
                    }
                    else {
                        [TSMessage showNotificationWithTitle:nil
                                                    subtitle:[error.userInfo objectForKey:@"error"]
                                                        type:TSMessageNotificationTypeError];
                    }
                    
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
                
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                CATransition *transition = [CATransition animation];
                [transition setType:kCATransitionFade];
                [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];

                
                [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
                [self.navigationController pushViewController:destViewController animated:NO];
                
                [CATransaction commit];

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
