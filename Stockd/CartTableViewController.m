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

@interface CartTableViewController ()

@property (nonatomic, strong) NSMutableArray *itemsToEdit;
@property (nonatomic, strong) NSMutableDictionary *updatedItemList;
@property (nonatomic) NSMutableDictionary *updatedPrice;
@property (nonatomic) NSDictionary *updatedPriceDic;
@property (nonatomic) float subtotal;
@property (nonatomic) float taxes;
@property (nonatomic) int discount;
@property (nonatomic) float finalTotal;
@property (nonatomic) int BOOZE;

@end

@implementation CartTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //_updatedPrice = -1;
    
    _BOOZE = 0;
    
    NSLog(@"packages: %@", self.packages);
    
    [self checkForBooze];
    
    [self setNavTitle];
    
    _updatedPrice = [[NSMutableDictionary alloc] init];
    _updatedItemList = [[NSMutableDictionary alloc] init];
    
    self.tableView.tableFooterView = [UIView new];
    self.itemsToEdit = [[NSMutableArray alloc] init];
    
    
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

    if (self.itemsToEdit != nil) {
        
        [self.itemsToEdit removeAllObjects];
    }
    
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return self.packages.count;
    }
    if (section == 1) {
        
        return 1;
    }
    return 0;
}

-(NSString*)getAllItems
{
    id strings = [@[] mutableCopy];
    
    for(int i=0; i<[self.packages count]; i++){
        NSString *packageName = [self.packages objectAtIndex:i];
        
        if (_updatedItemList[packageName] != nil) {
            [strings addObject:_updatedItemList[packageName]];
        } else {
            NSMutableString *result = [[NSMutableString alloc] init];
            for(int j=0; j<[self.items[packageName] count]; j++){
                NSDictionary  *item = self.items[packageName][j];
                if(j==[self.items[packageName] count]-1){
                    [result appendString:[NSString stringWithFormat:@"%@ x%d", item[@"itemName"],self.packageSize]];
                } else {
                    [result appendString:[NSString stringWithFormat:@"%@ x%d, ", item[@"itemName"],self.packageSize]];
                }
            }
            [strings addObject:result];
        }
    }
    
    return [strings componentsJoinedByString:@"; "];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CartTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    SubtotalTableCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
    
    if (indexPath.section == 0) {
    
    NSString *packageName = [self.packages objectAtIndex:indexPath.row];
    cell.packageNameLabel.text = [NSString stringWithFormat:@"%@ Package", packageName];
        
        
        NSMutableString *result = [[NSMutableString alloc] init];

            for(int j=0; j<[self.items[packageName] count]; j++){
                NSDictionary  *item = self.items[packageName][j];
                
                if([[packageName lowercaseString] isEqualToString:@"liquor"]){
                    
                    if([[item[@"itemName"] lowercaseString] isEqualToString:@"absolut"]){
                        if(j==[self.items[packageName] count]-1){
                            [result appendString:[NSString stringWithFormat:@"%@ x%d", item[@"itemName"],self.packageSize]];
                        } else {
                            [result appendString:[NSString stringWithFormat:@"%@ x%d, ", item[@"itemName"],self.packageSize]];
                        }
                    } else {
                        if(j==[self.items[packageName] count]-1){
                            [result appendString:[NSString stringWithFormat:@"%@ x0", item[@"itemName"]]];
                        } else {
                            [result appendString:[NSString stringWithFormat:@"%@ x0, ", item[@"itemName"]]];
                        }
                        
                    }
                    
                } else if([[packageName lowercaseString] isEqualToString:@"beer"]){
                
                    int maxBeers = self.packageSize;
                    if(maxBeers>2){
                        maxBeers = 2;
                    }
                    
                if([[item[@"itemName"] lowercaseString] isEqualToString:self.beerItem]){
                    if(j==[self.items[packageName] count]-1){
                        [result appendString:[NSString stringWithFormat:@"%@ x%d", item[@"itemName"], maxBeers]];
                    } else {
                        [result appendString:[NSString stringWithFormat:@"%@ x%d, ", item[@"itemName"], maxBeers]];
                    }
                } else {
                    if(j==[self.items[packageName] count]-1){
                        [result appendString:[NSString stringWithFormat:@"%@ x0", item[@"itemName"]]];
                    } else {
                        [result appendString:[NSString stringWithFormat:@"%@ x0, ", item[@"itemName"]]];
                    }
                }
                    
                } else {
                
                if(j==[self.items[packageName] count]-1){
                    [result appendString:[NSString stringWithFormat:@"%@ x%d", item[@"itemName"],self.packageSize]];
                } else {
                    [result appendString:[NSString stringWithFormat:@"%@ x%d, ", item[@"itemName"],self.packageSize]];
                }
                    
                }
                
                if (_updatedItemList[packageName] != nil) {
                    cell.packageItems.text = _updatedItemList[packageName];
                }
                else {
                    cell.packageItems.text = result;
            
                }
            }
        NSLog(@"CFRAIP: %@", result);
        
        
        if (_updatedPrice[packageName] != nil) {
            NSString *priceString = [NSString stringWithFormat:@"$%0.2f", [_updatedPrice[packageName] floatValue]];
            cell.packagePriceLabel.text = priceString;
        }
        else {
        float firstPrice = [self firstPriceFor:packageName];
        NSLog(@"Price: %0.2f", firstPrice);
            
        NSString *priceString = [NSString stringWithFormat:@"$%0.2f", firstPrice];
        cell.packagePriceLabel.text = priceString;
        }
        
    return cell;
        
    }
    
    if (indexPath.section == 1) {
        
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
    for(int j=0; j<[self.items[packageName] count]; j++){
        NSDictionary  *item = self.items[packageName][j];
        
        if([[packageName lowercaseString] isEqualToString:@"liquor"]){
            if([[item[@"itemName"] lowercaseString] isEqualToString:@"absolut"]){
                float ppu = [item[@"itemPrice"] floatValue];
                float quantity = 1.0f*self.packageSize;
                price += ppu*quantity;
            }
            
        } else if([[packageName lowercaseString] isEqualToString:@"beer"]){
            
            if([[item[@"itemName"] lowercaseString] isEqualToString:self.beerItem]){
            float ppu = [item[@"itemPrice"] floatValue];
                
                int maxBeers = self.packageSize;
                if(maxBeers>2){
                    maxBeers = 2;
                }
                
            float quantity = 1.0f*maxBeers;
            price += ppu*quantity;
            }
            
        } else {
        
        float ppu = [item[@"itemPrice"] floatValue];
        float quantity = 1.0f*self.packageSize;
        price += ppu*quantity;
            
        }
    }
    return price;
}


-(void)updateQuantitiesFor:(NSString*)packageName with:(NSMutableArray*)edited {
    
    NSLog(@"We are getting %@",edited);
    
    NSMutableString *result = [[NSMutableString alloc] init];
    float newPrice = 0;
    
    for(int i=0; i<[edited count]; i++){
        PFObject *itemObjectId = edited[i][@"item"];
        int quantity = [edited[i][@"quantity"] intValue];
        
        NSLog(@"Item Object: %@", itemObjectId);
        
        if(i==[edited count]-1){
            [result appendString:[NSString stringWithFormat:@"%@ x%d", itemObjectId[@"itemName"], quantity]];
        } else {
            [result appendString:[NSString stringWithFormat:@"%@ x%d, ", itemObjectId[@"itemName"], quantity]];
        }
        
        newPrice += (quantity*1.0f)*[itemObjectId[@"itemPrice"] floatValue];
        
    }

    _updatedPrice[packageName] = [NSNumber numberWithFloat:newPrice];
    _updatedItemList[packageName] = result;
    
    
    NSLog(@"Result: %@", result);
    [self.tableView reloadData];
    
    /*int indexValue = (int)[self.packages indexOfObject:packageName];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexValue inSection:0];
    CartTableCell *cell = (CartTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    NSString *priceString = [NSString stringWithFormat:@"$%0.2f", newPrice];
    
    cell.packageItems.text = result;
    cell.packagePriceLabel.text = priceString;*/
    
    [self updateTotal];
}

-(void)updateTotal {
    
    _subtotal = 0;
    _taxes = 0;
    _finalTotal = 0;
    
    for(int i=0; i<self.packages.count; i++){
        
        NSString *packageName = self.packages[i];
        
        if (_updatedPrice[packageName] != nil) {
            _subtotal += [_updatedPrice[packageName] floatValue];
        }
        else {
            float firstPrice = [self firstPriceFor:packageName];
            _subtotal += firstPrice;
        }
    }
    
    
    
    //_subtotal = _subtotal * self.packageSize;
    
    _subtotal = _subtotal - _discount;
    
    _taxes = (_subtotal) * 0.06;
    
    _finalTotal = (_subtotal) + _taxes;
    
    [self.tableView reloadData];
    
    NSLog(@"SUBTOTAL: %f TAXES: %f TOTAL: %f Discount: %d",_subtotal, _taxes, _finalTotal, _discount);
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        
        NSString *packageName = [self.packages objectAtIndex:indexPath.row];
        for(int j=0; j<[self.items[packageName] count]; j++){
            NSDictionary  *item = self.items[packageName][j];
            [self.itemsToEdit addObject:item];
        }
        
        EditPackageTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPackage"];
        destViewController.packageSize = self.packageSize;
        destViewController.packageName = packageName;
        destViewController.beerItem = self.beerItem;
        destViewController.parent = self;
        destViewController.itemsToEdit = self.itemsToEdit;
        
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
    
    if (indexPath.section == 0) {
        return 118;
    }
    if (indexPath.section == 1) {
        return 250;
    }
    return 0;
}

- (IBAction)sizeButtonTapped:(id)sender {
    
    PickSizeViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PickSize"];
    
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
    
    if ([self.packages containsObject:@"Liquor"]) {
        
        _BOOZE = 150;
        [self showBoozeTerms];
    }
    else if ([self.packages containsObject:@"Beer"]) {
                _BOOZE = 150;
        [self showBoozeTerms];
    }
    else if ([self.packages containsObject:@"Wine"]) {
                _BOOZE = 150;
        [self showBoozeTerms];
    }
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
    
    if (self.packageSize == 1) {
        self.title = @"Small Basket";
    }
    else if (self.packageSize == 2) {
        self.title = @"Medium Basket";
    }
    else if (self.packageSize == 3) {
        self.title = @"Large Basket";
    }
    else if (self.packageSize == 4) {
        self.title = @"XL Basket";
    }
}


@end
