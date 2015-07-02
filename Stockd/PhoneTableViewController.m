//
//  PhoneTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "PhoneTableViewController.h"

@interface PhoneTableViewController ()

@end

@implementation PhoneTableViewController

@synthesize firstCell, mobileNumberCell, houseNumberCell, workNumberCell;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mobileTextfield.delegate = self;
    self.houseTextfield.delegate = self;
    self.workTextfield.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"saveButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(saveButton:)];

    self.tableView.tableFooterView = [UIView new];
    
    self.title = @"Phone Info";
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialBkg"]];
    [self.tableView setBackgroundView:imageView];
    
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.layer.masksToBounds = YES;
    self.tableView.clipsToBounds = YES;
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
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

    if (indexPath.row == 0) {
        
        NSString *mobileNumber = [[PFUser currentUser] objectForKey:@"mobileNumber"];
        if (mobileNumber == nil) {
            
        }
        else {
            
            if ([mobileNumber length] == 10) {
                
                self.mobileTextfield.text = [[PFUser currentUser] objectForKey:@"mobileNumber"];
                NSMutableString *stringts = [NSMutableString stringWithString:self.mobileTextfield.text];
                [stringts insertString:@"(" atIndex:0];
                [stringts insertString:@")" atIndex:4];
                [stringts insertString:@" " atIndex:5];
                [stringts insertString:@"-" atIndex:9];
                self.mobileTextfield.text = stringts;
            }
            else {
                self.mobileTextfield.text = mobileNumber;
            }
        }
        return mobileNumberCell;
        
        }

    if (indexPath.row == 1) {
        
        NSString *houseNumber = [[PFUser currentUser] objectForKey:@"houseNumber"];
        if (houseNumber == nil) {
            
        }
        else {
            
            if ([houseNumber length] == 10) {
                
                self.houseTextfield.text = [[PFUser currentUser] objectForKey:@"houseNumber"];
                NSMutableString *stringts = [NSMutableString stringWithString:self.houseTextfield.text];
                [stringts insertString:@"(" atIndex:0];
                [stringts insertString:@")" atIndex:4];
                [stringts insertString:@" " atIndex:5];
                [stringts insertString:@"-" atIndex:9];
                self.mobileTextfield.text = stringts;
            }
            else {
                self.houseTextfield.text = houseNumber;
            }
        }
        return houseNumberCell;
        
    }

    if (indexPath.row == 2) {
        
        NSString *workNumber = [[PFUser currentUser] objectForKey:@"workNumber"];
        if (workNumber == nil) {
            
        }
        else {
            
            if ([workNumber length] == 10) {
                
                self.workTextfield.text = [[PFUser currentUser] objectForKey:@"workNumber"];
                NSMutableString *stringts = [NSMutableString stringWithString:self.workTextfield.text];
                [stringts insertString:@"(" atIndex:0];
                [stringts insertString:@")" atIndex:4];
                [stringts insertString:@" " atIndex:5];
                [stringts insertString:@"-" atIndex:9];
                self.workTextfield.text = stringts;
            }
            else {
                self.workTextfield.text = workNumber;
            }
        }
        return workNumberCell;
        
    }

    return nil;
}


//*********************************************
// Format Phone Number As It's Entered

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray *components = [newString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [components componentsJoinedByString:@""];
    
    NSUInteger length = decimalString.length;
    BOOL hasLeadingOne = length > 0 && [decimalString characterAtIndex:0] == '1';
    
    if (length == 0 || (length > 10 && !hasLeadingOne) || (length > 11)) {
        textField.text = decimalString;
        return NO;
    }
    
    NSUInteger index = 0;
    NSMutableString *formattedString = [NSMutableString string];
    
    if (hasLeadingOne) {
        [formattedString appendString:@"1 "];
        index += 1;
    }
    if (length - index > 3) {
        NSString *areaCode = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"(%@) ",areaCode];
        index += 3;
    }
    if (length - index > 3) {
        NSString *prefix = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"%@-",prefix];
        index += 3;
    }
    
    NSString *remainder = [decimalString substringFromIndex:index];
    [formattedString appendString:remainder];
    
    textField.text = formattedString;
    
    return NO;
}
//*********************************************


//*********************************************
// Save Phone Numbers To Parse

- (IBAction)saveButton:(id)sender {
    
    [ProgressHUD show:nil];
    NSString *mobileNumber = [[self.mobileTextfield.text componentsSeparatedByCharactersInSet:
                              [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                             componentsJoinedByString:@""];
    NSString *houseNumber = [[self.houseTextfield.text componentsSeparatedByCharactersInSet:
                               [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                              componentsJoinedByString:@""];
    NSString *workNumber = [[self.workTextfield.text componentsSeparatedByCharactersInSet:
                              [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                             componentsJoinedByString:@""];
    
    if ([mobileNumber length ] < 10) {
        
        [ProgressHUD showError:@"Please enter a valid mobile phone number"];
        
    }
    
    else {
        
        PFUser *user = [PFUser currentUser];
        [user setObject:mobileNumber forKey:@"mobileNumber"];
        [user setObject:houseNumber forKey:@"houseNumber"];
        [user setObject:workNumber forKey:@"workNumber"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
           
            if (error) {
                
            }
            else {
                
                [self.tableView reloadData];
                [ProgressHUD showSuccess:@"Saved Phone Info"];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];                
            }
        }];
    }
}
//*********************************************

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    [self dismissKeyboard];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)dismissKeyboard {
    
    [self.mobileTextfield resignFirstResponder];
    [self.houseTextfield resignFirstResponder];
    [self.workTextfield resignFirstResponder];
    
}



@end
