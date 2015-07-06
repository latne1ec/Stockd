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
#import "SCRecorder.h"



@interface CameraViewController : UIViewController <SlideNavigationControllerDelegate, UINavigationControllerDelegate, SCRecorderDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (nonatomic, strong) UIImage *selectedImage;
@property(nonatomic,strong) UIImageView *capturedImageView;
@property(nonatomic,strong) UIView *imageSelectedView;
@property (nonatomic, strong) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (nonatomic, strong) UITapGestureRecognizer *camTap;
@property (nonatomic, strong) IBOutlet UIButton *flash;
@property (nonatomic, strong) UIButton *cancelPhoto;
@property (nonatomic, strong) UITextField *caption;

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu;
- (BOOL)slideNavigationControllerShouldDisplayRightMenu;


@end
