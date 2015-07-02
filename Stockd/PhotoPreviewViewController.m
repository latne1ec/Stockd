//
//  PhotoPreviewViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/2/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "PhotoPreviewViewController.h"

@interface PhotoPreviewViewController ()

@end

@implementation PhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _image.image = _thePhoto;
    
    [self.view addSubview:_image];
    
    
}

@end
