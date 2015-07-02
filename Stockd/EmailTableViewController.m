//
//  EmailTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "EmailTableViewController.h"

@interface EmailTableViewController ()

@end

@implementation EmailTableViewController

@synthesize firstCell, emailCell, emailTextfield;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailTextfield.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveButton:)];
    
    
    
    self.title = @"Email Info";

    
}

-(void)viewWillAppear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == 0) {
        self.emailTextfield.text = [[PFUser currentUser] objectForKey:@"email"];
        
    }
    return emailCell;
    
    return nil;
}


//*********************************************
// Save Phone Numbers To Parse

- (IBAction)saveButton:(id)sender {
    
    [ProgressHUD show:nil];
    NSString *email = self.emailTextfield.text;
    if ([email length ] < 10) {
        
        [ProgressHUD showError:@"Please enter a valid email"];
    }
    else {
        
        PFUser *user = [PFUser currentUser];
        [user setObject:email forKey:@"email"];
        [user setObject:email forKey:@"username"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (error) {
                [ProgressHUD showError:@"Network Error"];
                NSLog(@"Error: %@", error);
            }
            else {
                
                [self.tableView reloadData];
                [ProgressHUD showSuccess:@"Updated Email"];
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
    
    [self.emailTextfield resignFirstResponder];

}

@end
