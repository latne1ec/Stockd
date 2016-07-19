//
//  PackageDetailCollectionViewController.m
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "PackageDetailCollectionViewController.h"
#import "CartButton.h"
#import "AppDelegate.h"
#import "PackageCollectionViewLayout.h"

@interface PackageDetailCollectionViewController ()

@property (nonatomic, strong) PFRelation *itemRelation;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) UIView *headerview;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation PackageDetailCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    PackageCollectionViewLayout* theLayout = [[PackageCollectionViewLayout alloc] init];
    theLayout.isEdit = YES;
    
    self.collectionView.collectionViewLayout = theLayout;
    
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
    //                                                                             style:UIBarButtonItemStylePlain
    //                                                                            target:self
    //                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    
    CartButton *btn =  [CartButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0,0,25,25);
    [btn addTarget:self action:@selector(goToCartScreen) forControlEvents:UIControlEventTouchUpInside];
    [btn load];
    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = barBtn;
    
    
    self.title = [NSString stringWithFormat:@"%@ Items", self.packageName];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialBkg"]];
    [self.collectionView setBackgroundView:imageView];
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.collectionView.layer.masksToBounds = YES;
    self.collectionView.clipsToBounds = YES;
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    
    [self queryForItems];
    
    self.headerview = [[[NSBundle mainBundle] loadNibNamed:@"ItemTableHeaderView" owner:self options:nil] objectAtIndex:0];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self updateCartAnimated];
    [self.collectionView reloadData];
    
    if (![[_appDelegate extraPackage_itemsDictionary] valueForKey:_packageType]){
        [[_appDelegate extraPackage_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey: _packageType];
    }
    
    //self.navigationItem.hidesBackButton = YES;
}


-(void)viewWillDisappear:(BOOL)animated {
    if ([[[_appDelegate extraPackage_itemsDictionary] valueForKey:_packageType] count] < 1){
        [[_appDelegate extraPackage_itemsDictionary] removeObjectForKey:_packageType];
    }
    [ProgressHUD dismiss];
    //self.navigationItem.hidesBackButton = YES;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TheCell" forIndexPath:indexPath];
    cell.isEven = (indexPath.row % 2 == 0);
    cell.showTopLine = (indexPath.row < 2);
    
    PFObject *object = [self.items objectAtIndex:indexPath.row];
    cell.itemNameLabel.text = [object objectForKey:@"itemName"];
    cell.itemDetailLabel.text = [object objectForKey:@"itemQuantity"];
    
    if ([[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:[object objectForKey:@"itemName"]]){
        cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:self.items[indexPath.row][@"itemName"]] itemQuantity]];
    }else{
        cell.itemQuantityLabel.text = @"0";
    }
    
    float price = [[object objectForKey:@"itemPrice"] floatValue];
    cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f",price];
    
    cell.decrementButton.tag = indexPath.row;
    cell.incrementButton.tag = indexPath.row;
    
    cell.theImageURL = [object objectForKey:@"itemImageUrl"];
    
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //NSLog(@"Scroll: %f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < 0) {
        self.headerview.backgroundColor = [UIColor clearColor];
    }
    else {
        
        self.headerview.backgroundColor = [UIColor colorWithRed:0.937 green:0.349 blue:0.639 alpha:1];
    }
}

-(void)queryForItems {
    
    [ProgressHUD show:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Items"];
    [query whereKey:@"itemPackage" equalTo:self.packageName];
    [query orderByAscending:@"itemName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [ProgressHUD dismiss];
            //NSLog(@"Error: %@", error);
        }
        else {
            [ProgressHUD dismiss];
            self.items = objects;
            //NSLog(@"Items: %@", objects);
            [self.collectionView reloadData];
        }
    }];
}


-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

-(BOOL) checkValidBeerLimit{
    if ([_packageName isEqual:@"Beer"]){
        int maxNumOfBeers = 6;
        int totalBeers = 0;
        for (NSString* itemNameKey in [[_appDelegate package_itemsDictionary] valueForKey:_packageName]){
            CartItemObject* cartItem = [[[_appDelegate package_itemsDictionary] valueForKey:_packageName] valueForKey:itemNameKey];
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
    return YES;
}


- (IBAction)incrementQuantityButtonTapped:(id)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    ItemCollectionViewCell *cell = (ItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    NSString *itemNameLabel = cell.itemNameLabel.text;
    
    if (![[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel]){
        if ([self checkValidBeerLimit]){
            [[[_appDelegate extraPackage_itemsDictionary] valueForKey:_packageType] setObject:[[CartItemObject alloc] initItem:self.items[indexPath.row][@"itemName"] detail:self.items[indexPath.row][@"itemQuantity"] quantity: 1 price:[self.items[indexPath.row][@"itemPrice"] floatValue] imageURLString:self.items[indexPath.row][@"itemImageUrl"]] forKey:self.items[indexPath.row][@"itemName"]];
            
            [self updateCartAnimated];
        }
    }else{
        if ([self checkValidBeerLimit]){
            [[[[_appDelegate extraPackage_itemsDictionary] valueForKey:_packageType] valueForKey:self.items[indexPath.row][@"itemName"]] increaseQuantity];
            [self updateCartAnimated];
        }
    }
    
    cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel] itemQuantity]];
    
}

- (IBAction)decrementQuantityButtonTapped:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    ItemCollectionViewCell *cell = (ItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    NSString *itemNameLabel = cell.itemNameLabel.text;
    
    if ([[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel]){
        int value = [[[[_appDelegate extraPackage_itemsDictionary] valueForKey:_packageType] valueForKey:self.items[indexPath.row][@"itemName"]] itemQuantity] - 1;
        
        if (value < 1){
            [[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] removeObjectForKey:itemNameLabel];
            
            [self updateCartAnimated];
        }else{
            [[[[_appDelegate extraPackage_itemsDictionary] valueForKey:_packageType] valueForKey:self.items[indexPath.row][@"itemName"]] decreaseQuantity];
            [self updateCartAnimated];
        }
    }
    
    cell.decrementButton.tag = indexPath.row;
    cell.incrementButton.tag = indexPath.row;
    
    if ([[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel]){
        cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel] itemQuantity]];
    }else{
        cell.itemQuantityLabel.text = @"0";
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

-(void)goToCartScreen {
    
    int totalNumber = 0;
    for (NSString* extraPackageKey in [_appDelegate extraPackage_itemsDictionary]){
        for (NSString* itemNameKey in [[_appDelegate extraPackage_itemsDictionary] valueForKey:extraPackageKey]){
            totalNumber += [[[[_appDelegate extraPackage_itemsDictionary] valueForKey:extraPackageKey] valueForKey:itemNameKey] itemQuantity];
        }
    }
    
    if ([_appDelegate package_itemsDictionary].count + totalNumber == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cart Empty" message:@"Your cart is empty. Add a package or two before checking out!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    }
    else {
        
        CartTableViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Cart"];
        [self.navigationController pushViewController:cvc animated:YES];
    }
    
    //}
    
}


@end
