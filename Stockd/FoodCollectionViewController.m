//
//  FoodCollectionViewController.m
//  Stockd
//
//  Created by Alex Consel on 2016-07-18.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "FoodCollectionViewController.h"
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TSMessage.h"
#import "ProgressHUD.h"
#import "PackageDetailViewController.h"
#import "PackageCollectionViewCell.h"
#include "PackageCollectionViewLayout.h"
#import "PackageDetailCollectionViewController.h"
#include "OrderView.h"

@interface FoodCollectionViewController ()

@property (nonatomic, strong) PFRelation *foodRelation;
@property (nonatomic, strong) NSArray *food;
@property (nonatomic, strong) NSArray *drinks;

@property (nonatomic, strong) OrderView *orderView;

@end

@implementation FoodCollectionViewController

@synthesize tappedMenu;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.collectionViewLayout = [[PackageCollectionViewLayout alloc] init];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    
    self.title = @"Food";
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.collectionView.layer.masksToBounds = YES;
    self.collectionView.clipsToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialBkg"]];
    [self.collectionView setBackgroundView:imageView];
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    [self queryForFoodPackages];
    
}


-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationItem.hidesBackButton = YES;
    
    if (!_orderView){
        _orderView = [[OrderView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, self.view.frame.size.height-100)];
        _orderView.parentViewController = self;
        [self.view addSubview:_orderView];
    }
    
    [_orderView update];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)reloadTheTable {
    
    [self.collectionView reloadData];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // Return the number of sections.
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.food.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PackageCollectionViewCell *cell = (PackageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"TheCell" forIndexPath:indexPath];
    cell.isOnlyName = YES;
    cell.isEven = (indexPath.row % 2 == 0);
    cell.showTopLine = (indexPath.row < 2);
    
    [cell layoutIfNeeded];
    
    PFObject *object = [self.food objectAtIndex:indexPath.row];
    cell.packageLabel.text = [object objectForKey:@"packageName"];
    
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    //NSLog(@"Tapped Row %ld", (long)indexPath.row);
    PFObject *object = [self.food objectAtIndex:indexPath.row];
    NSString *packageName = [object objectForKey:@"packageName"];
    //NSLog(@"Package Name: %@", packageName);
    
    PackageDetailCollectionViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PackageDetail"];
    destViewController.packageName = packageName;
    destViewController.packageType = @"Food";
    
    [self.navigationController pushViewController:destViewController animated:YES];
    [ProgressHUD show:nil];
    
    //    UINavigationController *navigationController =
    //    [[UINavigationController alloc] initWithRootViewController:destViewController];
    //    UIBarButtonItem *newBackButton =
    //    [[UIBarButtonItem alloc] initWithTitle:@"Address Info"
    //                                     style:UIBarButtonItemStylePlain
    //                                    target:nil
    //                                    action:nil];
    //    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
    //    [ProgressHUD show:nil];
    //    [self.navigationController presentViewController:navigationController animated:YES completion:^{
    //    }];
    
}

-(void)queryForFoodPackages {
    
    [ProgressHUD show:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Packages"];
    [query whereKey:@"packageCategory" equalTo:@"Food"];
    [query orderByAscending:@"packageName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:@"Error"];
        }
        
        else {
            [ProgressHUD dismiss];
            self.food = objects;
            [self.collectionView reloadData];
        }
    }];
}

@end
