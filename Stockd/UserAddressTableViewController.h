//
//  UserAddressTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 10/12/15.
//  Copyright © 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "TSMessage.h"


@interface UserAddressTableViewController : UITableViewController <UITextFieldDelegate, UITextViewDelegate, TSMessageViewProtocol, UIAlertViewDelegate>



@property (weak, nonatomic) IBOutlet UITableViewCell *streetCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *cityCell;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITableViewCell *stateCell;

@property (weak, nonatomic) IBOutlet UITextField *stateTextField;

@property (weak, nonatomic) IBOutlet UITableViewCell *apartmentDormCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *zipcodeCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *instructionsCell;

@property(nonatomic,strong) id parent;

@property (weak, nonatomic) IBOutlet UITextField *streetTextfield;

@property (weak, nonatomic) IBOutlet UITextField *apartmentDormTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipTextfield;
@property (weak, nonatomic) IBOutlet UITextView *instructionsTextfield;

@property (weak, nonatomic) IBOutlet UILabel *instructionsPlaceholder;



@end
