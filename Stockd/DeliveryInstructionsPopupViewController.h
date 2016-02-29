//
//  DeliveryInstructionsPopupViewController.h
//  Stockd
//
//  Created by Evan Latner on 2/22/16.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeliveryInstructionsPopupViewController : UIViewController <UITextViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UITextView *instructionsTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


@end
