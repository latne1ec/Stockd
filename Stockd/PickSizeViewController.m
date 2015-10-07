//
//  PickSizeViewController.m
//  Stockd
//
//  Created by Evan Latner on 10/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "PickSizeViewController.h"

@interface PickSizeViewController ()

@end

@implementation PickSizeViewController

@synthesize caption;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"select size";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(closeTheController)];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    

    UIImage *image1 = [UIImage imageNamed:@""];
    UIImage *image2 = [UIImage imageNamed:@""];
    UIImage *image3 = [UIImage imageNamed:@""];
    UIImage *image4 = [UIImage imageNamed:@""];
    
    UIButton *pickButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-50, CGRectGetHeight(self.view.bounds)-165, 100, 100)];
    [pickButton setImage:[UIImage imageNamed:@"pickButton"] forState:UIControlStateNormal];
    [pickButton addTarget:self action:@selector(setPackageSize) forControlEvents:UIControlEventTouchUpInside];
    [pickButton.layer setCornerRadius:20.0];
    [self.view addSubview:pickButton];


    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(captionDrag:)];
    [self.view addGestureRecognizer:drag];
    
    
    [self showSlider];
    
}

-(void)showSlider {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [self imageViewTapped:tap];
    
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

- (void)captionDrag:(UIGestureRecognizer*)gestureRecognizer{
    
    
    [UIView animateWithDuration:0.06 animations:^{
        
        //self.toastTwo.alpha = 0.0;
        
    } completion:^(BOOL finished) {
    }];
    
    
    
    CGPoint translation = [gestureRecognizer locationInView:self.view];
    
    float yPosition = translation.y;
    float upperLimit = 16;
    float lowerLimit = self.view.frame.size.height-110-caption.frame.size.height/2;
    
    if(yPosition<upperLimit){
        yPosition = upperLimit;
    } else if(yPosition>lowerLimit){
        yPosition = lowerLimit;
    }
    
    if(yPosition < caption.frame.size.height/2){
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  caption.frame.size.height/2);
    } else if(self.view.frame.size.height < yPosition + caption.frame.size.height/2){
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  self.view.frame.size.height - caption.frame.size.height/2);
    } else {
        caption.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2,  yPosition);
        
        
        
        float height = self.view.bounds.size.height;
        
        if (yPosition/height > 0) {
            caption.text = @"Extra Large";
        }
        if (yPosition/height > 0.2) {
            caption.text = @"Large";
        }
        if (yPosition/height > 0.45) {
            caption.text = @"Medium";
        }
        if (yPosition/height > 0.65f) {
            caption.text = @"Small";
        }
    }
}


- (void) initCaption{
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"hasRanAppYoTwo"] isEqualToString:@"yes"]) {
        NSLog(@"hi");
        //self.toastTwo.alpha = 0.0;
    }
    else {
        //self.toastTwo.alpha = 1.0;
        //[[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"hasRanAppYoTwo"];
    }
    
    // Caption
    caption.alpha = ([caption.text isEqualToString:@""]) ? 0 : caption.alpha;
    
    if([UIScreen mainScreen].bounds.size.height <= 480.0) {
        NSLog(@"iphone 4");
        caption = [[UITextField alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height/2+0,self.view.frame.size.width,34)];
        
    }
    
    else if([UIScreen mainScreen].bounds.size.height == 568.0) {
        NSLog(@"iphone 5");
        //self.toastTwo.translatesAutoresizingMaskIntoConstraints = YES;
        //self.toastTwo.center = self.view.center;
        caption = [[UITextField alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height/2+100,self.view.frame.size.width,34)];
    }
    else {
        //iPhone 6
        NSLog(@"IPHONE 6");
        //self.toastTwo.translatesAutoresizingMaskIntoConstraints = YES;
        //self.toastTwo.center = self.view.center;
        caption = [[UITextField alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height/2+75,self.view.frame.size.width,34)];
    }
    
    caption.backgroundColor = [[UIColor colorWithRed:0.318 green:0.89 blue:0.761 alpha:1] colorWithAlphaComponent:1.00];
    caption.textAlignment = NSTextAlignmentCenter;
    caption.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    caption.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    caption.textColor = [UIColor whiteColor];
    caption.alpha = 0;
    caption.tintColor = [UIColor whiteColor];
    caption.delegate = self;
    caption.font = [UIFont fontWithName:@"BELLABOO-Regular" size:18];
    caption.text = @"Small";
    [caption setEnabled:NO];
    caption.allowsEditingTextAttributes = NO;
    caption.layer.cornerRadius = 15;
    
    [self.view addSubview:caption];
    
}


-(void)setPackageSize {
    
    
    
}

-(void)closeTheController {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
    
}


@end
