//
//  MyImagePickerViewController.m
//  cameratestapp
//
//  Created by pavan krishnamurthy on 6/24/14.
//  Copyright (c) 2014 pavan krishnamurthy. All rights reserved.
//

#import "PKImagePickerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PKImagePickerViewController ()

@property(nonatomic,strong) AVCaptureSession *captureSession;
@property(nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic,strong) AVCaptureDevice *captureDevice;
@property(nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property(nonatomic,assign) BOOL isCapturingImage;
@property(nonatomic,strong) UIImageView *capturedImageView;
@property(nonatomic,strong)UIImagePickerController *picker;
@property(nonatomic,strong) UIView *imageSelectedView;
@property(nonatomic,strong) UIImage *selectedImage;

@end

@implementation PKImagePickerViewController

@synthesize caption;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView
{
    self.view = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}


-(BOOL)shouldAutorotate
{
    return NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.captureSession = [[AVCaptureSession alloc]init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    self.capturedImageView = [[UIImageView alloc]init];
    self.capturedImageView.frame = self.view.frame; // just to even it out
    self.capturedImageView.backgroundColor = [UIColor clearColor];
    self.capturedImageView.userInteractionEnabled = YES;
    self.capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    
    UIView *bottomViewTwo = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-150, CGRectGetWidth(self.view.frame), 150)];
    [bottomViewTwo setBackgroundColor:[UIColor colorWithRed:0.976 green:0.365 blue:0.29 alpha:1]];
    [self.captureVideoPreviewLayer addSublayer:bottomViewTwo.layer];

    
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (devices.count > 0) {
        self.captureDevice = devices[0];
    
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    
        [self.captureSession addInput:input];
    
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
        NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
        [self.captureSession addOutput:self.stillImageOutput];
    
    
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
        else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
    
    UIButton *camerabutton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-50, CGRectGetHeight(self.view.bounds)-125, 100, 100)];
    [camerabutton setImage:[UIImage imageNamed:@"snapPhoto"] forState:UIControlStateNormal];
    [camerabutton addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [camerabutton setTintColor:[UIColor blueColor]];
    [camerabutton.layer setCornerRadius:20.0];
    [self.view addSubview:camerabutton];
    
//    UIButton *menu = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 32, 32)];
//    [menu setImage:[UIImage imageNamed:@"stockdMenu"] forState:UIControlStateNormal];
//    [menu addTarget:self action:@selector(flash:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:menu];
    }
    
    UIButton *flash = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-54, CGRectGetHeight(self.view.frame)-54, 36, 36)];
    [flash setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    [flash addTarget:self action:@selector(flash:) forControlEvents:UIControlEventTouchUpInside];
    [flash setImage:[UIImage imageNamed:@"flashSelected"] forState:UIControlStateSelected];
    [self.view addSubview:flash];
    
    self.picker = [[UIImagePickerController alloc]init];
    self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.picker.delegate = self;
    
    self.imageSelectedView = [[UIView alloc]initWithFrame:self.view.frame];
    [self.imageSelectedView setBackgroundColor:[UIColor clearColor]];
    [self.imageSelectedView addSubview:self.capturedImageView];

    
    UIButton *cancelPhoto = [[UIButton alloc]initWithFrame:CGRectMake(9, 6.5, 29, 29)];
    [cancelPhoto setImage:[UIImage imageNamed:@"cancelPhoto"] forState:UIControlStateNormal];
    [cancelPhoto addTarget:self action:@selector(cancelSelectedPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelPhoto];
    
    [self.imageSelectedView addSubview:cancelPhoto];
    
    UIButton *fillButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-50, CGRectGetHeight(self.view.bounds)-125, 100, 100)];
    [fillButton setImage:[UIImage imageNamed:@"fillButton"] forState:UIControlStateNormal];
    [fillButton addTarget:self action:@selector(photoSelected:) forControlEvents:UIControlEventTouchUpInside];
    [fillButton.layer setCornerRadius:20.0];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    [topView setBackgroundColor:[UIColor colorWithRed:0.941 green:0.353 blue:0.643 alpha:1]];
    [self.imageSelectedView addSubview:topView];
    [topView addSubview:cancelPhoto];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-150, CGRectGetWidth(self.view.frame), 150)];
    [bottomView setBackgroundColor:[UIColor colorWithRed:0.976 green:0.365 blue:0.29 alpha:1]];
    [self.imageSelectedView addSubview:bottomView];
    [self.imageSelectedView addSubview:fillButton];
    
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(captionDrag:)];
    [self.capturedImageView addGestureRecognizer:drag];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.captureSession startRunning];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.captureSession stopRunning];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

//////Fill Meter

///********************************************************************
/////PHOTO CAPTION
- (void)imageViewTapped:(UITapGestureRecognizer *)recognizer {
    
    
        NSLog(@"Tap tap");
        caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        caption.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        if([caption isFirstResponder]){
            [caption resignFirstResponder];
            caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
            
        } else {
            if (caption.alpha == 1) {
            }
            else {
                [self initCaption];
                caption.alpha = 1;
        }
    }
}

-(void)showFullMeter {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self imageViewTapped:tap];
//    [self initCaption];
//    caption.alpha = 1;
}
- (void) initCaption{
    
    caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
    
    // Caption
    caption = [[UITextField alloc] initWithFrame:CGRectMake(0,self.capturedImageView.frame.size.height/2,self.capturedImageView.frame.size.width,40)];
    caption.backgroundColor = [[UIColor colorWithRed:0.318 green:0.89 blue:0.761 alpha:1] colorWithAlphaComponent:1.00];
    caption.textAlignment = NSTextAlignmentCenter;
    caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    caption.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    caption.textColor = [UIColor whiteColor];
    caption.alpha = 0;
    caption.tintColor = [UIColor whiteColor];
    caption.delegate = self;
    caption.font = [UIFont fontWithName:@"BELLABOO-Regular" size:20];
    caption.text = @"Half";
    [caption setEnabled:NO];
    caption.allowsEditingTextAttributes = NO;
    [self.capturedImageView addSubview:caption];
}

- (void) captionDrag: (UIGestureRecognizer*)gestureRecognizer{
    
    CGPoint translation = [gestureRecognizer locationInView:self.view];
    
    float yPosition = translation.y;
    
    float upperLimit = 64;
    float lowerLimit = self.view.frame.size.height-150-caption.frame.size.height/2;
    
    if(yPosition<upperLimit){
        yPosition = upperLimit;
    } else if(yPosition>lowerLimit){
        yPosition = lowerLimit;
    }
    
    if(yPosition < caption.frame.size.height/2){
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  caption.frame.size.height/2);
    } else if(self.capturedImageView.frame.size.height < yPosition + caption.frame.size.height/2){
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  self.capturedImageView.frame.size.height - caption.frame.size.height/2);
    } else {
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  yPosition);

        if (yPosition < 260) {
            caption.text = @"Full";
        }
        if (yPosition > 250) {
            caption.text = @"Half";
        }
    }
}



//////Fill Meter

-(IBAction)capturePhoto:(id)sender
{
    self.isCapturingImage = YES;
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *capturedImage = [[UIImage alloc]initWithData:imageData scale:1];
            self.isCapturingImage = NO;
            self.capturedImageView.image = capturedImage;
            [self.view addSubview:self.imageSelectedView];
            self.selectedImage = capturedImage;
            imageData = nil;
            
            [self showFullMeter];
            
        }
    }];
    
    
}


-(IBAction)flash:(UIButton*)sender
{
    if ([self.captureDevice isFlashAvailable]) {
        if (self.captureDevice.flashActive) {
            if([self.captureDevice lockForConfiguration:nil]) {
                self.captureDevice.flashMode = AVCaptureFlashModeOff;
                [sender setTintColor:[UIColor grayColor]];
                [sender setSelected:NO];
            }
        }
        else {
            if([self.captureDevice lockForConfiguration:nil]) {
                self.captureDevice.flashMode = AVCaptureFlashModeOn;
                [sender setTintColor:[UIColor blueColor]];
                [sender setSelected:YES];
            }
        }
        [self.captureDevice unlockForConfiguration];
    }
}

-(IBAction)showFrontCamera:(id)sender
{
    if (self.isCapturingImage != YES) {
        if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0]) {
            // rear active, switch to front
            self.captureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1];
            
            [self.captureSession beginConfiguration];
            AVCaptureDeviceInput * newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
            for (AVCaptureInput * oldInput in self.captureSession.inputs) {
                [self.captureSession removeInput:oldInput];
            }
            [self.captureSession addInput:newInput];
            [self.captureSession commitConfiguration];
        }
        else if (self.captureDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
            // front active, switch to rear
            self.captureDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
            [self.captureSession beginConfiguration];
            AVCaptureDeviceInput * newInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
            for (AVCaptureInput * oldInput in self.captureSession.inputs) {
                [self.captureSession removeInput:oldInput];
            }
            [self.captureSession addInput:newInput];
            [self.captureSession commitConfiguration];
        }
        
        // Need to reset flash btn
    }
}
-(IBAction)showalbum:(id)sender
{
    [self presentViewController:self.picker animated:YES completion:nil];
    //
}

-(IBAction)photoSelected:(id)sender
{
    
    if ([self.delegate respondsToSelector:@selector(imageSelected:)]) {
        [self.delegate imageSelected:self.selectedImage];
    }
    [self.imageSelectedView removeFromSuperview];
    
//    NSLog(@"photo selected");
//    [self dismissViewControllerAnimated:YES completion:^{
//        if ([self.delegate respondsToSelector:@selector(imageSelected:)]) {
//            [self.delegate imageSelected:self.selectedImage];
//        }
//        [self.imageSelectedView removeFromSuperview];
//    }];
    
}

-(IBAction)cancelSelectedPhoto:(id)sender
{
    [self.imageSelectedView removeFromSuperview];
}

-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        if ([self.delegate respondsToSelector:@selector(imageSelectionCancelled)]) {
            [self.delegate imageSelectionCancelled];
        }

    }];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSLog(@"Image: %@", self.selectedImage);

    
    [self dismissViewControllerAnimated:NO completion:^{
        self.capturedImageView.image = self.selectedImage;
        [self.view addSubview:self.imageSelectedView];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
