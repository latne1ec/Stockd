//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"
#import "FoodTableViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface LeftMenuViewController()

@property(nonatomic,strong) id data;

@end

@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self.slideOutAnimationEnabled = YES;
	
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0x4FD0FF);
	
    UIScrollView *sc = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width-[SlideNavigationController sharedInstance].portraitSlideOffset, self.view.bounds.size.height)];
    
    sc.backgroundColor = [UIColor clearColor];
    
    sc.scrollEnabled = NO;
    
    UIFont *font = [UIFont fontWithName:@"BELLABOO-Regular" size:24];
    
    _data = @[
              @{@"text":@"Home",@"viewC":@"AddPackages"},
              @{@"text":@"Food",@"viewC":@"Food"},
              @{@"text":@"Drinks",@"viewC":@"Drinks"},
              @{@"text":@"21+",@"viewC":@"21+"},
              @{@"text":@"Profile",@"viewC":@"Profile"},
               @{@"text":@"Help",@"viewC":@"Help"}
              ];
    
    float h = 60;
    UILabel *menuLabel;
    float dif = 40;
    for(int i=0; i<[_data count]; i++){
        menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, dif+(i*h), sc.frame.size.width-30, h)];
        menuLabel.text = _data[i][@"text"];
        menuLabel.textColor = [UIColor whiteColor];
        menuLabel.font = font;
        menuLabel.backgroundColor = [UIColor clearColor];
        menuLabel.userInteractionEnabled = NO;
        [sc addSubview:menuLabel];
        
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.backgroundColor = [UIColor clearColor];
        [b addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
        b.frame = menuLabel.frame;
        b.tag = i*-1;
        [sc addSubview:b];
        
    }
    
    float contentHeight = menuLabel.frame.size.height+menuLabel.frame.origin.y;
    if(contentHeight<=sc.frame.size.height){
        contentHeight = sc.frame.size.height+1;
    }
    
    sc.contentSize = CGSizeMake(sc.frame.size.width, contentHeight);
    [self.view addSubview:sc];
    
}

-(void)continueView:(id)sender
{
    
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:sender withSlideOutAnimation:NO andCompletion:nil];
}

-(IBAction)changeView:(id)sender {
 
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    int tag = [sender tag]*-1;
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier: _data[tag][@"viewC"]];
        //int reload = 0;
//    if(_data[tag][@"tapped"]){
//        if([(FoodTableViewController*)vc tappedMenu]){
//            reload = 1;
//        }
//        [(FoodTableViewController*)vc setTappedMenu:_data[tag][@"tapped"]];
//    }
    
    //[[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:NO];
    //[self performSelector:@selector(continueView:) withObject:vc afterDelay:0.1f];
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:NO andCompletion:^{
    
        [vc viewWillAppear:YES];
    }];
    

}

@end
