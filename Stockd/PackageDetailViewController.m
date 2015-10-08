//
//  PackageDetailViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "PackageDetailViewController.h"
#import "CartButton.h"
#import "AppDelegate.h"

@interface PackageDetailViewController ()

@property (nonatomic, strong) PFRelation *itemRelation;
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) UIView *headerview;
@property (nonatomic, strong) AppDelegate *appDelegate;

@end

@implementation PackageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (![[_appDelegate extraPackage_itemsDictionary] valueForKey:_packageType]){
        [[_appDelegate extraPackage_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey: _packageType];
    }
    
    self.tableView.tableFooterView = [UIView new];
    
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
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
      
    [self queryForItems];
    
    self.headerview = [[[NSBundle mainBundle] loadNibNamed:@"ItemTableHeaderView" owner:self options:nil] objectAtIndex:0];

    
}

-(void)viewWillAppear:(BOOL)animated {
    
    //self.navigationItem.hidesBackButton = YES;
}


-(void)viewWillDisappear:(BOOL)animated {
    
    [ProgressHUD dismiss];
    //self.navigationItem.hidesBackButton = YES;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    self.headerview.backgroundColor = [UIColor colorWithRed:0.937 green:0.349 blue:0.639 alpha:1];
    return self.headerview;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    PFObject *object = [self.items objectAtIndex:indexPath.row];
    cell.itemNameLabel.text = [object objectForKey:@"itemName"];
    cell.itemDetailLabel.text = [object objectForKey:@"itemQuantity"];
    
    if ([[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:[object objectForKey:@"itemName"]]){
        cell.itemQuantityLabel.text = [[[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:[object objectForKey:@"itemName"]] stringValue];
    }else{
        cell.itemQuantityLabel.text = @"0";
    }
    
    float price = [[object objectForKey:@"itemPrice"] floatValue];
    cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f",price];
    
    cell.decrementButton.tag = indexPath.row;
    cell.incrementButton.tag = indexPath.row;
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    return 70;
    
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
            [self.tableView reloadData];
        }
    }];
}


-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
        
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)incrementQuantityButtonTapped:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    ItemTableCell *cell = (ItemTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSString *itemNameLabel = cell.itemNameLabel.text;
    
    if (![[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel]){
        [[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] setObject:[NSNumber numberWithInt:1] forKey:itemNameLabel];
    }else{
        int value = [[[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel] intValue] + 1;
        
        [[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] setObject: [NSNumber numberWithInt: value] forKey:itemNameLabel];
    }
    
    NSLog(@"Test: %@", [_appDelegate extraPackage_itemsDictionary]);
    
    
    cell.itemQuantityLabel.text = [[[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel] stringValue];
}

- (IBAction)decrementQuantityButtonTapped:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    ItemTableCell *cell = (ItemTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    NSString *itemNameLabel = cell.itemNameLabel.text;
    
    if ([[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel]){
        int value = [[[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel] intValue] - 1;
        
        if (value < 1){
            [[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] removeObjectForKey:itemNameLabel];
        }else{
            [[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] setObject: [NSNumber numberWithInt: value] forKey:itemNameLabel];
        }
    }
    
    cell.decrementButton.tag = indexPath.row;
    cell.incrementButton.tag = indexPath.row;
    
    if ([[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel]){
        cell.itemQuantityLabel.text = [[[[_appDelegate extraPackage_itemsDictionary] valueForKey: _packageType] valueForKey:itemNameLabel] stringValue];
    }else{
        cell.itemQuantityLabel.text = @"0";
    }
}



-(void)goToCartScreen {
    
//    if (self.packages.count == 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cart Empty" message:@"Your cart is empty. Add a package or two before checking out!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//    }
//    else {
    
        CartTableViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Cart"];
//        cvc.packages = self.packages;
//        cvc.items = _itemsDictionary;
//        //cvc.packageSize = self.packageSize;
//        cvc.packageSize = 1;
//        cvc.orderNumber = _orderNumber;
//        cvc.beerItem = self.beerItem;
//        cvc.liquorItem = self.liquorItem;
        [self.navigationController pushViewController:cvc animated:YES];
    
    //}
    
}


@end
