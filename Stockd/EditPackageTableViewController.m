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


@end

@implementation EditPackageTableViewController

@synthesize parent,packageSize;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    _itemKeys = [[[_appDelegate package_itemsDictionary] valueForKey:_packageName] allKeys];
    
    NSLog(@"--------------------");
    
    NSLog(@"%@",_packageName);
    
    if ([[_appDelegate package_itemsDictionary] valueForKey:_packageName]){
        NSLog(@"YEah");
    }else{
        NSLog(@"NoooOOO");
    }
    
    NSLog(@"Diction: %@", [_appDelegate package_itemsDictionary]);
    NSLog(@"NB OF ITEMS: %lu", _itemKeys.count);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    self.title = [NSString stringWithFormat:@"Edit %@ Package", self.packageName];
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
        return [_itemKeys count];
    }
    if (section ==1) {
        return 1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    EditItemsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UpdateCartTableCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
    
    if([[[_appDelegate package_itemsDictionary] valueForKey: _packageName] count]==0){
        return cell;
    }
    
    if (indexPath.section == 0) {

    cell.itemNameLabel.text = [_itemKeys objectAtIndex:indexPath.row];
    cell.itemDetailLabel.text = [[[[_appDelegate package_itemsDictionary] valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemDetail];
    cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d",[[[[_appDelegate package_itemsDictionary] valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
    
        cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f",[[[[_appDelegate package_itemsDictionary] valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
        
        NSLog(@"PriceEEE: :$%.02f",[[[[_appDelegate package_itemsDictionary] valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]);
        
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
    
    NSLog(@"Scroll: %f", scrollView.contentOffset.y);
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

    if (([_packageName isEqual:@"Beer"] && [self checkValidBeerLimit]) || ![_packageName isEqual:@"Beer"]){
        [[[[_appDelegate package_itemsDictionary] valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] increaseQuantity];
    }
    
    cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[[_appDelegate package_itemsDictionary] valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
}

- (IBAction)decrementQuantity:(id)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    EditItemsTableCell *cell = (EditItemsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [[[[_appDelegate package_itemsDictionary] valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] decreaseQuantity];
    
    cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[[_appDelegate package_itemsDictionary] valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
}

-(BOOL) checkValidBeerLimit{
    if ([_packageName isEqual:@"Beer"]){
        int maxNumOfBeers = 6;
        int totalBeers = 0;
        for (NSString* itemNameKey in [[_appDelegate package_itemsDictionary] valueForKey:_packageName]){
            CartItemObject* cartItem = [[[_appDelegate package_itemsDictionary] valueForKey:_packageName] valueForKey:itemNameKey];
            totalBeers += cartItem.itemQuantity;
        }
        return totalBeers < maxNumOfBeers;
    }
    return YES;
}


- (IBAction)updateCartTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
