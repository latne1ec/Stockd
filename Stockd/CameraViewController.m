//
//  CameraViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/1/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

-(BOOL)prefersStatusBarHidden {
    
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePicker = [[PKImagePickerViewController alloc]init];
    
    [self.imagePicker.view addSubview:self.menuButton];
    
    [self.imagePicker.view addSubview:self.navigationController.navigationBar];
    
    self.imagePicker.delegate = self;
    
    //Nav Bar Color
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.941 green:0.353 blue:0.643 alpha:1]];
    
    self.navigationController.navigationBar.translucent = NO;
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];

}

-(void)viewWillAppear:(BOOL)animated {
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    //self.navigationController.navigationBar.hidden = NO;
    [self presentViewController:self.imagePicker animated:NO completion:nil];
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

@end
