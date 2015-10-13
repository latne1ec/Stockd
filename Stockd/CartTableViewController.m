//
//  CartTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/7/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "CartTableViewController.h"
#import "AddressTableViewController.h"
#import "AlcoholPolicyViewController.h"
#import "AppDelegate.h"

@interface CartTableViewController ()

//@property (nonatomic, strong) NSMutableArray *itemsToEdit;
//@property (nonatomic, strong) NSMutableDictionary *updatedItemList;
//@property (nonatomic) NSMutableDictionary *updatedPrice;
//@property (nonatomic) NSDictionary *updatedPriceDic;
@property (nonatomic) float subtotal;
@property (nonatomic) float taxes;
@property (nonatomic) int discount;
@property (nonatomic) int BOOZE;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSArray* packageKeys;
@property (nonatomic, strong) NSArray* extraKeys;

@end

@implementation CartTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    _packageKeys = [_appDelegate package_itemsDictionary].allKeys;
    _extraKeys = [_appDelegate extraPackage_itemsDictionary].allKeys;
    
    //_updatedPrice = -1;
    
    _BOOZE = 0;
    
    [self checkForBooze];
    
    [self setNavTitle];
    
    //_updatedPrice = [[NSMutableDictionary alloc] init];
    //_updatedItemList = [[NSMutableDictionary alloc] init];
    
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
    
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];
    
    if ([[PFUser currentUser] objectForKey:@"karmaCash"] >0) {
        _discount = [[[PFUser currentUser] objectForKey:@"karmaCash"] intValue];
    } else {
        _discount = 0;
        
    }
    
    [self updateTotal];
    [self checkIfParticipatingArea];
    
    NSLog(@"Das Beer Item is: %@", self.beerItem);
    NSLog(@"Das Liquor Item is: %@", self.liquorItem);
    
    NSLog(@"Order numbaaa 2: %@", self.orderNumber);
    
}


- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

-(void)checkIfParticipatingArea {
    
    NSString *zipCode = [[PFUser currentUser] objectForKey:@"zipCode"];
    
    if (zipCode == nil) {
        NSLog(@"BIG FAT NIL: POOPPP LOCK IT");
        [self getStockedTapped:self];
    }
    else {
        
        PFQuery *query = [PFQuery queryWithClassName:@"Zipcodes"];
        [query whereKey:@"zipcode" equalTo:zipCode];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object == nil) {
                NSLog(@"Not in that area");
            }
            else {
                
            }
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [self updateTotal];
    [self.tableView reloadData];
    
}

-(void)this {
    
    NSLog(@"Here dude");
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return _packageKeys.count;
    }
    
    if (section == 1) {
        return _extraKeys.count;
    }
    
    if (section == 2) {
        
        return 1;
    }
    return 0;
}

-(NSString*)getAllItems
{
    id strings = [@[] mutableCopy];
    
    for (NSString* packagesKey in [_appDelegate package_itemsDictionary]){
        for (NSString* itemNameKey in [[_appDelegate package_itemsDictionary] valueForKey:packagesKey]){
            NSMutableString *result = [[NSMutableString alloc] init];
            CartItemObject* cartItem = [[[_appDelegate package_itemsDictionary] valueForKey:packagesKey] valueForKey:itemNameKey];
            [result appendString:[NSString stringWithFormat:@"%@ x%d", [cartItem itemName],[cartItem itemQuantity]]];
            [strings addObject:result];
        }
    }
    return [strings componentsJoinedByString:@"; "];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CartTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    SubtotalTableCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
    
    if (indexPath.section == 0){
        NSString *packageName = [_packageKeys objectAtIndex:indexPath.row];
        NSMutableString *result = [[NSMutableString alloc] init];
        
        for (NSString* itemNameKey in [[_appDelegate package_itemsDictionary] valueForKey:packageName]){
            CartItemObject* cartItem = [[[_appDelegate package_itemsDictionary] valueForKey:packageName] valueForKey:itemNameKey];
            [result appendString:[NSString stringWithFormat:@"%@ x%d ", [cartItem itemName],[cartItem itemQuantity]]];
        }
        cell.packageNameLabel.text = [NSString stringWithFormat:@"%@ Package", packageName];
        cell.packageItems.text = result;
        float firstPrice = [self firstPriceFor:packageName];
        NSString *priceString = [NSString stringWithFormat:@"$%0.2f", firstPrice];
        cell.packagePriceLabel.text = priceString;
        
        return cell;
    }
    
    if (indexPath.section == 1){
        NSString *packageName = [_extraKeys objectAtIndex:indexPath.row];
        NSMutableString *result = [[NSMutableString alloc] init];
        
        for (NSString* itemNameKey in [[_appDelegate extraPackage_itemsDictionary] valueForKey:packageName]){
            CartItemObject* cartItem = [[[_appDelegate extraPackage_itemsDictionary] valueForKey:packageName] valueForKey:itemNameKey];
            [result appendString:[NSString stringWithFormat:@"%@ x%d ", [cartItem itemName],[cartItem itemQuantity]]];
        }
        cell.packageNameLabel.text = [NSString stringWithFormat:@"Extra %@ Items", packageName];
        cell.packageItems.text = result;
        float firstPrice = [self firstPriceFor:packageName];
        NSString *priceString = [NSString stringWithFormat:@"$%0.2f", firstPrice];
        cell.packagePriceLabel.text = priceString;
        
        return cell;
    }
    
    if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            cell2.separatorInset = UIEdgeInsetsMake(0.f, 10000.0f, 0.f, 0.0f);
        }
        
        CALayer *btn = [cell2.getStockdButton layer];
        [btn setMasksToBounds:YES];
        [btn setCornerRadius:5.0f];
        
        cell2.sizeButton.layer.cornerRadius = 5.0;
        
        
        cell2.totalPriceLabel.text = [NSString stringWithFormat:@"$%.02f", _subtotal+_discount];
        if(_discount>0){
            cell2.discountLabel.text = [NSString stringWithFormat:@"-$%d.00", _discount];
        } else {
            cell2.discountLabel.text = [NSString stringWithFormat:@"$%d.00", _discount];
        }
        cell2.taxesLabel.text = [NSString stringWithFormat:@"$%.02f", _taxes];
        cell2.finalTotalLabel.text = [NSString stringWithFormat:@"$%.02f", _finalTotal];
        
        return cell2;
    }
    
    return nil;
}

-(float)firstPriceFor:(NSString*)packageName {
    
    float price = 0;
    
    if ([[_appDelegate package_itemsDictionary] valueForKey:packageName]){
        for (NSString* itemNameKey in [[_appDelegate package_itemsDictionary] valueForKey:packageName]){
            CartItemObject* cartItem = [[[_appDelegate package_itemsDictionary] valueForKey:packageName] valueForKey:itemNameKey];
            price += cartItem.itemQuantity*cartItem.itemPrice;
        }
    }else{
        for (NSString* itemNameKey in [[_appDelegate extraPackage_itemsDictionary] valueForKey:packageName]){
            CartItemObject* cartItem = [[[_appDelegate extraPackage_itemsDictionary] valueForKey:packageName] valueForKey:itemNameKey];
            price += cartItem.itemQuantity*cartItem.itemPrice;
        }
    }
    
    return price;
}

-(void)updateTotal {
    
    _subtotal = 0;
    _taxes = 0;
    _finalTotal = 0;
    
    for(int i=0; i<[_appDelegate package_itemsDictionary].count; i++){
        
        NSString *packageName = _packageKeys[i];
        
        float firstPrice = [self firstPriceFor:packageName];
        _subtotal += firstPrice;
    }
    
    for(int i=0; i<[_appDelegate extraPackage_itemsDictionary].count; i++){
        
        NSString *packageName = _extraKeys[i];
        
        float firstPrice = [self firstPriceFor:packageName];
        _subtotal += firstPrice;
    }
    
    
    //_subtotal = _subtotal * self.packageSize;
    
    _subtotal = _subtotal - _discount;
    
    _taxes = (_subtotal) * 0.06;
    
    _finalTotal = (_subtotal) + _taxes;
    
    [self.tableView reloadData];
    
    NSLog(@"SUBTOTAL: %f TAXES: %f TOTAL: %f Discount: %d",_subtotal, _taxes, _finalTotal, _discount);
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        NSString *packageName = [[NSString alloc] init];
        
        if (indexPath.section == 0){
            packageName = [_packageKeys objectAtIndex:indexPath.row];
        }else if (indexPath.section == 1){
            packageName = [_extraKeys objectAtIndex:indexPath.row];
        }
        
        EditPackageTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPackage"];
        destViewController.packageSize = self.packageSize;
        destViewController.packageName = packageName;
        destViewController.beerItem = self.beerItem;
        destViewController.parent = self;
        //destViewController.itemsToEdit = self.itemsToEdit;
        
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Address Info"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        return 118;
    }
    if (indexPath.section == 2) {
        return 250;
    }
    return 0;
}



- (IBAction)sizeButtonTapped:(id)sender {
    
    PickSizeViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PickSize"];
    destViewController.currentCartPrice = _finalTotal;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:destViewController];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Pick Size"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
    [self.navigationController presentViewController:navigationController animated:YES completion:^{
    }];
    
}

- (IBAction)getStockedTapped:(id)sender {
    
    if (_BOOZE !=0) {
        
        NSString *birthDate = [[PFUser currentUser] objectForKey:@"userDOB"];
        NSDate *todayDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        int time = [todayDate timeIntervalSinceDate:[dateFormatter dateFromString:birthDate]];
        int allDays = (((time/60)/60)/24);
        
        NSLog(@"User BDAY: %@", birthDate);
        
        if (allDays >= 7670) {
            NSLog(@"User is over 21");
        }
        else {
            
            NSLog(@"User is NOT 21");
            [self showBoozeTerms];
            return;
        }
    }
    
    if (_finalTotal<=.5) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Orders must be greater than $0.50" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        
        return;
    }
    
    NSString *canOrder = [[PFUser currentUser] objectForKey:@"canOrder"];
    
    if ([canOrder isEqualToString:@"NO"]) {
        NSLog(@"Not in your area yet HOLMESS!!");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Unfortunately we won't be able to process your order until we start serving your area. We'll notify you as soon as we do!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
        
    }
    else {
        
        NSString *userStripeToken = [[PFUser currentUser] objectForKey:@"stripeToken"];
        
        if ([[PFUser currentUser] objectForKey:@"streetName"] == nil) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Address Info" message:@"Before making any purchases on Stockd, you must first add your address information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            AddressTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Address"];
            destViewController.parent = self;
            UINavigationController *navigationController =
            [[UINavigationController alloc] initWithRootViewController:destViewController];
            UIBarButtonItem *newBackButton =
            [[UIBarButtonItem alloc] initWithTitle:@"Address Info"
                                             style:UIBarButtonItemStylePlain
                                            target:nil
                                            action:nil];
            [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
            [self.navigationController presentViewController:navigationController animated:YES completion:^{
            }];
            
        }
        
        else if (userStripeToken == nil) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Payment Method" message:@"Before making any purchases on Stockd, you must first enter a payment method." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            PaymentTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Payment"];
            destViewController.parent = self;
            UINavigationController *navigationController =
            [[UINavigationController alloc] initWithRootViewController:destViewController];
            UIBarButtonItem *newBackButton =
            [[UIBarButtonItem alloc] initWithTitle:@"Payment Info"
                                             style:UIBarButtonItemStylePlain
                                            target:nil
                                            action:nil];
            [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
            [self.navigationController presentViewController:navigationController animated:YES completion:^{
            }];
        }
        else {
            
            [ProgressHUD show:nil Interaction:NO];
            
            NSString *customerID = [[PFUser currentUser] objectForKey:@"customerID"];
            float amountInCents = _finalTotal*100;
            int roundedTotal = (int)roundf(amountInCents);
            NSNumber *amount = [NSNumber numberWithFloat:roundedTotal];
            
            [self chargeCustomer:customerID amount:amount completion:^(id object, NSError *error) {
                if (error) {
                    [ProgressHUD dismiss];
                    [self showError:error];
                }
                else {
                    NSLog(@"Charging Customer: %@", object);
                }
            }];
        }
    }
}

-(void)chargeCustomer:(NSString *)customerId amount:(NSNumber *)amountInCents completion:(PFIdResultBlock)handler {
    
    [PFCloud callFunctionInBackground:@"chargeCustomer"
                       withParameters:@{
                                        @"amount":amountInCents,
                                        @"customerId":customerId
                                        }
                                block:^(id object, NSError *error) {
                                    handler(object,error);
                                    if (error) {
                                        [ProgressHUD dismiss];
                                        NSLog(@"Error: %@", error);
                                    }
                                    else {
                                        NSLog(@"Success: %@", object);
                                        [[PFUser currentUser] incrementKey:@"karmaScore"];
                                        [[PFUser currentUser] removeObjectForKey:@"karmaCash"];
                                        [[PFUser currentUser] saveInBackground];
                                        [self getOrder];
                                        [self showConfirmation];
                                    }
                                }];
}

-(void)updateOrderInParse:(PFObject *)order {
    
    [ProgressHUD show:nil];
    NSString *orderString = [self getAllItems];
    [order setObject:orderString forKey:@"orderItems"];
    [order saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [ProgressHUD dismiss];
        }
        else {
            [ProgressHUD dismiss];
        }
    }];
}

-(void)getOrder {
    
    [ProgressHUD show:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Orders"];
    [query whereKey:@"orderNumber" equalTo:self.orderNumber];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            [ProgressHUD dismiss];
        }
        else {
            self.order = object;
            NSLog(@"Order: %@", self.order);
            [self updateOrderInParse:self.order];
            
        }
    }];
}


-(void)showConfirmation {
    
    ConfirmationTableViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Confirmation"];
    cvc.subtotal = _finalTotal;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:cvc];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
    
    [self.navigationController pushViewController:cvc animated:YES];
    
}


-(void)showError:(NSError *)error {
    
    NSLog(@"Error: %@", error);
    [TSMessage showNotificationInViewController:self.navigationController
                                          title:@"Error"
                                       subtitle:[error.userInfo objectForKey:@"error"]
                                          image:nil
                                           type:TSMessageNotificationTypeError
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:nil
                                 buttonCallback:^{}
                                     atPosition:TSMessageNotificationPositionNavBarOverlay
                           canBeDismissedByUser:YES];
    
}


-(void)checkForBooze {
    
    /*if ([[_appDelegate package_itemsDictionary] valueForKey:@"Liquor"]) {
        
        _BOOZE = 150;
        [self showBoozeTerms];
    }
    else if ([[_appDelegate package_itemsDictionary] valueForKey:@"Beer"]) {
        _BOOZE = 150;
        [self showBoozeTerms];
    }
    else if ([[_appDelegate package_itemsDictionary] valueForKey:@"Wine"]) {
        _BOOZE = 150;
        [self showBoozeTerms];
    }*/
    
}
-(void)showBoozeTerms {
    
    AlcoholPolicyViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AlcoholPolicy"];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:cvc];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Alcohol Policy"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
    [self.navigationController presentViewController:navigationController animated:YES completion:^{
    }];
    
}

-(void)setNavTitle {
    
    self.title = @"Basket";
    
    //    if (self.packageSize == 1) {
    //        self.title = @"Small Basket";
    //    }
    //    else if (self.packageSize == 2) {
    //        self.title = @"Medium Basket";
    //    }
    //    else if (self.packageSize == 3) {
    //        self.title = @"Large Basket";
    //    }
    //    else if (self.packageSize == 4) {
    //        self.title = @"XL Basket";
    //    }
}


@end
