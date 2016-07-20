//
//  CartTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/7/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "CartTableViewController.h"
#import "AddressTableViewController.h"
#import "AddressViewController.h"
#import "PhoneTableViewController.h"
#import "AlcoholPolicyViewController.h"
#import "AppDelegate.h"
#import "EditPackageCollectionViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CartTableViewController ()

//@property (nonatomic, strong) NSMutableArray *itemsToEdit;
//@property (nonatomic, strong) NSMutableDictionary *updatedItemList;
//@property (nonatomic) NSMutableDictionary *updatedPrice;
//@property (nonatomic) NSDictionary *updatedPriceDic;
@property (nonatomic) float subtotal;
@property (nonatomic) float taxes;
@property (nonatomic) int discount;
@property (nonatomic) int theZeroSignal;
@property (nonatomic) int BOOZE;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSArray* packageKeys;
@property (nonatomic, strong) NSArray* extraKeys;
@property (nonatomic, strong) NSString *packageSizeString;
@property (nonatomic) BOOL isPastOrder;
@property (nonatomic, strong) NSMutableArray *zipcodes;
@property (nonatomic) BOOL canOrder;


@end

@implementation CartTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];

    _isPastOrder = true;
    
    if (_thePackage_itemsDictionary == NULL){
        _isPastOrder = false;
        _thePackage_itemsDictionary = [_appDelegate package_itemsDictionary];
    }
    
    if (_theExtraPackage_itemsDictionary == NULL){
        _isPastOrder = _isPastOrder && false;
        _theExtraPackage_itemsDictionary = [_appDelegate extraPackage_itemsDictionary];
    }
    
    _canOrder = false;
    
    
    [self initializeViewController];
    
}

-(void) initializeViewController {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"hasShownDeliveryInstructions"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _packageKeys = _thePackage_itemsDictionary.allKeys;
    _extraKeys = _theExtraPackage_itemsDictionary.allKeys;
    
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
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
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
    
    //NSLog(@"Das Beer Item is: %@", self.beerItem);
    //NSLog(@"Das Liquor Item is: %@", self.liquorItem);
    
    //NSLog(@"Order numbaaa 2: %@", self.orderNumber);
    
    // [[PFUser currentUser] setObject:[NSNumber numberWithInt:10] forKey:@"karmaCash"];
    //[[PFUser currentUser] saveInBackground];
    
    NSString *uuidStr = [[NSUUID UUID] UUIDString];
    self.orderNumber = uuidStr;
    
    
    // NSLog(@"All Items: %@ and Package size: %d",[self getAllItems], _appDelegate.packageSize);

}

-(void)viewDidAppear:(BOOL)animated {
    
    [self updateTotal];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return NO;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

-(void)checkIfParticipatingArea {
    
//    NSString *newUserAddress = [[PFUser currentUser] objectForKey:@"address"];
//    
//    if (newUserAddress == nil) {
//        
//    } else {
//        
//    }
    
    NSString *zipCode = [[PFUser currentUser] objectForKey:@"zipCode"];
    
    PFGeoPoint *userLocation = [[PFUser currentUser] objectForKey:@"userLocation"];
    
    if (userLocation == nil) {
        ///
        //S
         [self showAddressAlert];
    }
    
//    if (zipCode == nil) {
//
//        [self showAddressAlert];
//        
//    }
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
    int totalNumber = 0;
    for (NSString* extraPackageKey in _theExtraPackage_itemsDictionary){
        for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:extraPackageKey]){
            totalNumber += [[[_theExtraPackage_itemsDictionary valueForKey:extraPackageKey] valueForKey:itemNameKey] itemQuantity];
        }
    }
    
    if (!_isPastOrder){
        if (_thePackage_itemsDictionary.count + totalNumber == 0) {
            [self.navigationController popViewControllerAnimated:true];
            return;
        }
    }
    
    
    [self updateTotal];
    [self.tableView reloadData];
    [self setNavTitle];
    _canOrder = false;
    [self getCurrentZips];
    
}

-(void)getCurrentZips {
    
    self.zipcodes = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Zipcodes"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            
        } else {
            
            for (PFObject *object in objects) {
                NSString *zip = [object objectForKey:@"zipcode"];
                [self.zipcodes addObject:zip];
            }
            NSString *userZip = [[PFUser currentUser] objectForKey:@"zipCode"];
            if ([self.zipcodes containsObject:userZip]) {
                NSLog(@"We can deliver");
                _canOrder = true;
            } else {
                
                NSLog(@"we can't deliver!");
                _canOrder = false;
            }
        }
    }];
}

-(void)this {
    
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

-(void) removeEmptyPackages{
    for (NSString* packagesKey in _thePackage_itemsDictionary){
        int totalQt = 0;
        for (NSString* itemNameKey in [_thePackage_itemsDictionary valueForKey:packagesKey]){
            totalQt += [[[_thePackage_itemsDictionary valueForKey:packagesKey] valueForKey:itemNameKey] itemQuantity];
        }
        if (totalQt == 0){
            [_thePackage_itemsDictionary removeObjectForKey:packagesKey];
        }
    }
}

-(NSString*)getAllItems
{
   
    id strings = [@[] mutableCopy];
    
    for (NSString* packagesKey in _thePackage_itemsDictionary){
        for (NSString* itemNameKey in [_thePackage_itemsDictionary valueForKey:packagesKey]){
            NSMutableString *result = [[NSMutableString alloc] init];
            CartItemObject* cartItem = [[_thePackage_itemsDictionary valueForKey:packagesKey] valueForKey:itemNameKey];
            [result appendString:[NSString stringWithFormat:@"%@ x%d", [cartItem itemName],[cartItem itemQuantity]]];
            [strings addObject:result];
        }
    }
    
    for (NSString* packagesKey in _theExtraPackage_itemsDictionary){
        for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:packagesKey]){
            NSMutableString *result = [[NSMutableString alloc] init];
            CartItemObject* cartItem = [[_theExtraPackage_itemsDictionary valueForKey:packagesKey] valueForKey:itemNameKey];
            [result appendString:[NSString stringWithFormat:@"%@ x%d", [cartItem itemName],[cartItem itemQuantity]]];
            [strings addObject:result];
        }
    }

    if (_appDelegate.packageSize == 1) {
        self.packageSizeString = @"small";
    }
    if (_appDelegate.packageSize == 2) {
        self.packageSizeString = @"medium";
    }
    if (_appDelegate.packageSize == 3) {
        self.packageSizeString = @"large";
    }
    if (_appDelegate.packageSize == 4) {
        self.packageSizeString = @"extra large";
    }
    
    return [strings componentsJoinedByString:@"; "];
}

-(NSString*)getAllPackagesString
{
    
    id strings = [@[] mutableCopy];
    
    for (NSString* packagesKey in _thePackage_itemsDictionary){
        [strings addObject:packagesKey];
    }
    
    for (NSString* packagesKey in _theExtraPackage_itemsDictionary){
        [strings addObject:packagesKey];
    }
    
    return [strings componentsJoinedByString:@"; "];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CartTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    SubtotalTableCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
    
    if (indexPath.section == 0){
        NSString *packageName = [_packageKeys objectAtIndex:indexPath.row];
        NSMutableString *result = [[NSMutableString alloc] init];
        
        for (NSString* itemNameKey in [_thePackage_itemsDictionary valueForKey:packageName]){
            CartItemObject* cartItem = [[_thePackage_itemsDictionary valueForKey:packageName] valueForKey:itemNameKey];
            [result appendString:[NSString stringWithFormat:@"%@ x%d ", [cartItem itemName],[cartItem itemQuantity]]];
        }
        cell.packageNameLabel.text = [NSString stringWithFormat:@"%@ Package", packageName];
        cell.packageItems.text = result;
        float firstPrice = [self firstPriceFor:packageName];
        NSString *priceString = [NSString stringWithFormat:@"$%0.2f", firstPrice];
        cell.packagePriceLabel.text = priceString;
        
        Boolean modifiedFlag = false;
        for (NSString* itemNameKey in [_thePackage_itemsDictionary valueForKey:packageName]){
            if ([[[_thePackage_itemsDictionary valueForKey:packageName] valueForKey:itemNameKey] hasBeenModified] == true || [packageName isEqual:@"Beer"]){
                modifiedFlag = true;
                break;
            }
        }
        if (modifiedFlag){
            cell.lockIconButton.hidden = NO;
        }else{
            cell.lockIconButton.hidden = YES;
        }
        
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {
            [_thePackage_itemsDictionary removeObjectForKey:packageName];
            _packageKeys = _thePackage_itemsDictionary.allKeys;
            [self updateTotal];
            [tableView reloadData];
            return true;
        }]];
        
        return cell;
    }
    
    if (indexPath.section == 1){
        NSString *packageName = [_extraKeys objectAtIndex:indexPath.row];
        NSMutableString *result = [[NSMutableString alloc] init];
        
        for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:packageName]){
            CartItemObject* cartItem = [[_theExtraPackage_itemsDictionary valueForKey:packageName] valueForKey:itemNameKey];
            [result appendString:[NSString stringWithFormat:@"%@ x%d ", [cartItem itemName],[cartItem itemQuantity]]];
        }
        cell.packageNameLabel.text = [NSString stringWithFormat:@"Extra %@ Items", packageName];
        cell.packageItems.text = result;
        float firstPrice = [self firstPriceFor:packageName];
        NSString *priceString = [NSString stringWithFormat:@"$%0.2f", firstPrice];
        cell.packagePriceLabel.text = priceString;
        cell.lockIconButton.hidden = true;
        
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {
            [_theExtraPackage_itemsDictionary removeObjectForKey:packageName];
            _extraKeys = _theExtraPackage_itemsDictionary.allKeys;
            [self updateTotal];
            [tableView reloadData];
            return true;
        }]];
        
        return cell;
    }
    
    if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            cell2.separatorInset = UIEdgeInsetsMake(0.f, 10000.0f, 0.f, 0.0f);
        }
        
        CALayer *btn = [cell2.getStockdButton layer];
        [btn setMasksToBounds:YES];
        [btn setCornerRadius:5.0f];
        
        if (_isPastOrder){
            [cell2.getStockdButton setTitle:@"Get Stockd Again" forState:UIControlStateNormal];
            [cell2.sizeButton setHidden:YES];
            [cell2.getStockdButton setHidden:YES];
            cell2.getStockdAgainButton.layer.cornerRadius = 5;
            [cell2.getStockdAgainButton setHidden:NO];
            //[cell2.getStockdAgainButton setFrame:CGRectMake(0, 200, 180, 40)];
            
        }
        
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
    
    if ([_thePackage_itemsDictionary valueForKey:packageName]){
        for (NSString* itemNameKey in [_thePackage_itemsDictionary valueForKey:packageName]){
            CartItemObject* cartItem = [[_thePackage_itemsDictionary valueForKey:packageName] valueForKey:itemNameKey];
            price += cartItem.itemQuantity*cartItem.itemPrice;
        }
    }else{
        for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:packageName]){
            CartItemObject* cartItem = [[_theExtraPackage_itemsDictionary valueForKey:packageName] valueForKey:itemNameKey];
            price += cartItem.itemQuantity*cartItem.itemPrice;
        }
    }
    
    return price;
}

-(void)updateTotal {
    
    _subtotal = 0;
    _taxes = 0;
    _finalTotal = 0;
    
    for(int i=0; i<_thePackage_itemsDictionary.count; i++){
        
        NSString *packageName = _packageKeys[i];
        
        float firstPrice = [self firstPriceFor:packageName];
        _subtotal += firstPrice;
    }
    
    for(int i=0; i<_theExtraPackage_itemsDictionary.count; i++){
        
        NSString *packageName = _extraKeys[i];
        
        float firstPrice = [self firstPriceFor:packageName];
        _subtotal += firstPrice;
    }
    
    
    //_subtotal = _subtotal * self.packageSize;
    
    _subtotal = _subtotal - _discount;
    
    _taxes = (_subtotal) * 0.06;
    
    _finalTotal = (_subtotal) + _taxes;
    
    //NSLog(@"Final Total: %f", _finalTotal);
    
    [self.tableView reloadData];
    
    //NSLog(@"SUBTOTAL: %f TAXES: %f TOTAL: %f Discount: %d",_subtotal, _taxes, _finalTotal, _discount);
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        NSString *packageName = [[NSString alloc] init];
        
        if (indexPath.section == 0){
            packageName = [_packageKeys objectAtIndex:indexPath.row];
        }else if (indexPath.section == 1){
            packageName = [_extraKeys objectAtIndex:indexPath.row];
        }
        
        EditPackageCollectionViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPackage"];
        destViewController.thePackage_itemsDictionary = _thePackage_itemsDictionary;
        destViewController.theExtraPackage_itemsDictionary = _theExtraPackage_itemsDictionary;
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
        return 272;
    }
    return 0;
}

- (IBAction)sizeButtonTapped:(id)sender {
    
    PickSizeViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PickSize"];
    destViewController.thePackage_itemsDictionary = _thePackage_itemsDictionary;
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

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ((indexPath.section == 0 || indexPath.section == 1) && editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
    }
}

- (IBAction)getStockedTapped:(id)sender {
    
    PFGeoPoint *userLocation = [[PFUser currentUser] objectForKey:@"userLocation"];
    
    if (userLocation == nil) {
        
        [self showAddressAlert];
        return;
    }
    
    NSString *hasShownDeliveryInstructions = [[NSUserDefaults standardUserDefaults] objectForKey:@"hasShownDeliveryInstructions"];
    
    if (![hasShownDeliveryInstructions isEqualToString:@"YES"]) {
        
        [self showDeliveryInstructionsPopup];
        
    } else {
    
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
        
        if ([[PFUser currentUser] objectForKey:@"mobileNumber"] == nil) {
            
            [self showAddPhoneNumberAlert];
            return;
        }
        
        if (_finalTotal<=10.00) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Orders must be greater than $10.00" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
            
            return;
        }
        
        if (!_canOrder) {
            
            //NSLog(@"Not in your area yet HOLMESS!!");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Unfortunately we won't be able to process your order until we start serving your area. We'll notify you as soon as we do!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            
            [alert show];
            return;
        }
        
        else {
            
            NSString *userStripeToken = [[PFUser currentUser] objectForKey:@"stripeToken"];
            
//            if ([[PFUser currentUser] objectForKey:@"streetName"] == nil) {
//                
//                [self showAddressAlert];
//                return;
//            }
            
             if (userStripeToken == nil) {
                
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
}

-(void)showAddressAlert {
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Address Info" message:@"Before making any purchases on Stockd, you must first add your address information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alert show];
    
    AddressViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressVC"];
    destViewController.parent = self;
    destViewController.comingFromCart = true;
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

-(void)showNewAddressAlert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Address Info" message:@"Before making any purchases on Stockd, you must first add your address information. If you previously saved your address information, you must update it now to continue with your order." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    AddressViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddressVC"];
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

-(void)showAddPhoneNumberAlert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Phone Number" message:@"Before making any purchases on Stockd, you must first add your mobile phone number." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    PhoneTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Phone"];
    destViewController.parent = self;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:destViewController];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Phone Info"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
    [self.navigationController presentViewController:navigationController animated:YES completion:^{
    }];

}


-(void)chargeCustomer:(NSString *)customerId amount:(NSNumber *)amountInCents completion:(PFIdResultBlock)handler {
    
    //NSLog(@"Made it here");
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
                                        //[self getOrder];
                                        [self updateOrderInParse];
                                        
                                        //[self showConfirmation];
                                    }
                                }];
}

-(void)updateOrderInParse {
    
    NSString *deliveryInstructions = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentDeliveryInstructions"];
    
    [ProgressHUD show:nil Interaction:NO];
    PFObject *order = [PFObject objectWithClassName:@"Orders"];
    NSString *orderString = [self getAllItems];
    [order setObject:[PFUser currentUser] forKey:@"user"];
    [order setObject:orderString forKey:@"orderItems"];
    [order setObject:[self getAllPackagesString] forKey:@"orderPackages"];
    [order setObject:[NSNumber numberWithFloat: _finalTotal] forKey:@"price"];
    [order setObject:@"Order in Progress" forKey:@"deliveryDate"];
    [order setObject:deliveryInstructions forKey:@"deliveryInstructions"];
    [order setObject:self.packageSizeString forKey:@"orderSize"];
    [order saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [ProgressHUD showError:@"Network Error"];
            NSLog(@"Error: %@", error);
        }
        else {
            NSLog(@"Success UPDT");
            
            _theZeroSignal = _thePackage_itemsDictionary.count + _theExtraPackage_itemsDictionary.count;
            
            for (NSString* packagesKey in _thePackage_itemsDictionary){
                
                NSMutableArray* itemIdsArray = [[NSMutableArray alloc]init];
                NSMutableArray* itemQtsArray = [[NSMutableArray alloc]init];
                
                for (NSString* itemNameKey in [_thePackage_itemsDictionary valueForKey:packagesKey]){
                    NSMutableString *result = [[NSMutableString alloc] init];
                    CartItemObject* cartItem = [[_thePackage_itemsDictionary valueForKey:packagesKey] valueForKey:itemNameKey];
                    [itemIdsArray addObject:[cartItem itemName]];
                    [itemQtsArray addObject:[NSNumber numberWithInteger:[cartItem itemQuantity]]];
                    [result appendString:[NSString stringWithFormat:@"%@ x%d", [cartItem itemName],[cartItem itemQuantity]]];
                    //[strings addObject:result];
                }
                
                PFObject *packageOrder = [PFObject objectWithClassName:@"PackageOrder"];
                [packageOrder setObject:order.objectId forKey:@"orderID"];
                [packageOrder addObjectsFromArray:[itemIdsArray copy] forKey:@"itemsID"];
                [packageOrder addObjectsFromArray: [itemQtsArray copy] forKey:@"itemsQt"];
                [packageOrder setObject: packagesKey forKey:@"packageName"];
                [packageOrder setObject:@(YES) forKey:@"isPackage"];
                [packageOrder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        [ProgressHUD showError:@"Network Error"];
                        NSLog(@"Error: %@", error);
                    }
                    else {
                        NSLog(@"Success");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _theZeroSignal -= 1;
                            NSLog(@"Zero Signal %d", _theZeroSignal);
                            if (_theZeroSignal == 0){
                                [self endUploadingOrder];
                            }
                        });
                    }
                }];
            }
            
            for (NSString* packagesKey in _theExtraPackage_itemsDictionary){
                
                NSMutableArray* itemIdsArray = [[NSMutableArray alloc]init];
                NSMutableArray* itemQtsArray = [[NSMutableArray alloc]init];
                
                for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:packagesKey]){
                    NSMutableString *result = [[NSMutableString alloc] init];
                    CartItemObject* cartItem = [[_theExtraPackage_itemsDictionary valueForKey:packagesKey] valueForKey:itemNameKey];
                    [itemIdsArray addObject:[cartItem itemName]];
                    [itemQtsArray addObject:[NSNumber numberWithInteger:[cartItem itemQuantity]]];
                    [result appendString:[NSString stringWithFormat:@"%@ x%d", [cartItem itemName],[cartItem itemQuantity]]];
                    //[strings addObject:result];
                }
                
                PFObject *packageOrder = [PFObject objectWithClassName:@"PackageOrder"];
                [packageOrder setObject:order.objectId forKey:@"orderID"];
                [packageOrder addObjectsFromArray:[itemIdsArray copy] forKey:@"itemsID"];
                [packageOrder addObjectsFromArray: [itemQtsArray copy] forKey:@"itemsQt"];
                [packageOrder setObject: packagesKey forKey:@"packageName"];
                [packageOrder setObject: @(NO) forKey:@"isPackage"];
                [packageOrder saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (error) {
                        [ProgressHUD showError:@"Network Error"];
                        NSLog(@"Error: %@", error);
                    }
                    else {
                        NSLog(@"Success");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _theZeroSignal -= 1;
                            NSLog(@"Zero Signal %d", _theZeroSignal);
                            if (_theZeroSignal == 0){
                                [self endUploadingOrder];
                            }
                        });
                    }
                }];
            }
        }
    }];
}

-(void) endUploadingOrder{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"currentDeliveryInstructions"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [ProgressHUD dismiss];
    [self showConfirmation];
}

//-(void)getOrder {
//
//    NSLog(@"Get Order");
//    [ProgressHUD show:nil];
//    PFQuery *query = [PFQuery queryWithClassName:@"Orders"];
//    [query whereKey:@"orderNumber" equalTo:self.orderNumber];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if (error) {
//            NSLog(@"Error here dude");
//            [ProgressHUD dismiss];
//        }
//        else {
//            
//            self.order = object;
//            NSLog(@"Order: %@", self.order);
//            [self updateOrderInParse:self.order];
//            
//        }
//    }];
//}


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
    
    //NSLog(@"Error: %@", error);
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
    
    //NSLog(@"Here ya go: %@", _theExtraPackage_itemsDictionary);
    
    if ([_theExtraPackage_itemsDictionary valueForKey:@"21+"]) {
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"hasShownBoozeTerms"] isEqualToString:@"yes"]) {
            //NSLog(@"hi");
        }
        else {
            _BOOZE = 150;
            [self showBoozeTerms];
            [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"hasShownBoozeTerms"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    if ([_thePackage_itemsDictionary valueForKey:@"Liquor"]) {
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"hasShownBoozeTerms"] isEqualToString:@"yes"]) {
            //NSLog(@"hi");
        }
        else {
            _BOOZE = 150;
            [self showBoozeTerms];
            [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"hasShownBoozeTerms"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    else if ([_thePackage_itemsDictionary valueForKey:@"Beer"]) {
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"hasShownBoozeTerms"] isEqualToString:@"yes"]) {
            //NSLog(@"hi");
        }
        else {
            _BOOZE = 150;
            [self showBoozeTerms];
            [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"hasShownBoozeTerms"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    else if ([_thePackage_itemsDictionary valueForKey:@"Wine"]) {
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"hasShownBoozeTerms"] isEqualToString:@"yes"]) {
            //NSLog(@"hi");
        }
        else {
            _BOOZE = 150;
            [self showBoozeTerms];
            [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"hasShownBoozeTerms"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}


-(void)showDeliveryInstructionsPopup {
    
    DeliveryInstructionsPopupViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PopupTwo"];
    dvc.view.frame = CGRectMake(0, 0, 270.0f, 190.0f);
    [self presentPopUpViewController:dvc];
    
    [dvc.cancelButton addTarget:self action:@selector(dismissPopUpViewController) forControlEvents:UIControlEventTouchUpInside];
    [dvc.continueButton addTarget:self action:@selector(dismissPopUpViewController) forControlEvents:UIControlEventTouchUpInside];
    [dvc.continueButton addTarget:self action:@selector(getStockedTapped:) forControlEvents:UIControlEventTouchUpInside];
    [dvc.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)cancelButtonTapped {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"hasShownDeliveryInstructions"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    
    if (_appDelegate.packageSize == 1) {
        self.title = @"Small Basket";
    }
    else if (_appDelegate.packageSize == 2) {
        self.title = @"Medium Basket";
    }
    else if (_appDelegate.packageSize == 3) {
        self.title = @"Large Basket";
    }
    else if (_appDelegate.packageSize == 4) {
        self.title = @"XL Basket";
    }
}


@end
