//
//  AddPackagesTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "AddPackagesTableViewController.h"
#import "CameraViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "AppDelegate.h"
#import "InitialViewController.h"
#import "AppDelegate.h"
#include "CartItemObject.h"


@interface AddPackagesTableViewController ()

@property (nonatomic, strong) NSArray *booze;
@property (nonatomic) int oldPosition;
@property (nonatomic) int position, counts;
@property (nonatomic, strong) NSMutableDictionary *itemsDictionary;
@property (nonatomic, strong) NSString *beerItem;
@property (nonatomic, strong) NSString *liquorItem;

@property (nonatomic, strong) UIImageView *toast;
@property (nonatomic, strong) UIImage *toastPic;

@property (nonatomic, strong) AppDelegate *appDelegate;




@end

@implementation AddPackagesTableViewController

- (void)viewDidLoad {
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    [super viewDidLoad];
    _oldPosition = -1;
    _position = -1;
    
    //    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
    //                                                                     [UIColor whiteColor], NSForegroundColorAttributeName,
    //                                                                     shadow, NSShadowAttributeName,
    //                                                                     [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    //    PFQuery *query = [PFQuery queryWithClassName:@"Orders"];
    //    [query whereKey:@"orderNumber" equalTo:self.orderNumber];
    //    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
    //        if (error) {
    //
    //        }
    //        else {
    //            self.order = object;
    //            //NSLog(@"Order: %@", self.order);
    //        }
    //    }];
    
    
    if ([PFUser currentUser]) {
        
        [self queryForDrinkPackages];
        [self queryForFoodPackages];
    }
    else {
        
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
        
        InitialViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"InitialVC"];
        [self.navigationController pushViewController:ivc animated:NO];
        [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
        
    }
    
    
    self.title = @"Add Packages";
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.frame = CGRectMake(0, -60, self.view.frame.size.width, self.view.frame.size.height);
    
    _counts = 0;
    
    self.tableView.tableFooterView = [UIView new];
    
    //Nav Bar Back Button Color
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
    //                                                                             style:UIBarButtonItemStylePlain
    //                                                                            target:self
    //                                                                            action:@selector(closeTheController)];
    
    CartButton *btn =  [CartButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,0,25,25);
    [btn addTarget:self action:@selector(goToCartScreen) forControlEvents:UIControlEventTouchUpInside];
    [btn load];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = barBtn;
    
    //[[UIImage imageNamed:@"cartIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.layer.masksToBounds = YES;
    //self.tableView.clipsToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialBkg"]];
    [self.tableView setBackgroundView:imageView];
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    [self queryForFoodPackages];
    [self queryForDrinkPackages];
    [self queryForBoozePackages];
    [self queryForPackageItems];
    [self getPreselectedBeerItem];
        //[self queryForOrderNumber];
    
    
    NSString *uuidStr = [[NSUUID UUID] UUIDString];
    self.orderNumber = uuidStr;
    
    NSLog(@"dic: %@", [_appDelegate package_itemsDictionary]);
    

}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

-(void)closeTheController {
    
    CameraViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Camera"];
    [self.navigationController pushViewController:cvc animated:NO];
    
}

-(void)goToCartScreen {
    
    if ([_appDelegate package_itemsDictionary].count + [_appDelegate extraPackage_itemsDictionary].count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cart Empty" message:@"Your cart is empty. Add a package or two before checking out!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else {
        
        CartTableViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Cart"];
        //cvc.items = _itemsDictionary;
        
        
//        for (NSString* keyPackageName in cvc.packages){
//            if (![[_appDelegate package_itemsDictionary] valueForKey:keyPackageName]){
//                [[_appDelegate package_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:keyPackageName];
//                for (PFObject* itemPFObj in [cvc.items valueForKey:keyPackageName]){
//                    [[[_appDelegate package_itemsDictionary] valueForKey:keyPackageName] setObject:[NSNumber numberWithInt:1] forKey:itemPFObj[@"itemName"]];
//                }
//            }
//        }
        
//        for (NSString* keyPackageName in self.packages){
//            if (![[_appDelegate package_itemsDictionary] valueForKey:keyPackageName]){
//                [[_appDelegate package_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:keyPackageName];
//                for (PFObject* itemPFObj in [_itemsDictionary valueForKey:keyPackageName]){
//                    [[[_appDelegate package_itemsDictionary] valueForKey:keyPackageName] setObject:[NSNumber numberWithInt:1] forKey:itemPFObj[@"itemName"]];
//                }
//            }
//        }

        
        
        NSLog(@"packageDictionary: %@", [_appDelegate package_itemsDictionary]);
        
        //cvc.packageSize = self.packageSize;
        cvc.packageSize = 1;
        cvc.orderNumber = _orderNumber;
        cvc.beerItem = self.beerItem;
        cvc.liquorItem = self.liquorItem;
        [self.navigationController pushViewController:cvc animated:YES];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad showAnimation];
    
    self.navigationItem.hidesBackButton = YES;
    
    
    
    [self.tableView reloadData];
    
    UIView *headerView = [self.tableView headerViewForSection:0];
    [headerView setNeedsDisplay];
    [headerView setNeedsLayout];
    
    [(CartButton*)[self.navigationItem.rightBarButtonItem customView] changeNumber:(int)[[_appDelegate package_itemsDictionary] count]];
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [ProgressHUD dismiss];
    
    self.toast = nil;
    self.toastPic = nil;
    
    [self.toast removeFromSuperview];
    
    self.toast.alpha = 0.0;
    
    for(UIView* view in self.navigationController.navigationBar.subviews)
    {
        if(view.tag == 9)
        {
            [view removeFromSuperview];
        }
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:@"BELLABOO-Regular" size:22]];
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextAlignment:NSTextAlignmentCenter];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor whiteColor]];
    [[UIButton appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTintColor:[UIColor blackColor]];
    
    if (section == 0) {
        
        if(_position<0){
            [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor clearColor]];
        } else {
            [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor colorWithRed:0.937 green:0.349 blue:0.639 alpha:1]];
        }
        
        return @"Food";
        
    }
    
    if (section == 1) {
        if(_position>=1){
            [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor colorWithRed:0.937 green:0.349 blue:0.639 alpha:1]];
            
        } else {
            [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor clearColor]];
            
        }
        return @"Drinks";
    }
    
    if (section == 2) {
        if(_position>=2){
            [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor colorWithRed:0.937 green:0.349 blue:0.639 alpha:1]];
            
        } else {
            [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor clearColor]];
        }
        
        return @"21+";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = [UIColor clearColor];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //    NSLog(@"Position: %d", _position);
    
    float offsetY = scrollView.contentOffset.y;
    //NSLog(@"Position: %f", offsetY);
    
    _position = 0;
    
    if(offsetY<0){
        _position = 0;
    }
    
    if(offsetY>605.0f){
        _position = 1;
    }
    if(offsetY>918.0f){
        _position = 2;
    }
    
    if(_position!=_oldPosition){
        _oldPosition = _position;
        [self.tableView reloadData];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 42;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.food.count;
    }
    if (section == 1) {
        return self.drinks.count;
    }
    if (section == 2) {
        return self.booze.count;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PackageTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    
    CALayer *btn = [cell.greenBkgView layer];
    if (btn.cornerRadius !=5.0f) {
        [btn setMasksToBounds:YES];
        [btn setCornerRadius:5.0f];
    }
    
    if (indexPath.section == 0) {
        
        PFObject *object = [self.food objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        cell.packageNameLabel.text = [NSString stringWithFormat:@"+ %@", packageName];
        
//        if (![self.packages containsObject:packageName]) {
//            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
//            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
//            
//            
//        } else {
//            
//            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
//            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
//        }
        
        if (![[_appDelegate package_itemsDictionary] valueForKey:packageName]){
                
            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];

            }
            
        else {
            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
        }

        
        
        return cell;
        
    }
    
    if (indexPath.section == 1) {
        PFObject *object = [self.drinks objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        cell.packageNameLabel.text = [NSString stringWithFormat:@"+ %@", packageName];
        
//        if (![self.packages containsObject:packageName]) {
//            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
//            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
//            
//            
//        } else {
//            
//            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
//            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
//        }
       
        if (![[_appDelegate package_itemsDictionary] valueForKey:packageName]){
            
            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            
        }
        
        else {
            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
        }

        
        return cell;
    }
    
    if (indexPath.section == 2) {
        PFObject *object = [self.booze objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        cell.packageNameLabel.text = [NSString stringWithFormat:@"+ %@", packageName];
        
//        if (![self.packages containsObject:packageName]) {
//            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
//            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
//            
//            
//        } else {
//            
//            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
//            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
//        }
        
        if (![[_appDelegate package_itemsDictionary] valueForKey:packageName]){
            
            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            
        }
        
        else {
            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
        }
        
        return cell;
    }

    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    [(CartButton*)[self.navigationItem.rightBarButtonItem customView] changeNumber:6];
    
    
    PackageTableCell *cell = (PackageTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [self showToast];
    
    if (indexPath.section == 0) {
        PFObject *object = [self.food objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
            if (![[_appDelegate package_itemsDictionary] valueForKey:packageName]){
                [[_appDelegate package_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:packageName];
                for (PFObject* itemPFObj in [_itemsDictionary valueForKey:packageName]){
                    [[[_appDelegate package_itemsDictionary] valueForKey:packageName] setObject:[[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity: 1 price:[itemPFObj[@"itemPrice"] floatValue]] forKey:itemPFObj[@"itemName"]];
                }
                cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
                cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
            }
            else {
                [[_appDelegate package_itemsDictionary] removeObjectForKey:packageName];
                cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
                cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            }
        
    }
    
    else if (indexPath.section == 2) {
        PFObject *object = [self.booze objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        
        if (![[_appDelegate package_itemsDictionary] valueForKey:packageName]){
            [[_appDelegate package_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:packageName];
            NSLog(@"PackageName: %@", packageName);
            if ([packageName isEqual:@"Beer"] || [packageName isEqual:@"Liquor"] || [packageName isEqual:@"Wine"]){
                for (PFObject* itemPFObj in [_itemsDictionary valueForKey:packageName]){
                    int t_qt = 0;
                    if ([itemPFObj[@"itemName"] isEqual:@"Bud Light"] || [itemPFObj[@"itemName"] isEqual:@"Absolut"]){
                        t_qt = 1;
                    }
                    [[[_appDelegate package_itemsDictionary] valueForKey:packageName] setObject:[[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity: t_qt price:[itemPFObj[@"itemPrice"] floatValue]] forKey:itemPFObj[@"itemName"]];
                }
            }else{
                for (PFObject* itemPFObj in [_itemsDictionary valueForKey:packageName]){
                    [[[_appDelegate package_itemsDictionary] valueForKey:packageName] setObject:[[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity: 1 price:[itemPFObj[@"itemPrice"] floatValue]] forKey:itemPFObj[@"itemName"]];
                }
            }
            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
        }
        else {
            [[_appDelegate package_itemsDictionary] removeObjectForKey:packageName];
            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
        }
        
    }
    
    
    else {
        
        PFObject *object = [self.drinks objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        
        if (![[_appDelegate package_itemsDictionary] valueForKey:packageName]){
            [[_appDelegate package_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:packageName];
            for (PFObject* itemPFObj in [_itemsDictionary valueForKey:packageName]){
                [[[_appDelegate package_itemsDictionary] valueForKey:packageName] setObject:[[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity: 1 price:[itemPFObj[@"itemPrice"] floatValue]] forKey:itemPFObj[@"itemName"]];
            }

            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
        }
        else {
            [[_appDelegate package_itemsDictionary] removeObjectForKey:packageName];
            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
        }
        
    }
    
    [(CartButton*)[self.navigationItem.rightBarButtonItem customView] changeNumber:(int)[[_appDelegate package_itemsDictionary] count]];
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
            [self.tableView reloadData];
        }
    }];
}

-(void)queryForDrinkPackages {
    
    [ProgressHUD show:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Packages"];
    [query whereKey:@"packageCategory" equalTo:@"Drinks"];
    [query orderByAscending:@"packageName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:@"Error"];
        }
        else {
            [ProgressHUD dismiss];
            self.drinks = objects;
            [self.tableView reloadData];
        }
    }];
}

-(void)queryForBoozePackages {
    
    [ProgressHUD show:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Packages"];
    [query whereKey:@"packageCategory" equalTo:@"21+"];
    [query orderByAscending:@"packageName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:@"Error"];
        }
        else {
            
            [ProgressHUD dismiss];
            self.booze = objects;
            [self.tableView reloadData];
        }
    }];
}

-(void)queryForPackageItems {
    
    _itemsDictionary = [[NSMutableDictionary alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Items"];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        //NSLog(@"objetos: %@",objects);
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        else {
            for(int i=0; i<[objects count]; i++){
                id item = objects[i];
                if(!_itemsDictionary[item[@"itemPackage"]]){
                    _itemsDictionary[item[@"itemPackage"]] = [[NSMutableArray alloc] init];
                }
                [_itemsDictionary[item[@"itemPackage"]] addObject:item];
            }
        }
        //NSLog(@"Dictionary: %@", _itemsDictionary);
    }];
}

-(void)getPreselectedBeerItem {
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (error) {
            [ProgressHUD showError:@"Network Error"];
        }
        else {
            [ProgressHUD dismiss];
            self.beerItem = config[@"preselectedBeerItem"];
        }
    }];
}

-(void)getPreselectedLiquorItem {
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if (error) {
            [ProgressHUD showError:@"Network Error"];
        }
        else {
            [ProgressHUD dismiss];
            self.liquorItem = config[@"preselectedLiquorItem"];
        }
    }];
}

-(void)showToast {
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"hasRanApp3"] isEqualToString:@"yes"]) {
        NSLog(@"hi");
    }
    else {
        
        if ([UIScreen mainScreen].bounds.size.height <= 568.0) {
            self.toastPic = [UIImage imageNamed:@"toastThreeSmall"];
        }
        else {
            self.toastPic = [UIImage imageNamed:@"toastThree"];
        }
        
        self.toast = [[UIImageView alloc] initWithImage:self.toastPic];
        self.toast.alpha = 1.0;
        self.toast.tag = 9;
        
        CGPoint dasCenter = CGPointMake(self.navigationController.navigationBar.bounds.size.width/2, 24);
        
        [self.toast setCenter:dasCenter];
        
        [self.navigationController.navigationBar addSubview:self.toast];
        
        [UIView animateWithDuration:0.07 animations:^{
            
            [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"hasRanApp3"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.toast.alpha = 1.0;
            
            self.toast.transform = CGAffineTransformMakeScale(1.045, 1.045);
            
        } completion:^(BOOL finished) {
            self.toast.transform = CGAffineTransformMakeScale(1.0, 1.0);
            
        }];
    }
}

-(void)queryForOrderNumber {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Orders"];
    [query whereKey:@"orderNumber" equalTo:self.orderNumber];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            [self queryForOrderNumber];
        }
        else {
            self.order = object;
            //NSLog(@"Order: %@", self.order);
        }
    }];
    
}

@end
