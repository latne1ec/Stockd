//
//  AddressViewController.h
//  Stockd
//
//  Created by Alex Consel on 2016-03-23.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "TSMessage.h"
#import "ProfileTableViewController.h"

@interface AddressViewController : UIViewController <UIAlertViewDelegate>

@property(nonatomic,strong) id parent;
@property (nonatomic) BOOL comingFromCart;

@end
