//
//  AddPackagesCollectionViewController.m
//  Stockd
//
//  Created by Alex Consel on 2016-07-12.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "AddPackagesCollectionViewController.h"
#import "CameraViewController.h"
#import "BBBadgeBarButtonItem.h"
#import "AppDelegate.h"
#import "InitialViewController.h"
#import "AppDelegate.h"
#include "CartItemObject.h"
#include "PackageCollectionViewLayout.h"
#include "PackageHeaderView.h"

@interface AddPackagesCollectionViewController ()

@property (nonatomic, strong) NSArray *booze;
@property (nonatomic) int oldPosition;
@property (nonatomic) int position, counts;
@property (nonatomic, strong) NSMutableDictionary *itemsDictionary;
@property (nonatomic, strong) NSString *beerItem;
@property (nonatomic, strong) NSString *liquorItem;
@property (nonatomic, strong) UIImageView *toast;
@property (nonatomic, strong) UIImage *toastPic;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) UITableViewHeaderFooterView *headerView;
@property (nonatomic) float offsetY;


@end

@implementation AddPackagesCollectionViewController

static NSString * const reuseIdentifier = @"TheCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PackageCollectionViewLayout* theLayout = [[PackageCollectionViewLayout alloc] init];
    theLayout.headerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, 60);
    theLayout.sectionHeadersPinToVisibleBounds = YES;
    
    self.collectionView.collectionViewLayout = theLayout;
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
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
    
    PFUser *user = [PFUser currentUser];
    user.password = @"test";
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error");
        } else {
            NSLog(@"success");
        }
    }];
    
    //    [[PFUser currentUser] setObject:@"1532 Waverly Rd" forKey:@"streetName"];
    //    [[PFUser currentUser] setObject:@"Gladwyne" forKey:@"userCity"];
    //    [[PFUser currentUser] setObject:@"19035" forKey:@"zipCode"];
    //    [[PFUser currentUser] setObject:@"Pa" forKey:@"userState"];
    //    [[PFUser currentUser] saveInBackground];
    //    [[PFUser currentUser] removeObjectForKey:@"userLocation"];
    //    [[PFUser currentUser] saveInBackground];
    
    
    self.title = @"Add Packages";
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    _counts = 0;
    
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
    
    self.collectionView.layer.masksToBounds = YES;
    //self.tableView.clipsToBounds = YES;
    
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
    [self queryForDrinkPackages];
    [self queryForBoozePackages];
    [self queryForPackageItems];
    [self getPreselectedBeerItem];
    //[self queryForOrderNumber];
    
    
    NSString *uuidStr = [[NSUUID UUID] UUIDString];
    self.orderNumber = uuidStr;
    
    //NSLog(@"dic: %@", [_appDelegate package_itemsDictionary])
}

-(void) viewWillAppear:(BOOL)animated{
    AppDelegate *ad = [[UIApplication sharedApplication] delegate];
    [ad showAnimation];
    
    self.navigationItem.hidesBackButton = YES;
    
    [self.collectionView reloadData];
    
    [self updateCartAnimated];
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

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


-(BOOL) checkValidBeerLimit{
    int maxNumOfBeers = 6;
    int totalBeers = 0;
    for (NSString* itemNameKey in [[_appDelegate package_itemsDictionary] valueForKey:@"Beer"]){
        CartItemObject* cartItem = [[[_appDelegate package_itemsDictionary] valueForKey:@"Beer"] valueForKey:itemNameKey];
        totalBeers += cartItem.itemQuantity;
    }
    
    for (NSString* itemNameKey in [[_appDelegate extraPackage_itemsDictionary] valueForKey:@"21+"]){
        CartItemObject* cartItem = [[[_appDelegate extraPackage_itemsDictionary] valueForKey:@"21+"] valueForKey:itemNameKey];
        if ([[_appDelegate beerItemsDictionary] valueForKey:itemNameKey]){
            totalBeers += cartItem.itemQuantity;
        }
    }
    
    return totalBeers < maxNumOfBeers;
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
            self.food = [NSMutableArray arrayWithArray:objects];
            
            PFObject* tempObj = self.food[0];
            self.food[0] = self.food[1];
            self.food[1] = tempObj;
            
            tempObj = self.food[1];
            self.food[1] = self.food[5];
            self.food[5] = tempObj;
            
            tempObj = self.food[2];
            self.food[2] = self.food[3];
            self.food[3] = tempObj;
            
            tempObj = self.food[4];
            self.food[4] = self.food[5];
            self.food[5] = tempObj;
            
            
            [self.collectionView reloadData];
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
            [self.collectionView reloadData];
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
            [self.collectionView reloadData];
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
        //NSLog(@"hi");
    }
    else {
        
        if ([UIScreen mainScreen].bounds.size.height <= 568.0) {
            self.toastPic = [UIImage imageNamed:@"toastThreeSmall"];
        }
        else {
            self.toastPic = [UIImage imageNamed:@"toastThreeBig"];
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

-(void) updateCartAnimated{
    int totalNumber = 0;
    /*for (NSString* packagesKey in [_appDelegate package_itemsDictionary]){
     totalNumber += [[[_appDelegate package_itemsDictionary] valueForKey:packagesKey] count];
     }*/
    
    totalNumber += [_appDelegate package_itemsDictionary].count;
    
    for (NSString* extraPackageKey in [_appDelegate extraPackage_itemsDictionary]){
        for (NSString* itemNameKey in [[_appDelegate extraPackage_itemsDictionary] valueForKey:extraPackageKey]){
            totalNumber += [[[[_appDelegate extraPackage_itemsDictionary] valueForKey:extraPackageKey] valueForKey:itemNameKey] itemQuantity];
        }
    }
    
    [(CartButton*)[self.navigationItem.rightBarButtonItem customView] changeNumber:totalNumber];
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
        
        
        
        // NSLog(@"packageDictionary: %@", [_appDelegate package_itemsDictionary]);
        
        //cvc.packageSize = self.packageSize;
        cvc.packageSize = 1;
        cvc.orderNumber = _orderNumber;
        cvc.beerItem = self.beerItem;
        cvc.liquorItem = self.liquorItem;
        [self.navigationController pushViewController:cvc animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
         PackageHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        
        if (indexPath.section == 0){
            headerView.titleLabel.text = @"Food";
        }else if (indexPath.section == 1){
            headerView.titleLabel.text = @"Drinks";
        }
        
        reusableview = headerView;
    }
    
    return reusableview;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete implementation, return the number of sections
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of items
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PackageCollectionViewCell *cell = (PackageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.isEven = (indexPath.row % 2 == 0);
    
    [cell layoutIfNeeded];
    
    
    /*sCALayer *btn = [cell.greenBkgView layer];
    if (btn.cornerRadius !=5.0f) {
        [btn setMasksToBounds:YES];
        [btn setCornerRadius:5.0f];
    }*/
    
    if (indexPath.section == 0) {
        
        PFObject *object = [self.food objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        cell.packageLabel.text = [NSString stringWithFormat:@"+ %@", packageName];
        
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
            
            //cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            cell.packageImageView.alpha = 0.3;
            
        }
        
        else {
            //cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
            cell.packageImageView.alpha = 1;
        }
        
        
        cell.isLast = (indexPath.row == _food.count-1);
        if ((_food.count % 2) == 0 && indexPath.row == _food.count-2){
            cell.isLast = YES;
        }
        
        
        return cell;
        
    }
    
    if (indexPath.section == 1) {
        PFObject *object = [self.drinks objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        cell.packageLabel.text = [NSString stringWithFormat:@"+ %@", packageName];
        
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
            
            //cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            cell.packageImageView.alpha = 0.3;
            
        }
        
        else {
            //cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
            cell.packageImageView.alpha = 1;
        }
        
        
        /*cell.isLast = (indexPath.row == _drinks.count-1);
        if ((_drinks.count % 2) == 0 && indexPath.row == _drinks.count-2){
            cell.isLast = YES;
        }*/
        
        return cell;
    }
    
    if (indexPath.section == 2) {
        PFObject *object = [self.booze objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        cell.packageLabel.text = [NSString stringWithFormat:@"+ %@", packageName];
        
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
            
            //cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            cell.packageImageView.alpha = 0.3;
            
        }
        
        else {
            //cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
            cell.packageImageView.alpha = 1;
        }
        
        /*cell.isLast = (indexPath.row == _booze.count-1);
        if ((_booze.count % 2) == 0 && indexPath.row == _booze.count-2){
            cell.isLast = YES;
        }*/
        
        return cell;
    }
    
    
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [(CartButton*)[self.navigationItem.rightBarButtonItem customView] changeNumber:6];
    
    PackageCollectionViewCell *cell = (PackageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    [self showToast];
    
    if (indexPath.section == 0) {
        PFObject *object = [self.food objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        if (![[_appDelegate package_itemsDictionary] valueForKey:packageName]){
            [[_appDelegate package_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:packageName];
            for (PFObject* itemPFObj in [_itemsDictionary valueForKey:packageName]){
                [[[_appDelegate package_itemsDictionary] valueForKey:packageName] setObject:[[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity: 1 price:[itemPFObj[@"itemPrice"] floatValue] imageURLString:itemPFObj[@"itemImageUrl"]] forKey:itemPFObj[@"itemName"]];
            }
            //cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
            cell.packageImageView.alpha = 1;
        }
        else {
            [[_appDelegate package_itemsDictionary] removeObjectForKey:packageName];
            //cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            cell.packageImageView.alpha = 0.3;
        }
        
    }
    
    else if (indexPath.section == 2) {
        PFObject *object = [self.booze objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        
        if (([packageName isEqual:@"Beer"] && [self checkValidBeerLimit]) || ![packageName isEqual:@"Beer"]){
            
            if (![[_appDelegate package_itemsDictionary] valueForKey:packageName]){
                [[_appDelegate package_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:packageName];
                //NSLog(@"PackageName: %@", packageName);
                if ([packageName isEqual:@"Beer"] || [packageName isEqual:@"Liquor"] || [packageName isEqual:@"Wine"]){
                    for (PFObject* itemPFObj in [_itemsDictionary valueForKey:packageName]){
                        int t_qt = 0;
                        if ([itemPFObj[@"itemName"] isEqual:@"Bud Light"] || [itemPFObj[@"itemName"] isEqual:@"Absolut"]){
                            t_qt = 1;
                        }
                        [[[_appDelegate package_itemsDictionary] valueForKey:packageName] setObject:[[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity: t_qt price:[itemPFObj[@"itemPrice"] floatValue] imageURLString:itemPFObj[@"itemImageUrl"]] forKey:itemPFObj[@"itemName"]];
                    }
                }else{
                    for (PFObject* itemPFObj in [_itemsDictionary valueForKey:packageName]){
                        [[[_appDelegate package_itemsDictionary] valueForKey:packageName] setObject:[[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity: 1 price:[itemPFObj[@"itemPrice"] floatValue] imageURLString:itemPFObj[@"itemImageUrl"]] forKey:itemPFObj[@"itemName"]];
                    }
                }
                //cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
                cell.packageLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
                cell.packageImageView.alpha = 1;
            }
            else {
                [[_appDelegate package_itemsDictionary] removeObjectForKey:packageName];
                //cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
                cell.packageLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
                cell.packageImageView.alpha = 0.3;
            }
        }else{
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"You already have the maximum amount of beer in your cart."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
        
    }
    
    
    else {
        
        PFObject *object = [self.drinks objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        
        if (![[_appDelegate package_itemsDictionary] valueForKey:packageName]){
            [[_appDelegate package_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:packageName];
            for (PFObject* itemPFObj in [_itemsDictionary valueForKey:packageName]){
                [[[_appDelegate package_itemsDictionary] valueForKey:packageName] setObject:[[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity: 1 price:[itemPFObj[@"itemPrice"] floatValue] imageURLString:itemPFObj[@"itemImageUrl"]] forKey:itemPFObj[@"itemName"]];
            }
            
            //cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
            cell.packageImageView.alpha = 1;
        }
        else {
            [[_appDelegate package_itemsDictionary] removeObjectForKey:packageName];
            //cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            cell.packageImageView.alpha = 0.3;
        }
        
    }
    
    [self updateCartAnimated];
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
