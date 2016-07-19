//
//  EditPackageTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/7/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "EditPackageTableViewController.h"
#import "CartTableViewController.h"
#import "AppDelegate.h"

@interface EditPackageTableViewController ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableDictionary *editedCells;
@property (nonatomic, strong) UIView *headerview;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSArray *itemKeys;
@property (nonatomic, strong) NSArray *extraKeys;

@end

@implementation EditPackageTableViewController

@synthesize parent,packageSize;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (_thePackage_itemsDictionary == NULL){
        _thePackage_itemsDictionary = [_appDelegate package_itemsDictionary];
    }
    
    if (_theExtraPackage_itemsDictionary == NULL){
        _theExtraPackage_itemsDictionary = [_appDelegate extraPackage_itemsDictionary];
    }
    
    if ([_thePackage_itemsDictionary valueForKey:_packageName]){
        _itemKeys = [[_thePackage_itemsDictionary valueForKey:_packageName] allKeys];
    }else{
        _extraKeys = [[_theExtraPackage_itemsDictionary valueForKey:_packageName] allKeys];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"updateButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    
    
    
    if ([_thePackage_itemsDictionary valueForKey:_packageName]){
        self.title = [NSString stringWithFormat:@"Edit %@ Package", self.packageName];
    }else {
        self.title = [NSString stringWithFormat:@"Edit Extra %@ Items", self.packageName];
    }
    self.tableView.tableFooterView = [UIView new];
    
    //Nav Bar Back Button Color
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.layer.masksToBounds = YES;
    self.tableView.clipsToBounds = YES;
    
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
    
    
    self.headerview = [[[NSBundle mainBundle] loadNibNamed:@"ItemTableHeaderView" owner:self options:nil] objectAtIndex:0];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        
        self.headerview.backgroundColor = [UIColor colorWithRed:0.937 green:0.349 blue:0.639 alpha:1];
        return self.headerview;
    }
    
    UIView *clearView = [UIView new];
    clearView.backgroundColor = [UIColor clearColor];
    return clearView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        if ([_thePackage_itemsDictionary valueForKey:_packageName]){
            return [_itemKeys count];
        }else {
            return [_extraKeys count];
        }
    }
    if (section ==1) {
        return 1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EditItemsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UpdateCartTableCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
    
    if([[_thePackage_itemsDictionary valueForKey: _packageName] count]==0 && [[_theExtraPackage_itemsDictionary valueForKey: _packageName] count]==0){
        return cell;
    }
    
    if (indexPath.section == 0) {
        
        if ([_thePackage_itemsDictionary valueForKey:_packageName]){
            cell.itemNameLabel.text = [_itemKeys objectAtIndex:indexPath.row];
            cell.itemDetailLabel.text = [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemDetail];
            cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d",[[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
            
            cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
        }else{
            cell.itemNameLabel.text = [_extraKeys objectAtIndex:indexPath.row];
            cell.itemDetailLabel.text = [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemDetail];
            cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d",[[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
            
            cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
        }
        
        //NSLog(@"Price: %.02f", price);
        
        
        if(_editedCells[[NSString stringWithFormat:@"c%d",(int)indexPath.row]]!=nil){
            cell.itemQuantityLabel.text = _editedCells[[NSString stringWithFormat:@"c%d",(int)indexPath.row]];
            
        }
        
        cell.decrementButton.tag = indexPath.row;
        cell.incrementButton.tag = indexPath.row;
    }
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            cell2.separatorInset = UIEdgeInsetsMake(0.f, 10000.0f, 0.f, 0.0f);
        }
        
        CALayer *btn = [cell2.updateCartButton layer];
        [btn setMasksToBounds:YES];
        [btn setCornerRadius:5.0f];
        
        return cell2;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 70;
    }
    if (indexPath.section == 1) {
        return 122;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 46;
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


-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)incrementQuantity:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    EditItemsTableCell *cell = (EditItemsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (([_packageName isEqual:@"Beer"] && [self checkValidBeerLimit]) || (![_packageName isEqual:@"Beer"] && ![_packageName isEqual:@"21+"])){
        if ([_thePackage_itemsDictionary valueForKey:_packageName]){
            [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] increaseQuantity];
            cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
            cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
        }else{
            if (![[_theExtraPackage_itemsDictionary valueForKey: _packageName] valueForKey:cell.itemNameLabel.text]){
                [[_theExtraPackage_itemsDictionary valueForKey:_packageName] setObject:[[CartItemObject alloc] initItem:cell.itemNameLabel.text detail:cell.itemDetailLabel.text quantity: 1 price:[cell.itemPriceLabel.text floatValue] imageURLString: @""] forKey:cell.itemNameLabel.text];
            }else{
                [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] increaseQuantity];
            }
            
            cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
            cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
        }
    }
}

- (IBAction)decrementQuantity:(id)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    EditItemsTableCell *cell = (EditItemsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([_thePackage_itemsDictionary valueForKey:_packageName]){
        [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] decreaseQuantity];
        cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
        cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
    }else{
        int value = [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] - 1;
        if (value < 1){
            [[[_theExtraPackage_itemsDictionary valueForKey: _packageName] valueForKey:cell.itemNameLabel.text] setItemQuantity:0];
            //[[_theExtraPackage_itemsDictionary valueForKey: _packageName] removeObjectForKey:cell.itemNameLabel.text];
        }else{
            [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] decreaseQuantity];
        }
        cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
        cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
    }
}

-(BOOL) checkValidBeerLimit{
    if ([_packageName isEqual:@"Beer"]){
        int maxNumOfBeers = 6;
        int totalBeers = 0;
        for (NSString* itemNameKey in [_thePackage_itemsDictionary valueForKey:_packageName]){
            CartItemObject* cartItem = [[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:itemNameKey];
            totalBeers += cartItem.itemQuantity;
        }
        
        for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:@"21+"]){
            CartItemObject* cartItem = [[_theExtraPackage_itemsDictionary valueForKey:@"21+"] valueForKey:itemNameKey];
            if ([[_appDelegate beerItemsDictionary] valueForKey:itemNameKey]){
                totalBeers += cartItem.itemQuantity;
            }
        }
        
        return totalBeers < maxNumOfBeers;
    }
    return YES;
}


- (IBAction)updateCartTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)removeEmptyExtraItems{
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    for (NSString* packagesKey in _theExtraPackage_itemsDictionary){
        for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:packagesKey]){
            if ([[[_theExtraPackage_itemsDictionary valueForKey: packagesKey] valueForKey:itemNameKey] itemQuantity] == 0){
                [arr addObject:itemNameKey];
            }
        }
        
        for (int i = 0; i < [arr count]; i++){
            [[_theExtraPackage_itemsDictionary valueForKey: packagesKey] removeObjectForKey:[arr objectAtIndex:i]];
        }
        
        [arr removeAllObjects];
    }
    
    
}

-(void) viewWillDisappear:(BOOL)animated{
    if ([[_theExtraPackage_itemsDictionary valueForKey:_packageName] count] < 1){
        [_theExtraPackage_itemsDictionary removeObjectForKey:_packageName];
    }
    [self removeEmptyExtraItems];
    [parent removeEmptyPackages];
    [parent initializeViewController];
}

@end
