//
//  CameraViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/1/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController () {
    SCRecorder *_recorder;
    UIImage *_photo;
    SCRecordSession *_recordSession;
    UIImageView *_ghostImageView;
}



@end

@implementation CameraViewController

-(BOOL)prefersStatusBarHidden {
    
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //Photo Views
    self.capturedImageView = [[UIImageView alloc]init];
    self.capturedImageView.frame = self.view.frame; // just to even it out
    self.capturedImageView.backgroundColor = [UIColor clearColor];
    self.capturedImageView.userInteractionEnabled = YES;
    self.capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.imageSelectedView = [[UIView alloc]initWithFrame:self.view.frame];
    [self.imageSelectedView setBackgroundColor:[UIColor clearColor]];
    [self.imageSelectedView addSubview:self.capturedImageView];
    
    _recorder = [SCRecorder recorder];
    _recorder.sessionPreset = [SCRecorderTools bestSessionPresetCompatibleWithAllDevices];
    _recorder.maxRecordDuration = CMTimeMake(7, 1); //
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
    
    UIView *previewView = self.previewView;
    self.previewView.frame = self.view.frame;
    _recorder.previewView = previewView;

    _recorder.initializeRecordSessionLazily = YES;
    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        [self prepareCamera];
    }];
    
    self.camTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(capturePhoto:)];
    self.camTap.numberOfTapsRequired = 1;
    
    UIView *bottomViewTwo = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-175, CGRectGetWidth(self.view.frame), 150)];
    [bottomViewTwo setBackgroundColor:[UIColor colorWithRed:0.976 green:0.365 blue:0.29 alpha:1]];
    [self.previewView.layer addSublayer:bottomViewTwo.layer];
    
    UIButton *camerabutton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-50, CGRectGetHeight(self.view.bounds)-150, 100, 100)];
    [camerabutton setImage:[UIImage imageNamed:@"snapPhoto"] forState:UIControlStateNormal];
    [camerabutton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [camerabutton setTintColor:[UIColor blueColor]];
    [camerabutton.layer setCornerRadius:20.0];
    [self.view addSubview:camerabutton];
    
    self.flash = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-68, CGRectGetHeight(self.view.frame)-104, 36, 36)];
    [self.flash setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    [self.flash addTarget:self action:@selector(switchFlash:) forControlEvents:UIControlEventTouchUpInside];
    [self.flash setImage:[UIImage imageNamed:@"flashSelected"] forState:UIControlStateSelected];
    [self.view addSubview:self.flash];
    
    UIButton *fillButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-50, CGRectGetHeight(self.view.bounds)-150, 100, 100)];
    [fillButton setImage:[UIImage imageNamed:@"fillButton"] forState:UIControlStateNormal];
    [fillButton addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];
    [fillButton.layer setCornerRadius:20.0];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, -60, CGRectGetWidth(self.view.frame), 60)];
    [topView setBackgroundColor:[UIColor colorWithRed:0.941 green:0.353 blue:0.643 alpha:1]];
    [self.imageSelectedView addSubview:topView];
    //[topView addSubview:cancelPhoto];

    
    self.cancelPhoto = [[UIButton alloc]initWithFrame:CGRectMake(9, -32.5, 29, 29)];
    [self.cancelPhoto setImage:[UIImage imageNamed:@"cancelPhoto"] forState:UIControlStateNormal];
    [self.cancelPhoto addTarget:self action:@selector(cancelSelectedPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageSelectedView addSubview:self.cancelPhoto];
    
    UITapGestureRecognizer *cancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelectedPhoto:)];
    [topView addGestureRecognizer:cancel];
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-175, CGRectGetWidth(self.view.frame), 150)];
    [bottomView setBackgroundColor:[UIColor colorWithRed:0.976 green:0.365 blue:0.29 alpha:1]];
    [self.imageSelectedView addSubview:bottomView];
    [self.imageSelectedView addSubview:fillButton];


}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSLog(@"got here");
    CGFloat radius = 100.0;
    CGRect frame = CGRectMake(-radius, -radius,
                              self.view.frame.size.width + radius,
                              self.view.frame.size.height + radius);
    
    if (CGRectContainsPoint(frame, point)) {
        return self.view;
    }
    return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    
    NSLog(@"got here");
    if (CGRectContainsPoint(self.view.bounds, point) ||
        CGRectContainsPoint(self.cancelPhoto.frame, point))
    {
        return YES;
    }
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_recorder startRunningSession];
}

- (void) prepareCamera {
    if (_recorder.recordSession == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.fileType = AVFileTypeQuickTimeMovie;
        _recorder.recordSession = session;
    }
}



- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


-(void)viewWillAppear:(BOOL)animated {
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
}

-(void)imageSelected:(UIImage *)img {
    
    self.selectedImage = img;
    NSLog(@"Image: %@", img);
}

-(void)imageSelectionCancelled {
    
}

- (IBAction)switchFlash:(id)sender {
    NSString *flashModeString = nil;
    if ([_recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        [self.flash setSelected:YES];
        switch (_recorder.flashMode) {
            case SCFlashModeAuto:
                flashModeString = @"Flash : Off";
                _recorder.flashMode = SCFlashModeOff;
                break;
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                _recorder.flashMode = SCFlashModeOn;
                break;
            case SCFlashModeOn:
                flashModeString = @"Flash : Light";
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Auto";
                _recorder.flashMode = SCFlashModeAuto;
                break;
            default:
                break;
        }
    } else {
        [self.flash setSelected:YES];

        switch (_recorder.flashMode) {
            case SCFlashModeOff:
                flashModeString = @"Flash : On";
                [self.flash setSelected:YES];
                _recorder.flashMode = SCFlashModeLight;
                break;
            case SCFlashModeLight:
                flashModeString = @"Flash : Off";
                [self.flash setSelected:NO];
                _recorder.flashMode = SCFlashModeOff;
                break;
            default:
                break;
        }
    }
}

- (IBAction)capturePhoto:(id)sender {
    
    [_recorder capturePhoto:^(NSError *error, UIImage *image) {
        if (image != nil) {
            
        
            NSLog(@"Got Pic: %@", image);
            self.capturedImageView.image = image;
            [self.view addSubview:self.imageSelectedView];
            
            self.navigationController.navigationBar.hidden = YES;
            
            //[[SlideNavigationController sharedInstance] setEnableSwipeGesture:NO];
            
            }
        }];
}

-(IBAction)cancelSelectedPhoto:(id)sender {
    
    NSLog(@"Called");
    [self.imageSelectedView removeFromSuperview];
    
    self.navigationController.navigationBar.hidden = NO;
    
}

-(void)uploadPhoto {

    NSLog(@"upload");
}


@end
