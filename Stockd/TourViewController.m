//
//  TourViewController.m
//  Stockd
//
//  Created by Carlos on 7/1/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#import "TourViewController.h"

@interface TourViewController()
@property(nonatomic,strong) UIScrollView *pagedTour;
@property(nonatomic,strong) UIPageControl *pageControl;
@property(nonatomic) int pages;
@property(nonatomic) float w, h;
@end

@implementation TourViewController



-(void)viewDidLoad
{
    
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"hasRanApp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _w = self.view.frame.size.width;
    _h = self.view.frame.size.height;
    
    UIView *whiteSquare = [[UIView alloc] initWithFrame:CGRectMake(0, _h/2.0f, _w, _h/2.0f)];
    whiteSquare.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteSquare];
    
    
    _pages = 4;
    _pagedTour = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _pagedTour.contentSize = CGSizeMake(_pagedTour.frame.size.width*_pages, _pagedTour.frame.size.height);
    _pagedTour.showsHorizontalScrollIndicator = NO;
    _pagedTour.showsVerticalScrollIndicator = NO;
    _pagedTour.delegate = self;
    _pagedTour.bounces = YES;
    _pagedTour.pagingEnabled = YES;
    [self.view addSubview:_pagedTour];
    
    UIFont *font = [UIFont fontWithName:@"BELLABOO" size:48];
    NSString *message1 = @"SNAP A PHOTO OF WHAT YOU WANT STOCKED";
    NSString *message2 = @"CHOOSE WHETHER YOU WANT TO FILL IT FULL OR HALF";
    NSString *message3 = @"PICK FROM YUMMY PRESELECTED FOODS";
    NSString *message4 = @"THAT'S IT!\n#GETSTOCKD";
    
    UIImage *image1 = [UIImage imageNamed:@"TourImage1.png"];
    UIImage *image2 = [UIImage imageNamed:@"TourImage2.png"];
    UIImage *image3 = [UIImage imageNamed:@"TourImage3.png"];
    
    NSString *thankYouMessage = @"THANK YOU!\nYOU'LL BE NOTIFIED WHEN YOUR DELIVERY IS ON THE WAY!";
    
    
    UIView *page1 = [[UIView alloc] initWithFrame:self.view.bounds];
    page1.backgroundColor = [UIColor clearColor];
    [_pagedTour addSubview:page1];
    
    float maxWidth = _w;
    float scaleTo = maxWidth/[image1 size].width;
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(_w/2.0f-([image1 size].width*scaleTo)/2.0f, ((_h/2.0f)-([image1 size].height*scaleTo)), ([image1 size].width*scaleTo), ([image1 size].height*scaleTo))];
    imageView1.backgroundColor = [UIColor clearColor];
    imageView1.image = image1;
    [page1 addSubview:imageView1];
    
    
    UILabel *page1Message = [[UILabel alloc] initWithFrame:CGRectMake(75, _h/2.0f, _w-150, _h/2.0f)];
    page1Message.text = message1;
    page1Message.numberOfLines = 0;
    page1Message.font = font;
    page1Message.textColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    page1Message.textAlignment = NSTextAlignmentCenter;
    [page1 addSubview:page1Message];
    
    UIView *page2 = [[UIView alloc] initWithFrame:CGRectMake(_w, 0, _w, _h)];
    page2.backgroundColor = [UIColor clearColor];
    [_pagedTour addSubview:page2];
    
    scaleTo = maxWidth/[image2 size].width;
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(_w/2.0f-([image2 size].width*scaleTo)/2.0f, ((_h/2.0f)-([image2 size].height*scaleTo)), ([image2 size].width*scaleTo), ([image2 size].height*scaleTo))];
    imageView2.backgroundColor = [UIColor clearColor];
    imageView2.image = image2;
    [page2 addSubview:imageView2];
    
    whiteSquare = [[UIView alloc] initWithFrame:CGRectMake(0, _h/2.0f, _w, _h/2.0f)];
    whiteSquare.backgroundColor = [UIColor whiteColor];
    [page2 addSubview:whiteSquare];
    
    UILabel *page2Message = [[UILabel alloc] initWithFrame:CGRectMake(75, _h/2.0f, _w-150, _h/2.0f)];
    page2Message.text = message2;
    page2Message.numberOfLines = 0;
    page2Message.font = font;
    page2Message.textColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    page2Message.textAlignment = NSTextAlignmentCenter;
    [page2 addSubview:page2Message];
    
    UIView *page3 = [[UIView alloc] initWithFrame:CGRectMake(_w*2, 0, _w, _h)];
    page3.backgroundColor = [UIColor clearColor];
    [_pagedTour addSubview:page3];
    
    scaleTo = maxWidth/[image3 size].width;
    
    UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(_w/2.0f-([image3 size].width*scaleTo)/2.0f, ((_h/2.0f)-([image3 size].height*scaleTo)), ([image3 size].width*scaleTo), ([image3 size].height*scaleTo))];
    imageView3.backgroundColor = [UIColor clearColor];
    imageView3.image = image3;
    [page3 addSubview:imageView3];
    
    whiteSquare = [[UIView alloc] initWithFrame:CGRectMake(0, _h/2.0f, _w, _h/2.0f)];
    whiteSquare.backgroundColor = [UIColor whiteColor];
    [page3 addSubview:whiteSquare];
    
    UILabel *page3Message = [[UILabel alloc] initWithFrame:CGRectMake(75, _h/2.0f, _w-150, _h/2.0f)];
    page3Message.text = message3;
    page3Message.numberOfLines = 0;
    page3Message.font = font;
    page3Message.textColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    page3Message.textAlignment = NSTextAlignmentCenter;
    [page3 addSubview:page3Message];
    
    UIView *page4 = [[UIView alloc] initWithFrame:CGRectMake(_w*3, 0, _w, _h)];
    page4.backgroundColor = [UIColor clearColor];
    [_pagedTour addSubview:page4];
    
    whiteSquare = [[UIView alloc] initWithFrame:CGRectMake(0, _h/2.0f, _w, _h/2.0f)];
    whiteSquare.backgroundColor = [UIColor whiteColor];
    [page4 addSubview:whiteSquare];
    
    UILabel *page4Message = [[UILabel alloc] initWithFrame:CGRectMake(75, _h/2.0f-_h/10.0f, _w-150, _h/2.0f)];
    page4Message.text = message4;
    page4Message.numberOfLines = 0;
    page4Message.font = font;
    page4Message.textColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    page4Message.textAlignment = NSTextAlignmentCenter;
    [page4 addSubview:page4Message];
    
    UILabel *page4ThankYou = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, _w-150, _h/2.0f)];
    page4ThankYou.text = thankYouMessage;
    page4ThankYou.numberOfLines = 0;
    page4ThankYou.font = font;
    page4ThankYou.textColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    page4ThankYou.textAlignment = NSTextAlignmentCenter;
    [page4 addSubview:page4ThankYou];
    
    
    
    
    float buttonWidth = _w*0.5f;
    float buttonHeight = 45.0f;
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    
    startButton.backgroundColor = [UIColor whiteColor];
    startButton.frame = CGRectMake(_w/2.0f-buttonWidth/2.0f, _h/2.0f+[self compare:180], buttonWidth, buttonHeight);
    [startButton addTarget:self action:@selector(getStarted:) forControlEvents:UIControlEventTouchUpInside];
    [page4 addSubview:startButton];
    
    UILabel *buttonLabel = [[UILabel alloc] initWithFrame:startButton.bounds];
    buttonLabel.text = @"START";
    buttonLabel.numberOfLines = 0;
    buttonLabel.font = font;
    buttonLabel.userInteractionEnabled = NO;
    buttonLabel.textColor = UIColorFromRGB(0x00E676);
    buttonLabel.textAlignment = NSTextAlignmentCenter;
    [startButton addSubview:buttonLabel];
    
    CALayer *btn1 = [startButton layer];
    [btn1 setMasksToBounds:YES];
    [btn1 setCornerRadius:5.0f];
    [btn1 setBorderWidth:1.5f];
    [btn1 setBorderColor:UIColorFromRGB(0x00E676).CGColor];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, _h-80, _w, 80)];
    _pageControl.currentPage = 0;
    _pageControl.numberOfPages = _pages;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0 alpha:0.2f];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0 alpha:0.5f];
    [self.view addSubview:_pageControl];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}



-(float)compare:(float)cual
{
    return (self.view.frame.size.height/685)*cual;
}

-(IBAction)getStarted:(id)sender
{
    NSLog(@"GET STARTED!");
}

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
}

@end
