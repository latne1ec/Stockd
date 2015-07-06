//
//  EmailTableViewController.h
//  Stockd
//
//  Created by Evan Latner on 6/30/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "TSMessage.h"
#import "ProfileTableViewController.h"

@interface EmailTableViewController : UITableViewController <UITextFieldDelegate>
{
    id parent;
}

@property(nonatomic,strong) id parent;
@property (weak, nonatomic) IBOutlet UITableViewCell *firstCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *emailCell;
@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;

@end
