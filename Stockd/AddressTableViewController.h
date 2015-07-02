//
//  AddressTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "TSMessage.h"

@interface AddressTableViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate>



@property (weak, nonatomic) IBOutlet UITableViewCell *firstCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *streetCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *apartmentDormCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *zipcodeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *instructionsCell;

@property (weak, nonatomic) IBOutlet UITextField *streetTextfield;

@property (weak, nonatomic) IBOutlet UITextField *apartmentDormTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipTextfield;
@property (weak, nonatomic) IBOutlet UITextView *instructionsTextfield;

@property (weak, nonatomic) IBOutlet UILabel *instructionsPlaceholder;




@end
