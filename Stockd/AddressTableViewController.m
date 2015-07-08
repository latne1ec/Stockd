//
//  AddressTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "AddressTableViewController.h"
#import "ProfileTableViewController.h"

@interface AddressTableViewController ()

@end

@implementation AddressTableViewController

@synthesize firstCell, streetCell, apartmentDormCell, zipcodeCell, instructionsCell, parent;
@synthesize streetTextfield, apartmentDormTextField, zipTextfield, instructionsTextfield;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"saveButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(saveButton:)];
    
    

    
    
    
    self.streetTextfield.delegate = self;
    self.apartmentDormTextField.delegate = self;
    self.zipTextfield.delegate = self;
    self.instructionsTextfield.delegate = self;
    
    self.title = @"Address Info";
    
    self.instructionsTextfield.text = @"";
    
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
    
    if ([[PFUser currentUser] objectForKey:@"deliveryInstructions"] == nil) {
        self.instructionsPlaceholder.hidden = NO;
    }
    else {
        self.instructionsPlaceholder.hidden = YES;
    }
    
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [ProgressHUD dismiss];
}

//*********************************************
// Keyboard Button Actions

-(BOOL)textFieldShouldReturn:(UITextField*)textField; {
    
    if([streetTextfield isFirstResponder]){
        [apartmentDormTextField becomeFirstResponder];
        
    }
    else if ([apartmentDormTextField isFirstResponder]){
        [zipTextfield becomeFirstResponder];
    }
    else if ([zipTextfield isFirstResponder]){
        [instructionsTextfield becomeFirstResponder];
    }
    else if ([instructionsTextfield isFirstResponder]) {
        [instructionsTextfield resignFirstResponder];
        [self saveButton:self];
    }
    return YES;
}
//*********************************************




//*********************************************
// Custom Placeholder

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    self.instructionsPlaceholder.hidden = YES;
    
}

- (void)textViewDidChange:(UITextView *)txtView {
    self.instructionsPlaceholder.hidden = ([txtView.text length] > 0);
    
}

- (void)textViewDidEndEditing:(UITextView *)txtView {
    self.instructionsPlaceholder.hidden = ([txtView.text length] > 0);
    
}

//*********************************************






#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    
    if (indexPath.row == 0) {
        
        NSString *streetName = [[PFUser currentUser] objectForKey:@"streetName"];
        if (streetName == nil) {
        }
        else {
        self.streetTextfield.text = [[PFUser currentUser] objectForKey:@"streetName"];
        }
        return streetCell;
    }
    if (indexPath.row == 1) {
        NSString *aptDormNumber = [[PFUser currentUser] objectForKey:@"aptDormNumber"];
        if (aptDormNumber == nil) {
        }
        else {
            self.apartmentDormTextField.text = [[PFUser currentUser] objectForKey:@"aptDormNumber"];
        }
        return apartmentDormCell;
    }
    if (indexPath.row == 2) {
        NSString *zipCode = [[PFUser currentUser] objectForKey:@"zipCode"];
        if (zipCode == nil) {
        }
        else {
            self.zipTextfield.text = [[PFUser currentUser] objectForKey:@"zipCode"];
        }
        return zipcodeCell;
    }
    if (indexPath.row == 3) {
        NSString *instructions = [[PFUser currentUser] objectForKey:@"deliveryInstructions"];
        if (instructions == nil) {
        }
        else {
            self.instructionsPlaceholder.hidden = YES;
            self.instructionsTextfield.text = [[PFUser currentUser] objectForKey:@"deliveryInstructions"];
        }
        return instructionsCell;
    }
    
   
    return nil;
}


//*********************************************
// Save Address To Parse

- (IBAction)saveButton:(id)sender {
    
    //[ProgressHUD show:nil];
    NSString *streetName = self.streetTextfield.text;
    NSString *aptDormNumber = self.apartmentDormTextField.text;
    NSString *zipCode = self.zipTextfield.text;
    NSString *deliveryInstructions = self.instructionsTextfield.text;
    
    
    if ([streetName length ] < 7) {
        
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Error"
                                           subtitle:@"Invalid street name"
                                              image:nil
                                               type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:^{}
                                         atPosition:TSMessageNotificationPositionNavBarOverlay
                               canBeDismissedByUser:YES];

    }
    else if (aptDormNumber == nil) {
        
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Error"
                                           subtitle:@"Invalid apt/dorm number"
                                              image:nil
                                               type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:^{}
                                         atPosition:TSMessageNotificationPositionNavBarOverlay
                               canBeDismissedByUser:YES];

    }
    else if ([zipCode length] < 5) {
        
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Error"
                                           subtitle:@"Invalid zip code"
                                              image:nil
                                               type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:^{}
                                         atPosition:TSMessageNotificationPositionNavBarOverlay
                               canBeDismissedByUser:YES];

    }
    
    else {
        [ProgressHUD show:nil];
        PFUser *user = [PFUser currentUser];
        [user setObject:streetName forKey:@"streetName"];
        [user setObject:aptDormNumber forKey:@"aptDormNumber"];
        [user setObject:zipCode forKey:@"zipCode"];
        [user setObject:deliveryInstructions forKey:@"deliveryInstructions"];
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
           
            if (error) {
                [ProgressHUD dismiss];
                [TSMessage showNotificationInViewController:self.navigationController
                                                      title:@"Eror"
                                                   subtitle:@"There was an issue saving your address information"
                                                      image:nil
                                                       type:TSMessageNotificationTypeSuccess
                                                   duration:TSMessageNotificationDurationAutomatic
                                                   callback:nil
                                                buttonTitle:nil
                                             buttonCallback:^{}
                                                 atPosition:TSMessageNotificationPositionNavBarOverlay
                                       canBeDismissedByUser:YES];

                
            }
            else {
                [ProgressHUD dismiss];
                [self.tableView reloadData];
                [parent addressMessage];

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
    
    [self.streetTextfield resignFirstResponder];
    [self.apartmentDormTextField resignFirstResponder];
    [self.zipTextfield resignFirstResponder];
    [self.instructionsTextfield resignFirstResponder];
    
}




@end
