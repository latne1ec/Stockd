//
//  PickSizeViewController.m
//  Stockd
//
//  Created by Evan Latner on 10/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "PickSizeViewController.h"
#import "CartTableViewController.h"
#import "AppDelegate.h"

@interface PickSizeViewController ()

@property (nonatomic) int packageSize;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation PickSizeViewController

@synthesize caption;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    _packageSize = _appDelegate.packageSize;
    
    self.title = @"select size";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(closeTheController)];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    

//    UIImage *image1 = [UIImage imageNamed:@""];
//    UIImage *image2 = [UIImage imageNamed:@""];
//    UIImage *image3 = [UIImage imageNamed:@""];
//    UIImage *image4 = [UIImage imageNamed:@""];
    
    
    
    UIButton *pickButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-50, CGRectGetHeight(self.view.bounds)-210, 100, 100)];
    [pickButton setImage:[UIImage imageNamed:@"pickButton"] forState:UIControlStateNormal];
    [pickButton addTarget:self action:@selector(setPackageSize) forControlEvents:UIControlEventTouchUpInside];
    [pickButton.layer setCornerRadius:20.0];
    [self.view addSubview:pickButton];
    
    self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2-60, CGRectGetHeight(self.view.bounds)-145, 200, 100)];
    
    self.priceLabel.text = [NSString stringWithFormat:@"Price: $%0.2f", _currentCartPrice];
    self.priceLabel.textColor = [UIColor whiteColor];
    self.priceLabel.font = [UIFont fontWithName:@"BELLABOO-Regular" size:20];
    [self.view addSubview:self.priceLabel];
    
    

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
        
        
        [self updatePackageSize: yPosition];
        
    }
}

-(void) updatePackageSize: (float) yPosition{
    NSLog(@"yPosition: %f", yPosition);
    float height = self.view.bounds.size.height;
    
    if (yPosition/height > 0.65f) {
        caption.text = @"Small";
        _packageSize = 1;
        self.priceLabel.text = [NSString stringWithFormat:@"Price: $%0.2f", _currentCartPrice];
    }else if (yPosition/height > 0.45) {
        caption.text = @"Medium";
        _packageSize = 2;
        self.priceLabel.text = [NSString stringWithFormat:@"Price: $%0.2f", _currentCartPrice*2];
    }else if (yPosition/height > 0.2) {
        caption.text = @"Large";
        _packageSize = 3;
        self.priceLabel.text = [NSString stringWithFormat:@"Price: $%0.2f", _currentCartPrice*3];
    }else if (yPosition/height >= 0) {
        caption.text = @"Extra Large";
        _packageSize = 4;
        self.priceLabel.text = [NSString stringWithFormat:@"Price: $%0.2f", _currentCartPrice*4];
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
    caption.text = @"C";
    [caption setEnabled:NO];
    caption.allowsEditingTextAttributes = NO;
    caption.layer.cornerRadius = 15;
    
    CGRect frame = caption.layer.frame;
    frame.origin.y = self.view.bounds.size.height-(self.view.bounds.size.height * _appDelegate.packageSize/4);
    caption.layer.frame = frame;
    
    [self updatePackageSize:caption.layer.frame.origin.y];
    
    [self.view addSubview:caption];
    
}


-(void)setPackageSize {
    _appDelegate.packageSize = _packageSize;
    
    for (NSString* packagesKey in [_appDelegate package_itemsDictionary]){
        Boolean modifiedFlag = false;
        for (NSString* itemNameKey in [[_appDelegate package_itemsDictionary] valueForKey:packagesKey]){
            if ([[[[_appDelegate package_itemsDictionary] valueForKey:packagesKey] valueForKey:itemNameKey] hasBeenModified] == true){
                modifiedFlag = true;
                break;
            }
        }
        if (modifiedFlag){
            continue;
        }
        
        for (NSString* itemNameKey in [[_appDelegate package_itemsDictionary] valueForKey:packagesKey]){
            [[[[_appDelegate package_itemsDictionary] valueForKey:packagesKey] valueForKey:itemNameKey] setItemQuantity:[_appDelegate packageSize]];
        }
    }
    
    [self closeTheController];
    
}

-(void)closeTheController {
    
    CartTableViewController *cart  = [self.storyboard instantiateViewControllerWithIdentifier:@"Cart"];
    NSString *stringWithoutSpaces = [self.priceLabel.text
                                     stringByReplacingOccurrencesOfString:@"Price: $" withString:@""];
    
    cart.finalTotal = [stringWithoutSpaces floatValue];
    NSLog(@"Final Price: %0.2f", [stringWithoutSpaces floatValue]);
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}


@end
