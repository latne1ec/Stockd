//
//  PhoneTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "TSMessage.h"

@interface PhoneTableViewController : UITableViewController <UITextFieldDelegate, TSMessageViewProtocol>
{
    id parent;
}

@property(nonatomic,strong) id parent;
@property (weak, nonatomic) IBOutlet UITableViewCell *firstCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *mobileNumberCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *houseNumberCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *workNumberCell;

@property (weak, nonatomic) IBOutlet UITextField *mobileTextfield;
@property (weak, nonatomic) IBOutlet UITextField *houseTextfield;

@property (weak, nonatomic) IBOutlet UITextField *workTextfield;
@end
