//
//  PaymentTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "PaymentTableViewController.h"
#import "ProfileTableViewController.h"

@interface PaymentTableViewController ()

@property (nonatomic, strong) NSString *userStripeToken;
@property (nonatomic, strong) NSString *customerID;
@property (nonatomic, strong) NSString *ccNumber;





@end

@implementation PaymentTableViewController 

@synthesize firstCell, cardNumberCell, cardExpirationCell, ccvCell, parent;
@synthesize cardNumberTextfield, cvvTextfield;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.cardNumberTextfield.delegate = self;
    self.cardExpirationTextfield.delegate = self;
    self.cvvTextfield.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"saveButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(savePaymentInfo)];
    
    self.tableView.tableFooterView = [UIView new];
    
    self.title = @"Payment Info";
    
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
    
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    if ([[PFUser currentUser] objectForKey:@"lastFourCC"] != nil) {
    
    self.ccNumber = [[PFUser currentUser] objectForKey:@"lastFourCC"];
    NSString *secureCard = [NSString stringWithFormat:@"****%@", self.ccNumber];
    NSLog(@"Card #: %@", secureCard);
    self.cardNumberTextfield.text = secureCard;
    self.cvvTextfield.text = [[PFUser currentUser] objectForKey:@"fakeCvvCode"];
    
    self.userStripeToken = [[PFUser currentUser] objectForKey:@"stripeToken"];
    self.customerID = [[PFUser currentUser] objectForKey:@"customerID"];
        
        self.cardNumberTextfield.enabled = NO;
        self.cardExpirationTextfield.enabled = NO;
        self.cvvTextfield.enabled = NO;
        
    }
    
    CALayer *btn1 = [self.removeCardButton layer];
    [btn1 setMasksToBounds:YES];
    [btn1 setCornerRadius:4.0f];
    
}

-(void)reloadTheTable {
    
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [ProgressHUD dismiss];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (self.userStripeToken !=nil) {
        return 4;
    }
    else{
    return 3;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /////TO DO
    //Update and Retrieve Payment Info from Stripe
    
    if (indexPath.row == 0) {
        
        return cardNumberCell;
    }
    if (indexPath.row == 1) {
        
        NSString *fakeExpCode = [[PFUser currentUser] objectForKey:@"fakeExpCode"];
        if (fakeExpCode == nil) {
        }
        else {
            
            self.cardExpirationTextfield.text = [[PFUser currentUser] objectForKey:@"fakeExpCode"];
            NSString *secureExpCode = [NSString stringWithFormat:@"%@", fakeExpCode];
            self.cardExpirationTextfield.text = secureExpCode;
        }
   
    return cardExpirationCell;
    }
    
    if (indexPath.row == 2) {
     
        if (indexPath.row == 2) {
            
            NSString *fakeCvvCode = [[PFUser currentUser] objectForKey:@"fakeCvvCode"];
            if (fakeCvvCode == nil) {
            }
            else {
                
                self.cvvTextfield.text = [[PFUser currentUser] objectForKey:@"fakeCvvCode"];
                NSString *secureCvvCode = [NSString stringWithFormat:@"%@", fakeCvvCode];
                self.cvvTextfield.text = secureCvvCode;
            }
        }
        
    return ccvCell;
    }
    
    if (indexPath.row == 3) {
        _removeCardCell.separatorInset = UIEdgeInsetsMake(0.f, 10000.0f, 0.f, 0.0f);
    }
    
     if (indexPath.row == 3) {
         
         return _removeCardCell;
     }
    
    return nil;
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    [self dismissKeyboard];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

-(void)dismissKeyboard {
    
    [self.cardNumberTextfield resignFirstResponder];
    [self.cardExpirationTextfield resignFirstResponder];
    [self.cvvTextfield resignFirstResponder];
    
}



//*********************************************
// Format Phone Number As It's Entered

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([self.cardNumberTextfield isFirstResponder]) {
        
        if([string length]>0){
            if([textField.text length]>15 && [string characterAtIndex:0]!=5){
                NSLog(@"Here: %@", string);
                return NO;
            }
        }
    }
    
    if ([self.cardExpirationTextfield isFirstResponder]) {
        
    if([string length]>0){
        if([textField.text length]>4 && [string characterAtIndex:0]!=5){
            NSLog(@"Here: %@", string);
            return NO;
        }
    }
      
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSArray *components = [newString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [components componentsJoinedByString:@""];
    
    NSUInteger length = decimalString.length;
    
    NSUInteger index = 0;
    NSMutableString *formattedString = [NSMutableString string];
    
    if (length - index > 2) {
        NSString *areaCode = [decimalString substringWithRange:NSMakeRange(index, 2)];
        [formattedString appendFormat:@"%@/",areaCode];
        index += 2;
    }
    
    NSString *remainder = [decimalString substringFromIndex:index];
    [formattedString appendString:remainder];
    
    textField.text = formattedString;
    return NO;
        
    }
    
    if ([self.cvvTextfield isFirstResponder]) {
        
        if([string length]>0){
            if([textField.text length]>3 && [string characterAtIndex:0]!=5){
                NSLog(@"Here: %@", string);
                return NO;
            }
        }
    }
    
    
    return YES;
    
}
//*********************************************


-(void)savePaymentInfo {
    
    if ([[PFUser currentUser] objectForKey:@"stripeToken"] != nil) {
        NSLog(@"Already set up payment info");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already Saved" message:@"This card has already been saved to your Stockd account. You're good to go!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else {
        
    if (self.cardNumberTextfield.text.length < 16) {
        
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Error"
                                           subtitle:@"Invalid credit card number"
                                              image:nil
                                               type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:^{}
                                         atPosition:TSMessageNotificationPositionNavBarOverlay
                               canBeDismissedByUser:YES];
    }
        
    else if (self.cardExpirationTextfield.text.length < 4) {
        
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Error"
                                           subtitle:@"Invalid expiration date"
                                              image:nil
                                               type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:^{}
                                         atPosition:TSMessageNotificationPositionNavBarOverlay
                               canBeDismissedByUser:YES];
        
    }
    
    else if (self.cvvTextfield.text.length < 3) {
     
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Error"
                                           subtitle:@"Invalid CVV"
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
        
    NSString *exp = self.cardExpirationTextfield.text;
    
    [ProgressHUD show:nil Interaction:NO];
    STPCard *card = [[STPCard alloc] init];
    card.number = self.cardNumberTextfield.text;
    card.expMonth = [[exp substringToIndex:2] integerValue];
    card.expYear = [[exp substringFromIndex: [exp length] - 2] integerValue];
    card.cvc = self.cvvTextfield.text;
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  [ProgressHUD dismiss];
                                                  [TSMessage showNotificationInViewController:self.navigationController
                                                                                        title:@"Error"
                                                                                     subtitle:@"Invalid credit card info"
                                                                                        image:nil
                                                                                         type:TSMessageNotificationTypeError
                                                                                     duration:TSMessageNotificationDurationAutomatic
                                                                                     callback:nil
                                                                                  buttonTitle:nil
                                                                               buttonCallback:^{}
                                                                                   atPosition:TSMessageNotificationPositionNavBarOverlay
                                                                         canBeDismissedByUser:YES];

                                                  
                                                  
                                              } else {
                                                  [ProgressHUD dismiss];
                                                  NSString *theToken = [NSString stringWithFormat:@"%@",token];
                                                  NSString *formattedToken = [theToken stringByReplacingOccurrencesOfString:@" (live mode)" withString:@""];
                                                  
                                                  [self saveUserTokenToParse:formattedToken];
                                                  [PaymentTableViewController createCustomerFromCard:token completion:^(id object, NSError *error) {
                                                      
                                                  }];
                                                  
                                            }
                                          }];
                }
        }
}

typedef void (^STPCardCompletionBlock)(STPCard *card,NSError *error);
+(void)createCustomerFromCard:(STPToken *)tokenId completion:(PFIdResultBlock)handler {
    
    NSString *theToken = [NSString stringWithFormat:@"%@",tokenId];
    NSString *formattedToken = [theToken stringByReplacingOccurrencesOfString:@" (live mode)" withString:@""];
    
    [PFCloud callFunctionInBackground:@"createCustomer"
                       withParameters:@{
                                        @"tokenId":formattedToken,
                                        }
                                block:^(id object, NSError *error) {
                                    handler(object,error);
                                    
                                    if (error) {
                                        NSLog(@"Error: %@", error);
                                        [ProgressHUD showError:@"Network Error"];
                                    }
                                    else {
                                        
                                        NSLog(@"Customer: %@",object);
                                        
                                        [[PFUser currentUser] setObject:object forKey:@"customerID"];
                                        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                            if (error) {
                                                NSLog(@"Error");
                                            } else{
                                                NSLog(@"Successfully saved Customer ID");
                                            }
                                        }];
                                    }
                                }];
}

-(void)saveUserTokenToParse:(NSString *)token {
    
    NSString *lastFourCC = [self.cardNumberTextfield.text substringFromIndex: [self.cardNumberTextfield.text length] - 4];
    NSString *expCode = @"****";
    NSString *cvcCode = @"***";

    [[PFUser currentUser] setObject:token forKey:@"stripeToken"];
    [[PFUser currentUser] setObject:lastFourCC forKey:@"lastFourCC"];
    [[PFUser currentUser] setObject:expCode forKey:@"fakeExpCode"];
    [[PFUser currentUser] setObject:cvcCode forKey:@"fakeCvvCode"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [ProgressHUD dismiss];
            [TSMessage showNotificationInViewController:self.navigationController
                                                  title:@"Error"
                                               subtitle:[error.userInfo objectForKey:@"error"]
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
            [ProgressHUD dismiss];
            [parent paymentMessage];
            [self dismissViewControllerAnimated:YES completion:^{
                
                
                
            }];
        }
    }];
}

- (IBAction)removeCardTapped:(id)sender {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Remove Card?" message:@"Are you sure you want to remove this card? You can add a new one when this one is removed." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
    alertView.tag = 55;
    alertView.delegate = self;
}

//*********************************************
// Actions Methods For Logout Button

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex {
    
    if (alertView.tag == 55) {
        
        if (buttonIndex == 0) {
            
        }
        else if (buttonIndex == 1) {
            
            [self clearCardDetails];
            
        }
    }
}
//*********************************************

-(void)clearCardDetails {
    
    NSLog(@"Here");
    [[PFUser currentUser] removeObjectForKey:@"lastFourCC"];
    [[PFUser currentUser] removeObjectForKey:@"stripeToken"];
    [[PFUser currentUser] removeObjectForKey:@"fakeExpCode"];
    [[PFUser currentUser] removeObjectForKey:@"fakeCvvCode"];
    [[PFUser currentUser] removeObjectForKey:@"customerID"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            
            [TSMessage showNotificationInViewController:self.navigationController
                                                  title:@"Error"
                                               subtitle:[error.userInfo objectForKey:@"error"]
                                                  image:nil
                                                   type:TSMessageNotificationTypeError
                                               duration:TSMessageNotificationDurationAutomatic
                                               callback:nil
                                            buttonTitle:nil
                                         buttonCallback:^{}
                                             atPosition:TSMessageNotificationPositionNavBarOverlay
                                   canBeDismissedByUser:YES];
            
        } else {
            
            [TSMessage showNotificationInViewController:self.navigationController
                                                  title:@"Success"
                                               subtitle:@"Removed credit card information"
                                                  image:nil
                                                   type:TSMessageNotificationTypeSuccess
                                               duration:TSMessageNotificationDurationAutomatic
                                               callback:nil
                                            buttonTitle:nil
                                         buttonCallback:^{}
                                             atPosition:TSMessageNotificationPositionNavBarOverlay
                                   canBeDismissedByUser:YES];
            
            [self.tableView reloadData];
            self.cardNumberTextfield.text = nil;
            self.cardExpirationTextfield.text = nil;
            self.cvvTextfield.text = nil;
            
            self.cardNumberTextfield.enabled = YES;
            self.cardExpirationTextfield.enabled = YES;
            self.cvvTextfield.enabled = YES;
        }
    }];
}

-(void)textFieldChanged:(id)sender {
}


@end
