//
//  AlcoholPolicyViewController.m
//  Stockd
//
//  Created by Evan Latner on 8/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "AlcoholPolicyViewController.h"
#import "UIViewController+ENPopUp.h"
#import "PopupViewController.h"

@interface AlcoholPolicyViewController ()

@end

@implementation AlcoholPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    self.title = @"Alcohol Policy";
    
    UIImage *img = [UIImage imageNamed:@"initialBkg"];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:img]];
    
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    [self showPopup];
    
    self.textview.contentInset = UIEdgeInsetsMake(2.0,0.0,0,0.0);
    
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
- (IBAction)continueButtonTapped:(id)sender {
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)showPopup {
    
    PopupViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Popup"];
    pvc.view.frame = CGRectMake(0, 0, 270.0f, 180.0f);
    [self presentPopUpViewController:pvc];
    
    [pvc.submitButton addTarget:self action:@selector(dismissPopUpViewController) forControlEvents:UIControlEventTouchUpInside];
    
}


@end
