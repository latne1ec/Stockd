//
//  PaymentTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "PaymentTableViewController.h"

@interface PaymentTableViewController ()

@property (nonatomic, strong) NSString *userStripeToken;
@property (nonatomic, strong) NSString *ccNumber;




@end

@implementation PaymentTableViewController

@synthesize firstCell, cardNumberCell, cardExpirationCell, ccvCell;
@synthesize cardNumberTextfield, cardExpirationTextfield, ccvTextfield;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cardExpirationTextfield.delegate = self;
    self.cardExpirationTextfield.delegate = self;
    self.ccvTextfield.delegate = self;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(savePaymentInfo)];
    
    self.tableView.tableFooterView = [UIView new];
    
    self.title = @"Payment Info";
    
    [self performSelector:@selector(reloadTheTable) withObject:nil afterDelay:1.0];
    
}

-(void)reloadTheTable {
    
    [self.tableView reloadData];
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
    
    /////TO DO
    //Update and Retrieve Payment Info from Stripe
    
    if (indexPath.row == 0) {
        
        self.ccNumber = [[PFUser currentUser] objectForKey:@"lastFourCC"];
        NSLog(@"YOO: %@", self.ccNumber);
        if (self.ccNumber == nil) {
        }
        else {
                
            NSString *secureCard = [NSString stringWithFormat:@"****%@", self.ccNumber];
            NSLog(@"Card #: %@", secureCard);
            self.cardNumberTextfield.text = secureCard;
            NSLog(@"secure card: %@", self.cardExpirationTextfield.text);
        }
    return cardNumberCell;
    }
    if (indexPath.row == 1) {
        
        NSString *fakeExpCode = [[PFUser currentUser] objectForKey:@"fakeExpCode"];
        if (fakeExpCode == nil) {
        }
        else {
            
            self.cardExpirationTextfield.text = [[PFUser currentUser] objectForKey:@"fakeExpCode"];
            NSString *secureExpCode = [NSString stringWithFormat:@"%@", fakeExpCode];
            self.cardNumberTextfield.text = secureExpCode;
        }
   
    return cardExpirationCell;
    }
    
    if (indexPath.row == 2) {
     
        if (indexPath.row == 2) {
            
            NSString *fakeCvcCode = [[PFUser currentUser] objectForKey:@"fakeCvcCode"];
            if (fakeCvcCode == nil) {
            }
            else {
                
                self.ccvTextfield.text = [[PFUser currentUser] objectForKey:@"fakeExpCode"];
                NSString *secureExpCode = [NSString stringWithFormat:@"%@", fakeCvcCode];
                self.ccvTextfield.text = secureExpCode;
            }
        }

        
    return ccvCell;
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
    [self.ccvTextfield resignFirstResponder];
    
}

-(void)savePaymentInfo {
    
    [ProgressHUD show:nil Interaction:NO];
    STPCard *card = [[STPCard alloc] init];
    card.number = self.cardNumberTextfield.text;
    card.expMonth = 7;
    card.expYear = 15;
    card.cvc = self.ccvTextfield.text;
    [[STPAPIClient sharedClient] createTokenWithCard:card
                                          completion:^(STPToken *token, NSError *error) {
                                              if (error) {
                                                  [ProgressHUD showError:@"Invalid Credit Card Info"];
                                                  NSLog(@"Create token Error: %@", error);
                                              } else {
                                                  
                                                  NSString *theToken = [NSString stringWithFormat:@"%@",token];
                                                  NSString *formattedToken = [theToken stringByReplacingOccurrencesOfString:@" (live mode)" withString:@""];
                                                  
                                                  [self saveUserTokenToParse:formattedToken];
                                                  [PaymentTableViewController createCustomerFromCard:token completion:^(id object, NSError *error) {
                                                      
                                                  }];
                                                  
                                            }
                                          }];
    
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
                                        NSLog(@"Success");
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
    [[PFUser currentUser] setObject:cvcCode forKey:@"fakeCvcCode"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            
            [ProgressHUD showError:@"Network Error"];
            
        }
        else {
            
            [ProgressHUD showSuccess:@"Payment Method Save"];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }];
}





@end
