//
//  PickSizeViewController.h
//  Stockd
//
//  Created by Evan Latner on 10/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickSizeViewController : UIViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, strong) IBOutlet UIButton *pickButton;
@property (nonatomic, strong) UITextField *caption;

@property (nonatomic) float currentCartPrice;



@end
