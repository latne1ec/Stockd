//
//  PaymentTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <Stripe/Stripe.h>
#import "ProgressHUD.h"
#import "TSMessage.h"

@interface PaymentTableViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *firstCell;

@property (weak, nonatomic) IBOutlet UITableViewCell *cardNumberCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cardExpirationCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *ccvCell;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberTextfield;
@property (weak, nonatomic) IBOutlet UITextField *cardExpirationTextfield;
@property (weak, nonatomic) IBOutlet UITextField *ccvTextfield;


@end
