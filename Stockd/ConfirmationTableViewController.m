//
//  ConfirmationTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/8/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "ConfirmationTableViewController.h"
#import "ProfileTableViewController.h"
#import "InitialViewController.h"

@interface ConfirmationTableViewController ()

@end

@implementation ConfirmationTableViewController

@synthesize firstCell, secondCell, thirdCell, fourthCell;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"Stockd";
    
    self.tableView.tableFooterView = [UIView new];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"initialBkg"]];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialBkg"]];
    [self.tableView setBackgroundView:imageView];
    
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.layer.masksToBounds = YES;
    self.tableView.clipsToBounds = YES;
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                     shadow, NSShadowAttributeName,
                                                                     [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    
    self.navigationController.navigationItem.hidesBackButton = YES;
    
    CALayer *btn = [self.homeButton layer];
    [btn setMasksToBounds:YES];
    [btn setCornerRadius:5.0f];
    
    NSString *streetName = [[PFUser currentUser] objectForKey:@"streetName"];
    NSString *cityName = [[PFUser currentUser] objectForKey:@"userCity"];
    NSString *zipCode = [[PFUser currentUser] objectForKey:@"zipCode"];
    
    self.streetNameLabel.text = streetName;
    self.cityStateZipLabel.text = [NSString stringWithFormat:@"%@, %@", cityName, zipCode];
    self.totalPriceLabel.text = [NSString stringWithFormat:@"$%.02f", _subtotal];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.navigationItem setHidesBackButton:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    
    self.navigationItem.hidesBackButton = YES;
    [self.navigationItem setHidesBackButton:YES];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) return firstCell;
    if (indexPath.row == 1) return secondCell;
    if (indexPath.row == 2) return thirdCell;
    if (indexPath.row == 3) {
        fourthCell.separatorInset = UIEdgeInsetsMake(0.f, 10000.0f, 0.f, 0.0f);
    }
    
    if (indexPath.row == 3) return fourthCell;
    
    return nil;
}

- (IBAction)homeButtonTapped:(id)sender {

    ProfileTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Camera"];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    CATransition *transition = [CATransition animation];
    [transition setType:kCATransitionFade];
    [self.navigationController.view.layer addAnimation:transition forKey:@"someAnimation"];
    
    [self.navigationController pushViewController:destViewController animated:NO];
    
    
    [CATransaction commit];

    
}
@end
