//
//  CameraViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/1/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "CameraViewController.h"
#import "InitialViewController.h"

@interface CameraViewController () {
    SCRecorder *_recorder;
    UIImage *_photo;
    SCRecordSession *_recordSession;
    UIImageView *_ghostImageView;
}


@property (nonatomic, strong) NSArray *food;
@property (nonatomic, strong) NSArray *drinks;




@end

@implementation CameraViewController

@synthesize caption;

-(BOOL)prefersStatusBarHidden {
    
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([PFUser currentUser]) {
        
        [self queryForDrinkPackages];
        [self queryForFoodPackages];
    }
    else {
        
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
        
        InitialViewController *tvc = [self.storyboard instantiateViewControllerWithIdentifier:@"InitialVC"];
        [self.navigationController pushViewController:tvc animated:NO];
        
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
        
    }
    
    
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
    
    UIView *bottomViewTwo = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-190, CGRectGetWidth(self.view.frame), 150)];
    //[bottomViewTwo setBackgroundColor:[UIColor colorWithRed:0.976 green:0.365 blue:0.29 alpha:1]];
    bottomViewTwo.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"initialBkg"]];
    [self.previewView.layer addSublayer:bottomViewTwo.layer];
    
    UIButton *camerabutton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-50, CGRectGetHeight(self.view.bounds)-175, 100, 100)];
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
    
    UIButton *fillButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-50, CGRectGetHeight(self.view.bounds)-175, 100, 100)];
    [fillButton setImage:[UIImage imageNamed:@"fillButton"] forState:UIControlStateNormal];
    [fillButton addTarget:self action:@selector(uploadPhoto) forControlEvents:UIControlEventTouchUpInside];
    [fillButton.layer setCornerRadius:20.0];
    
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, -60, CGRectGetWidth(self.view.frame), 60)];
    [topView setBackgroundColor:[UIColor colorWithRed:0.941 green:0.353 blue:0.643 alpha:1]];
    [self.imageSelectedView addSubview:topView];
    //[topView addSubview:cancelPhoto];

    
    self.cancelPhoto = [[UIButton alloc]initWithFrame:CGRectMake(44, 50, 50, 50)];
    //[self.cancelPhoto setImage:[UIImage imageNamed:@"cancelPhoto"] forState:UIControlStateNormal];
    [self.cancelPhoto setTitle:@"retake" forState:UIControlStateNormal];
    [self.cancelPhoto addTarget:self action:@selector(cancelSelectedPhoto:) forControlEvents:UIControlEventTouchUpInside];
    //[self.imageSelectedView addSubview:self.cancelPhoto];
    
    UITapGestureRecognizer *cancel = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelectedPhoto:)];
    [topView addGestureRecognizer:cancel];
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-190, CGRectGetWidth(self.view.frame), 150)];
    //[bottomView setBackgroundColor:[UIColor colorWithRed:0.937 green:0.204 blue:0.733 alpha:1]];
    bottomView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"initialBkg"]];
    [bottomView addSubview:self.cancelPhoto];
    [self.imageSelectedView addSubview:bottomView];
    [self.imageSelectedView addSubview:fillButton];
    
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(captionDrag:)];
    [self.capturedImageView addGestureRecognizer:drag];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appClosed) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                     shadow, NSShadowAttributeName,
                                                                     [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    self.title = @"Stockd";
    
}

-(void)appClosed {
    
     [[SlideNavigationController sharedInstance] setEnableSwipeGesture:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    
    [_recorder startRunningSession];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[_recorder startRunningSession];
}


-(void)viewWillDisappear:(BOOL)animated {
    NSLog(@"Disappear");
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidEnterBackgroundNotification];
    [[SlideNavigationController sharedInstance] setEnableSwipeGesture:YES];
    
      
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        _recorder = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
        });
    });
    
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
    
}
- (void) initCaption{
    
    caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
    
    // Caption
    caption = [[UITextField alloc] initWithFrame:CGRectMake(0,self.capturedImageView.frame.size.height/2,self.capturedImageView.frame.size.width,34)];
    caption.backgroundColor = [[UIColor colorWithRed:0.318 green:0.89 blue:0.761 alpha:1] colorWithAlphaComponent:1.00];
    caption.textAlignment = NSTextAlignmentCenter;
    caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    caption.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    caption.textColor = [UIColor whiteColor];
    caption.alpha = 0;
    caption.tintColor = [UIColor whiteColor];
    caption.delegate = self;
    caption.font = [UIFont fontWithName:@"BELLABOO-Regular" size:18];
    caption.text = @"Half";
    [caption setEnabled:NO];
    caption.allowsEditingTextAttributes = NO;
    caption.layer.cornerRadius = 15;
    
    [self.capturedImageView addSubview:caption];
}

- (void) captionDrag: (UIGestureRecognizer*)gestureRecognizer{
    
    CGPoint translation = [gestureRecognizer locationInView:self.view];
    
    float yPosition = translation.y;
    
    float upperLimit = 16;
    float lowerLimit = self.view.frame.size.height-146-caption.frame.size.height/2;
    
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

        if (yPosition < 205) {
            caption.text = @"Full";
        }
        if (yPosition > 205) {
            caption.text = @"Half";
        }
    }
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
            
            [self showFullMeter];
        
            NSLog(@"Got Pic: %@", image);
            self.capturedImageView.image = image;
           self.selectedImage = self.capturedImageView.image;
            [self.view addSubview:self.imageSelectedView];
            
            self.navigationController.navigationBar.userInteractionEnabled = YES;
            
        }
    }];
}

-(IBAction)cancelSelectedPhoto:(id)sender {
    
    NSLog(@"Called");
    [self.imageSelectedView removeFromSuperview];
    
    self.navigationController.navigationBar.hidden = NO;
    
    [[SlideNavigationController sharedInstance] setEnableSwipeGesture:YES];
    
    
}

-(void)uploadPhoto {

    NSString *uuidStr = [[NSUUID UUID] UUIDString];
//
//    NSLog(@"upload");
//    [ProgressHUD show:nil Interaction:NO];
//    self.filePicture = [PFFile fileWithName:@"picture.png" data:UIImagePNGRepresentation(self.selectedImage)];
//    [self.filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//       
//        if (error) {
//            [ProgressHUD showError:@"Network Error"];
//        }
//        else {
//        
//            PFObject *order = [PFObject objectWithClassName:@"Orders"];
//            [order setObject:self.filePicture forKey:@"image"];
//            [order setObject:[PFUser currentUser] forKey:@"user"];
//            [order setObject:caption.text forKey:@"orderSize"];
//            [order setObject:uuidStr forKey:@"orderNumber"];
//            [order saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                if (error) {
//                    [ProgressHUD showError:@"Error"];
//                }
//                else {
                    [self pushViewToAddPackages:uuidStr];
//                }
//            }];
//        }
//    }];
}

-(void)pushViewToAddPackages:(NSString *)orderNumber {
    
    AddPackagesTableViewController *apvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddPackages"];
    apvc.picture = self.filePicture;
    apvc.orderNumber = orderNumber;
    apvc.food = self.food;
    apvc.drinks = self.drinks;
    [self.navigationController pushViewController:apvc animated:YES];
    
}


-(void)queryForFoodPackages {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Packages"];
    [query whereKey:@"packageCategory" equalTo:@"Food"];
    [query orderByAscending:@"packageName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
        }
        else {
            self.food = objects;
        }
    }];

}

-(void)queryForDrinkPackages {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Packages"];
    [query whereKey:@"packageCategory" equalTo:@"Drinks"];
    [query orderByAscending:@"packageName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
        }
        else {
            self.drinks = objects;
        }
    }];
}



@end
