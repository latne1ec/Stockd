//
//  CartTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/7/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "CartTableViewController.h"

@interface CartTableViewController ()

@property (nonatomic, strong) NSMutableArray *itemsToEdit;
@property (nonatomic, strong) NSMutableDictionary *updatedItemList;
@property (nonatomic) NSMutableDictionary *updatedPrice;


@property (nonatomic) NSDictionary *updatedPriceDic;

@property (nonatomic) float subtotal;
@property (nonatomic) float taxes;
@property (nonatomic) float finalTotal;




@end

@implementation CartTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //_updatedPrice = -1;
    
    self.title = @"Basket";
    
    //NSLog(@"Items: %@",self.items);
    
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
    
    [self updateTotal];
    
}
-(void)viewWillAppear:(BOOL)animated {

    if (self.itemsToEdit != nil) {
        
        [self.itemsToEdit removeAllObjects];
    }
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CartTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    SubtotalTableCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
    
    if (indexPath.section == 0) {
    
    NSString *packageName = [self.packages objectAtIndex:indexPath.row];
    cell.packageNameLabel.text = [NSString stringWithFormat:@"%@ Package", packageName];
        
        
        NSMutableString *result = [[NSMutableString alloc] init];

            for(int j=0; j<[self.items[packageName] count]; j++){
                NSDictionary  *item = self.items[packageName][j];
                if(j==[self.items[packageName] count]-1){
                    [result appendString:[NSString stringWithFormat:@"%@ x1", item[@"itemName"]]];
                } else {
                    [result appendString:[NSString stringWithFormat:@"%@ x1, ", item[@"itemName"]]];
                }
                
                if (_updatedItemList[packageName] != nil) {
                    cell.packageItems.text = _updatedItemList[packageName];
                }
                else {
                    cell.packageItems.text = result;
                }
            }
        
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
        
        cell2.totalPriceLabel.text = [NSString stringWithFormat:@"$%.02f", _subtotal];
        
        return cell2;
    }
    
    return nil;
}

-(float)firstPriceFor:(NSString*)packageName
{
    
    float price = 0;
    for(int j=0; j<[self.items[packageName] count]; j++){
        NSDictionary  *item = self.items[packageName][j];
        
        float ppu = [item[@"itemPrice"] floatValue];
        float quantity = 1.0f;
        price += ppu*quantity;
        
    }
    
    return price;
}


-(void)updateQuantitiesFor:(NSString*)packageName with:(NSMutableArray*)edited
{
    
    self.title = @"Edited Basket";
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

-(void)updateTotal
{
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
    _taxes = _subtotal * 0.06;
    _finalTotal = _subtotal + _taxes;
    
    NSLog(@"SUBTOTAL: %f TAXES: %f TOTAL: %f",_subtotal, _taxes, _finalTotal);
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        
        NSString *packageName = [self.packages objectAtIndex:indexPath.row];
        for(int j=0; j<[self.items[packageName] count]; j++){
            NSDictionary  *item = self.items[packageName][j];
            [self.itemsToEdit addObject:item];
        }
        
        EditPackageTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EditPackage"];
        destViewController.packageName = packageName;
        destViewController.parent = self;
        destViewController.itemsToEdit = self.itemsToEdit;
        
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Address Info"
                                         style:UIBarButtonItemStyleBordered
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
        return 210;
    }
    return 0;
}

- (IBAction)getStockedTapped:(id)sender {
    
    NSString *userStripeToken = [[PFUser currentUser] objectForKey:@"stripeToken"];
    if (userStripeToken == nil) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Payment Method" message:@"Before making any purchases on Stockd, you must first enter a payment method." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];

        PaymentTableViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Payment"];
        destViewController.parent = self;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Payment Info"
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
        [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{
        }];
    }
    else {
        
        [ProgressHUD show:nil Interaction:NO];
        
        NSString *customerID = [[PFUser currentUser] objectForKey:@"customerID"];
        float amountInCents = _subtotal*100;
        NSNumber *amount = [NSNumber numberWithFloat:amountInCents];
        
        [self chargeCustomer:customerID amount:amount completion:^(id object, NSError *error) {
            if (error) {
                [ProgressHUD dismiss];
                [self showError:error];
            }
            else {
                NSLog(@"Object Up Here: %@", object);
            }
        }];
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
                                        [self showConfirmation];
                                }
                    }];
                                
}

-(void)showConfirmation {
    
    ConfirmationTableViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Confirmation"];
    cvc.subtotal = _subtotal;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:cvc];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
    [self.navigationController presentViewController:navigationController animated:YES completion:^{
    }];

    
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

@end
