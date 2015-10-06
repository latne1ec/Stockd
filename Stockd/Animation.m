//
//  Animation.m
//  Hivee
//
//  Created by Carlos on 7/19/15.
//  Copyright (c) 2015 Appartar. All rights reserved.
//

#import "Animation.h"

@interface Animation()
@property(nonatomic) float w, h;
@property(nonatomic,strong) UILabel *stockd;
@end

@implementation Animation

-(void)load
{
    
    _w = self.frame.size.width;
    _h = self.frame.size.height;
    
    UIImage *background = [UIImage imageNamed:@"initialBkg@2x.png"];
    float bw = [background size].width;
    float bh = [background size].height;
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(_w/2.0f-bw/2.0f,_h/2.0f-bh/2.0f,bw,bh)];
    backgroundView.backgroundColor = [UIColor clearColor];
    backgroundView.image = background;
    [self addSubview:backgroundView];
    
    UILabel *stockd = [[UILabel alloc] initWithFrame:CGRectMake(0,_h*0.35,_w,_h*0.15)];
    stockd.backgroundColor = [UIColor clearColor];
    stockd.textAlignment = NSTextAlignmentCenter;
    stockd.transform = CGAffineTransformMakeScale(0.00000001f,0.00000001f);
    stockd.textColor = [UIColor whiteColor];
    stockd.font = [UIFont fontWithName:@"HelveticaNeue" size:58.0f];
    stockd.text = @"STOCKD";
    [self addSubview:stockd];
    
    _stockd = stockd;
    
    id images = @[@"Apple@2x.png",@"Bread@2x.png",@"Chicken@2x.png",@"Donut@2x.png",@"Fish@2x.png"];
    NSMutableArray *arr = [NSMutableArray array];
    
    
    bw = [[UIImage imageNamed:images[1]] size].width/3.8f;
    bh = [[UIImage imageNamed:images[1]] size].height/3.8f;
    
    for(int i=0; i<[images count]; i++){
        UIImage *icon = [UIImage imageNamed:images[i]];

        float inicio = (_w/2.0f)-(((bw+15)*[images count])/2.0f)+(bw/6.0f);
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(inicio+(bw+15)*i,_h/2.0f-bh/2.0f+(_h*0.1f),bh,bw)];
        iconView.backgroundColor = [UIColor clearColor];
        iconView.image = icon;
        iconView.transform = CGAffineTransformMakeScale(0.00000001f,0.00000001f);
        [self addSubview:iconView];
        [arr addObject:iconView];
    }
    
         float __block lastTime = 0;
    
    
    [UIView animateWithDuration:0.1f delay:0.1f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:
     ^{
         
         [_stockd setTransform:CGAffineTransformMakeScale(1.4f, 1.4f)];
         
     } completion:^(BOOL finished) {

         
         [UIView animateWithDuration:0.075f delay:0.0f
                             options:UIViewAnimationOptionCurveEaseInOut
                          animations:
          ^{
              
              [_stockd setTransform:CGAffineTransformMakeScale(1.0f, 1.0f)];
              
          } completion:^(BOOL finished) {
              
          }];
         
         

    
    for(int i=0; i<[images count]; i++){
        
        lastTime = ((0.15f*i)+0.5f);
        
        [UIView animateWithDuration:0.1f delay:((0.15f*i)+0.1f)
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:
         ^{
             
             [(UIView*)arr[i] setTransform:CGAffineTransformMakeScale(1.4f, 1.4f)];
             
         } completion:^(BOOL finished) {
             
             [UIView animateWithDuration:0.075f delay:0.0f
                                 options:UIViewAnimationOptionCurveEaseInOut
                              animations:
              ^{
                  
                  [(UIView*)arr[i] setTransform:CGAffineTransformMakeScale(1.0f, 1.0f)];
                  
              } completion:^(BOOL finished) {
                  
              }];
             
         }];
     }
    }];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        
        
        [UIView animateWithDuration:0.25f delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:
         ^{
             
             [(UIView*)backgroundView setAlpha:0.0f];
             
             _stockd.frame = CGRectMake(0,_h*0.35-_h,_w,_h*0.15);
             
             for(int i=0; i<[images count]; i++){
                [(UIView*)arr[i] setFrame:CGRectMake([arr[i] frame].origin.x,[arr[i] frame].origin.y+_h,[arr[i] frame].size.width,[arr[i] frame].size.height)];
             }
             
         } completion:^(BOOL finished) {
         
             [self removeFromSuperview];
         
         }];
        
    });

}

@end
