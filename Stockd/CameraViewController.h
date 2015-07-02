//
//  CameraViewController.h
//  Stockd
//
//  Created by Evan Latner on 7/1/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKImagePickerViewController.h"
#import <Parse/Parse.h>
#import "SlideNavigationController.h"



@interface CameraViewController : UIViewController <PKImagePickerViewControllerDelegate, SlideNavigationControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic,strong) PKImagePickerViewController *imagePicker;


@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (nonatomic, strong) UIImage *selectedImage;


-(void)imageSelected:(UIImage *)img;

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu;
- (BOOL)slideNavigationControllerShouldDisplayRightMenu;


@end
