//
//  OrderView.m
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "OrderView.h"
#import "UpdateCartTableCell.h"

#import "AddressTableViewController.h"
#import "AddressViewController.h"
#import "PhoneTableViewController.h"
#import "AlcoholPolicyViewController.h"
#import "AppDelegate.h"
#import "EditPackageCollectionViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation OrderView

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _appDelegate = [[UIApplication sharedApplication] delegate];
        
        [self queryForPackageItems];
        
        self.backgroundColor = [UIColor whiteColor];
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [panRecognizer setMinimumNumberOfTouches:1];
        [panRecognizer setMaximumNumberOfTouches:1];
        panRecognizer.delegate = self;
        [self addGestureRecognizer:panRecognizer];
        
        _initialPosition = self.frame.origin;
        
        _tableView=[[UITableView alloc]init];
        _tableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _tableView.dataSource=self;
        _tableView.delegate=self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _tableView.separatorColor = [UIColor clearColor];
        
        //[_tableView registerClass:[UpdateCartTableCell class] forCellReuseIdentifier:@"Cell"];
        UINib *nib = [UINib nibWithNibName:@"NIBOrderOneTableViewCell" bundle:nil];
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"OrderOneTableViewCell"];
        
        nib = [UINib nibWithNibName:@"NIBOrderTwoTableViewCell" bundle:nil];
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"OrderTwoTableViewCell"];
        
        nib = [UINib nibWithNibName:@"NIBOrderThreeTableViewCell" bundle:nil];
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"OrderThreeTableViewCell"];
        
        nib = [UINib nibWithNibName:@"NIBOrderFourTableViewCell" bundle:nil];
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"OrderFourTableViewCell"];
        
        nib = [UINib nibWithNibName:@"NIBOrderFiveTableViewCell" bundle:nil];
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"OrderFiveTableViewCell"];
        
        nib = [UINib nibWithNibName:@"FeesTableViewCell" bundle:nil];
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"FeesTableViewCell"];
        
        nib = [UINib nibWithNibName:@"JustPlacedOrderViewCell" bundle:nil];
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"JustPlacedOrderViewCell"];

        nib = [UINib nibWithNibName:@"PreviousOrderStatusCell" bundle:nil];
        [[self tableView] registerNib:nib forCellReuseIdentifier:@"PreviousOrderStatusCell"];

        [_tableView reloadData];
        [self addSubview:_tableView];
        
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                         byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight)
                                               cornerRadii:CGSizeMake(6.0, 6.0)];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
        
        _isUp = false;
        _justPlacedOrder = false;
        
        //_tableView.userInteractionEnabled = false;
        _tableView.scrollEnabled = false;
        
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 54, 0)];
        
        [TSMessage setDefaultViewController:_parentViewController];
        [TSMessage setDelegate:self];
        
        if ([[PFUser currentUser] objectForKey:@"karmaCash"] >0) {
            _discount = [[[PFUser currentUser] objectForKey:@"karmaCash"] intValue];
        } else {
            _discount = 0;
            
        }
        
        
        
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"hasShownDeliveryInstructions"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"This: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"hasShownDeliveryInstructions"]);
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
//    ScrollDirection scrollDirection;
//    if (self.lastContentOffset > scrollView.contentOffset.y) {
//         NSLog(@"Down");
//        scrollDirection = ScrollDirectionRight;
//    }
//    else if (self.lastContentOffset < scrollView.contentOffset.y) {
//        scrollDirection = ScrollDirectionLeft;
//         NSLog(@"Up");
//    }
//    self.lastContentOffset = scrollView.contentOffset.x;
//    
    // do whatever you need to with scrollDirection here.
}

-(void)queryForPackageItems {
    
    _itemsDictionary = [[NSMutableDictionary alloc] init];
    //[ProgressHUD show:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Items"];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        //NSLog(@"objetos: %@",objects);
        
        if (error) {
            [ProgressHUD showError:@"Unknown Error"];
            NSLog(@"Error: %@", error);
        }
        else {
            for(int i=0; i<[objects count]; i++){
                id item = objects[i];
                if(!_itemsDictionary[item[@"itemPackage"]]){
                    _itemsDictionary[item[@"itemPackage"]] = [[NSMutableDictionary alloc] init];
                }
                [_itemsDictionary[item[@"itemPackage"]] setObject:item forKey:item[@"itemName"]];
                
                if(!_itemsDictionary[item[@"itemCategory"]]){
                    _itemsDictionary[item[@"itemCategory"]] = [[NSMutableDictionary alloc] init];
                }
                [_itemsDictionary[item[@"itemCategory"]] setObject:item forKey:item[@"itemName"]];
            }
            
            if ([PFUser currentUser]) {
                [self getMostRecentOrder];
            }
        }
        //NSLog(@"Dictionary: %@", _itemsDictionary);
    }];
}

-(void) getMostRecentOrder {
    PFQuery *query = [PFQuery queryWithClassName:@"Orders"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    NSDate *yesterday = [NSDate dateWithTimeInterval:(-24*60*60) sinceDate:[NSDate date]];
    [query whereKey:@"deliveryFor" greaterThanOrEqualTo:yesterday];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            _previousOrder = object;
            _pastDeliveryDate = (NSDate *) _previousOrder[@"deliveryFor"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            _pastDeliveryDay = [dateFormatter stringFromDate: _pastDeliveryDate];
            
            [self getRecentOrderDetail];
        }
    }];
}

-(void) getRecentOrderDetail{
    self.pastOrderPackage_itemsDictionary = [[NSMutableDictionary alloc] init];
    self.pastOrderExtraPackage_itemsDictionary = [[NSMutableDictionary alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"PackageOrder"];
    [query whereKey:@"orderID" equalTo:_previousOrder.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 0) {
                
            } else {
                
                [ProgressHUD dismiss];
                for (PFObject *object in objects){
                    if ([object[@"isPackage"] boolValue] == YES){
                        NSString *thePackageName = object[@"packageName"];
                        [[self pastOrderPackage_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:thePackageName];
                        
                        NSArray *allItemsName = object[@"itemsID"];
                        NSArray *allItemsQt = object[@"itemsQt"];
                        
                        for (int i = 0; i < allItemsName.count; i++){
                            PFObject* itemPFObj = [[_itemsDictionary valueForKey:thePackageName]valueForKey: allItemsName[i]];
                            
                            id theItem = [[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity:[allItemsQt[i] integerValue] price:[itemPFObj[@"itemPrice"] floatValue] imageURLString:itemPFObj[@"itemImageUrl"]];
                            
                            [[[self pastOrderPackage_itemsDictionary] valueForKey:thePackageName] setObject:theItem forKey:allItemsName[i]];
                        }
                    }else{
                        NSString *thePackageName = object[@"packageName"];
                        [[self pastOrderExtraPackage_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:thePackageName];
                        
                        NSArray *allItemsName = object[@"itemsID"];
                        NSArray *allItemsQt = object[@"itemsQt"];
                        
                        for (int i = 0; i < allItemsName.count; i++){
                            PFObject* itemPFObj = [[_itemsDictionary valueForKey:thePackageName]valueForKey: allItemsName[i]];
                            
                            id theItem = [[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity:[allItemsQt[i] integerValue] price:[itemPFObj[@"itemPrice"] floatValue] imageURLString:itemPFObj[@"itemImageUrl"]];
                            
                            [[[self pastOrderExtraPackage_itemsDictionary] valueForKey:thePackageName] setObject:theItem forKey:allItemsName[i]];
                        }
                    }
                }
            }
            
            [self update];
        } else {
            [ProgressHUD showError:@"Unknown Error"];
            NSLog(@"%@", error);
        }
    }];
}

-(void) initializeViewController {
    [self update];
}

-(void) update{
    if ([_appDelegate package_itemsDictionary].count > 0 || [_appDelegate extraPackage_itemsDictionary].count >0){
        _thePackage_itemsDictionary = [_appDelegate package_itemsDictionary];
        _theExtraPackage_itemsDictionary = [_appDelegate extraPackage_itemsDictionary];
        _deliveryDate = [_appDelegate deliveryDate];
        _deliveryDay = [_appDelegate deliveryDay];
        _isPastOrder = false;
    }else if (_previousOrder){
        NSLog(@"Past order????");
        _isPastOrder = true;
        _thePackage_itemsDictionary = _pastOrderPackage_itemsDictionary;
        _theExtraPackage_itemsDictionary = _pastOrderExtraPackage_itemsDictionary;
        _deliveryDate = _pastDeliveryDate;
        _deliveryDay = _pastDeliveryDay;
        
    }else{
        _isPastOrder = false;
    }
    
    if (_thePackage_itemsDictionary){
        _packageKeys = _thePackage_itemsDictionary.allKeys;
    }else{
        _packageKeys = [[NSArray alloc]init];
    }
    
    if (_theExtraPackage_itemsDictionary){
        _extraKeys = _theExtraPackage_itemsDictionary.allKeys;
    }else{
        _extraKeys = [[NSArray alloc]init];
    }
    
    _canOrder = false;
    
    [self updateTotal];
    [self checkIfParticipatingArea];
    
    NSString *uuidStr = [[NSUUID UUID] UUIDString];
    self.orderNumber = uuidStr;
    
    //_updatedPrice = -1;
    
    _BOOZE = 0;
    
    [self checkForBooze];
    
    [self.tableView reloadData];
    _canOrder = false;
    [self getCurrentZips];
    
    NSString *string = [self calculateBasketItemCount];
    
}



-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if (_isUp && _tableView.contentOffset.y <= 0){
        return YES;
    }
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (_isPastOrder){
            return 3;
        }else{
            return 2;
        }
        
    }
    
    if (section == 1){
        return _packageKeys.count;
    }
    
    if (section == 2) {
        return _extraKeys.count;
    }
    
    if (section == 3) {
        
        return 6;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        return 57;
    }
    return 50;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* theCell = [[UITableViewCell alloc] init];
    
    switch (indexPath.section) {
        case 0:
        {

            // CHANGE!
            if (_justPlacedOrder && indexPath.row == 0) {
                JustPlacedOrderViewCell *cell = (JustPlacedOrderViewCell *)[tableView dequeueReusableCellWithIdentifier:@"JustPlacedOrderViewCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            if (_isPastOrder && indexPath.row == 0){
                
                PreviousOrderStatusCell *cell = (PreviousOrderStatusCell *)[tableView dequeueReusableCellWithIdentifier:@"PreviousOrderStatusCell" forIndexPath:indexPath];
                theCell = cell;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.orderStatusLabel.text = [NSString stringWithFormat:@"Previous Order Status: %@", _previousOrder[@"deliveryDate"]];
                cell.orderStatusLabel.alpha = 0.0;
                [UIView animateWithDuration:0.12 animations:^{
                    cell.orderStatusLabel.alpha = 0.7;
                } completion:^(BOOL finished) {
                    
                }];
                cell.orderStatusLabel.minimumFontSize = 8;
                cell.orderStatusLabel.adjustsFontSizeToFitWidth = YES;
                cell.sliderIconImageView.hidden = false;
                //cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
//                OrderTwoTableViewCell *cell = (OrderTwoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OrderTwoTableViewCell" forIndexPath:indexPath];
//                theCell = cell;
//                theCell.selectionStyle = UITableViewCellSelectionStyleNone;
//                cell.orderTitleLabel.alpha = 0.0;
//                cell.sliderIconImageView.hidden = false;
//                cell.orderTitleLabel.text = [NSString stringWithFormat:@"Previous Order Status: %@", _previousOrder[@"deliveryDate"]];
//                [UIView animateWithDuration:0.28 animations:^{
//                    cell.orderTitleLabel.alpha = 0.7;
//                } completion:^(BOOL finished) {
//                }];
                
            } else if ((!_isPastOrder && indexPath.row == 0) || (_isPastOrder && indexPath.row == 1)){
                OrderOneTableViewCell *cell = (OrderOneTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OrderOneTableViewCell" forIndexPath:indexPath];
                theCell = cell;
                theCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                if (_isPastOrder) {
                    cell.sliderIconImageView.hidden = true;
                } else {
                    cell.sliderIconImageView.hidden = false;
                }
                
                if (!_isPastOrder){
                    [cell.orderButton addTarget:self
                                 action:@selector(placeOrder)
                       forControlEvents:UIControlEventTouchUpInside];
                    [cell.orderButton setEnabled:YES];
                }else{
                    [cell.orderButton setEnabled:NO];
                }
                
                int totalNumber = 0;
                for (NSString* extraPackageKey in _theExtraPackage_itemsDictionary){
                    for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:extraPackageKey]){
                        totalNumber += [[[_theExtraPackage_itemsDictionary valueForKey:extraPackageKey] valueForKey:itemNameKey] itemQuantity];
                    }
                }
                
                if (_thePackage_itemsDictionary.count + totalNumber == 0) {
                    
                    cell.orderTitleLabel.text = @"Basket Empty";
                    cell.orderTitleLabel.alpha = 0.0;
                    cell.orderPriceLabel.alpha = 0.0;
                    cell.orderButton.alpha = 0.0;
                    [UIView animateWithDuration:0.2 delay:0.2 options:0 animations:^{
                        cell.orderTitleLabel.alpha = 0.7;
                        cell.orderPriceLabel.alpha = 0.7;
                        cell.orderButton.alpha = 1.0;

                    } completion:^(BOOL finished) {
                        
                    }];
                
                }else{
                    if (_thePackage_itemsDictionary.count == 1 && totalNumber == 0){
                        cell.orderTitleLabel.text = [NSString stringWithFormat:@"%@", [_packageKeys objectAtIndex:0]];
                    }else if (_theExtraPackage_itemsDictionary.count == 1 && _thePackage_itemsDictionary.count == 0){
                        //cell.orderTitleLabel.text = [NSString stringWithFormat:@"Extra %@ Items", [_extraKeys objectAtIndex:0]];
                       
//                        __block NSString *packageName = [_extraKeys objectAtIndex:0];
//                        NSMutableString *result = [[NSMutableString alloc] init];
//                        
//                        int i = 1;
//                        
//                        for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:packageName]){
//                            CartItemObject* cartItem = [[_theExtraPackage_itemsDictionary valueForKey:packageName] valueForKey:itemNameKey];
//                            if (i == 1) {
//                                [result appendString:[NSString stringWithFormat:@"%@ ", [cartItem itemName]]];
//                            }
//                            i++;
//                        }
//                        NSArray *array = [_theExtraPackage_itemsDictionary objectForKey:@"Food"];
//
//                        
//                        if (i == 1) {
//                         cell.orderTitleLabel.text = result;
//                        }
//                        
//                        
//                        else if (i>1) {
//                            cell.orderTitleLabel.text = [NSString stringWithFormat:@"%@ and %lu More", result,(array.count - 1)];
//                        }
                        
                        cell.orderTitleLabel.text = [self calculateBasketItemCount];
                        
                        
                    }else if (_thePackage_itemsDictionary.count >= 1){
//                        cell.orderTitleLabel.text = [NSString stringWithFormat:@"%@ & %lu More", [_packageKeys objectAtIndex:0], (_thePackage_itemsDictionary.count + _theExtraPackage_itemsDictionary.count - 1)];
                        cell.orderTitleLabel.text = [self calculateBasketItemCount];
                    }else if (_thePackage_itemsDictionary.count == 0 && _theExtraPackage_itemsDictionary.count > 1){
//                        cell.orderTitleLabel.text = [NSString stringWithFormat:@"%@ & %lu More", [_extraKeys objectAtIndex:0], (_theExtraPackage_itemsDictionary.count - 1)];
                        cell.orderTitleLabel.text = [self calculateBasketItemCount];
                    }
                }
                
                cell.orderPriceLabel.text = [NSString stringWithFormat:@"$%.02f", _finalTotal];
            }else if ((!_isPastOrder && indexPath.row == 1) || (_isPastOrder && indexPath.row == 2)){
                OrderTwoTableViewCell *cell = (OrderTwoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OrderTwoTableViewCell" forIndexPath:indexPath];
                theCell = cell;
                theCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.sliderIconImageView.hidden = true;
                cell.orderTitleLabel.text = @"Order Details";
//
//                FeesTableViewCell *cell = (FeesTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"FeesTableViewCell" forIndexPath:indexPath];
//                cell.titleLabel.text = @"Order Details";
//                cell.priceFeeLabel.text = @"";
//                [cell layoutIfNeeded];
            }
            break;
        }
        case 1:
        {
            OrderThreeTableViewCell *cell = (OrderThreeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OrderThreeTableViewCell" forIndexPath:indexPath];
            theCell = cell;
            theCell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            __block NSString *packageName = [_packageKeys objectAtIndex:indexPath.row];
            NSMutableString *result = [[NSMutableString alloc] init];
            
            for (NSString* itemNameKey in [_thePackage_itemsDictionary valueForKey:packageName]){
                CartItemObject* cartItem = [[_thePackage_itemsDictionary valueForKey:packageName] valueForKey:itemNameKey];
                [result appendString:[NSString stringWithFormat:@"%@ x%d, ", [cartItem itemName],[cartItem itemQuantity]]];
            }
            cell.orderTitleLabel.text = [NSString stringWithFormat:@"%@ Package", packageName];
            cell.orderDescriptionLabel.text = result;
            float firstPrice = [self firstPriceFor:packageName];
            NSString *priceString = [NSString stringWithFormat:@"$%0.2f", firstPrice];
            cell.orderPriceLabel.text = priceString;
            cell.tapToEditLabel.text = @"tap to edit";
            
            Boolean modifiedFlag = false;
            for (NSString* itemNameKey in [_thePackage_itemsDictionary valueForKey:packageName]){
                if ([[[_thePackage_itemsDictionary valueForKey:packageName] valueForKey:itemNameKey] hasBeenModified] == true || [packageName isEqual:@"Beer"]){
                    modifiedFlag = true;
                    break;
                }
            }
            
            cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {
                
                if (_isPastOrder) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to edit a previous order." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                } else {
      
                //[ProgressHUD show:nil];
                NSString *oldPackageName = cell.orderTitleLabel.text;
                NSString *dasPackage;
                if ([oldPackageName containsString:@"Package"]) {
                    dasPackage = [oldPackageName stringByReplacingOccurrencesOfString: @" Package" withString:@""];
                    packageName = dasPackage;
                    NSLog(@"package name here: %@", packageName);
                } else {
                    dasPackage = packageName;
                    if ([cell.orderTitleLabel.text containsString:@"Food"]) {
                        dasPackage = @"Food";
                    } else {
                    
                        dasPackage = @"Drink";
                    }
                    
                    NSLog(@"das package: %@", dasPackage);

                    [_thePackage_itemsDictionary removeObjectForKey:dasPackage];
                    [_theExtraPackage_itemsDictionary removeObjectForKey:dasPackage];
                    _extraKeys = _theExtraPackage_itemsDictionary.allKeys;
                    _packageKeys = _thePackage_itemsDictionary.allKeys;

                    [self updateTotal];
                    [tableView reloadData];
                    [ProgressHUD dismiss];
                    [_parentViewController.collectionView reloadData];
                    return true;
                }
                NSLog(@"Das Package: %@", dasPackage);
                [_thePackage_itemsDictionary removeObjectForKey:packageName];
                [_theExtraPackage_itemsDictionary removeObjectForKey:packageName];
                _extraKeys = _theExtraPackage_itemsDictionary.allKeys;
                _packageKeys = _thePackage_itemsDictionary.allKeys;

                [self updateTotal];
                [tableView reloadData];
                [ProgressHUD dismiss];
                [_parentViewController.collectionView reloadData];
                
                return true;
                }
                return false;
            }]];
        
            break;
        }
        case 2:
        {
            OrderThreeTableViewCell *cell = (OrderThreeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OrderThreeTableViewCell"   forIndexPath:indexPath];
            theCell = cell;
            theCell.selectionStyle = UITableViewCellSelectionStyleGray;
            
            __block NSString *packageName = [_extraKeys objectAtIndex:indexPath.row];
            NSMutableString *result = [[NSMutableString alloc] init];
            
            int j = 0;
            
            for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:packageName]){
                CartItemObject* cartItem = [[_theExtraPackage_itemsDictionary valueForKey:packageName] valueForKey:itemNameKey];
                NSArray *array = [_theExtraPackage_itemsDictionary objectForKey:@"Food"];
                NSArray *array2 = [_theExtraPackage_itemsDictionary objectForKey:@"Drink"];
                NSMutableArray *finalArray = [[NSMutableArray alloc] init];
                [finalArray addObjectsFromArray:array];
                [finalArray addObjectsFromArray:array2];
                
//                for(int j=0; j<[finalArray count]; j++){
//                    NSString  *item = finalArray[j];
//                    if(j==[_theExtraPackage_itemsDictionary[packageName] count]-1){
//                        [result appendString:[NSString stringWithFormat:@"%@ x1", item]];
//                    } else {
//                        [result appendString:[NSString stringWithFormat:@"%@ x1, ", item]];
//                    }
//                }
////
//                for(int j=0; j<[_theExtraPackage_itemsDictionary[packageName] count]; j++){
//                    CartItemObject* cartItemYo = cartItem[j];
//                    if(j==[finalArray count]-1){
//                        [result appendString:[NSString stringWithFormat:@"%@ x%d", [cartItem itemName],[cartItem itemQuantity]]];
//                    } else {
//                        [result appendString:[NSString stringWithFormat:@"%@ x%d, ", [cartItem itemName],[cartItem itemQuantity]]];
//                    }
//                }
                
                if(j==[finalArray count]-1){
                    [result appendString:[NSString stringWithFormat:@"%@ x%d", [cartItem itemName],[cartItem itemQuantity]]];
                } else {
                    [result appendString:[NSString stringWithFormat:@"%@ x%d, ", [cartItem itemName],[cartItem itemQuantity]]];
                }

                j++;
                
//                if (finalArray.count == 1) {
//                    [result appendString:[NSString stringWithFormat:@"%@ x%d ", [cartItem itemName],[cartItem itemQuantity]]];
//                } else {
//                    [result appendString:[NSString stringWithFormat:@"%@ x%d, ", [cartItem itemName],[cartItem itemQuantity]]];
//                }
                //[result appendString:[NSString stringWithFormat:@"%@ x%d ", [cartItem itemName],[cartItem itemQuantity]]];
            }
            cell.orderTitleLabel.text = [NSString stringWithFormat:@"Extra %@ Items", packageName];
            cell.orderDescriptionLabel.text = result;
            float firstPrice = [self firstPriceFor:packageName];
            NSString *priceString = [NSString stringWithFormat:@"$%0.2f", firstPrice];
            cell.orderPriceLabel.text = priceString;
            //cell.lockIconButton.hidden = true;
            cell.tapToEditLabel.text = @"tap to edit";
           
            cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {

                if (_isPastOrder) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to edit a previous order." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                } else {
                //[ProgressHUD show:nil];
                NSString *oldPackageName = cell.orderTitleLabel.text;
                NSString *dasPackage;
                NSLog(@"Package Name: %@", packageName);
                if ([oldPackageName containsString:@"Package"]) {
                    NSLog(@"Contains string package");
                    dasPackage = [oldPackageName stringByReplacingOccurrencesOfString: @" Package" withString:@""];
                    packageName = [NSString stringWithFormat:@"%@", dasPackage];
                    
                } else {
                    dasPackage = packageName;
                    if ([cell.orderTitleLabel.text containsString:@"Food"]) {
                        dasPackage = @"Food";
                    } else {
                        
                        dasPackage = @"Drink";
                    }
                    
                    NSLog(@"das package: %@", dasPackage);
                    
                    [_thePackage_itemsDictionary removeObjectForKey:dasPackage];
                    [_theExtraPackage_itemsDictionary removeObjectForKey:dasPackage];
                    _extraKeys = _theExtraPackage_itemsDictionary.allKeys;
                    _packageKeys = _thePackage_itemsDictionary.allKeys;
                    
                    [self updateTotal];
                    [tableView reloadData];
                    [ProgressHUD dismiss];
                    [_parentViewController.collectionView reloadData];
                    return true;

                }
                NSLog(@"Package Name again: %@", packageName);
                [_thePackage_itemsDictionary removeObjectForKey:packageName];
                [_theExtraPackage_itemsDictionary removeObjectForKey:packageName];
                _extraKeys = _theExtraPackage_itemsDictionary.allKeys;
                _packageKeys = _thePackage_itemsDictionary.allKeys;
                [_parentViewController.collectionView reloadData];
                [self updateTotal];
                [tableView reloadData];
                [ProgressHUD dismiss];
                    
                return true;
                }
                return false;
            }]];
        
            break;
        }
        case 3:
        {
            if (indexPath.row == 0){
                OrderThreeTableViewCell *cell = (OrderThreeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OrderThreeTableViewCell" forIndexPath:indexPath];
                theCell = cell;
                theCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.orderTitleLabel.text = @"Taxes";
                cell.orderDescriptionLabel.text = @"";
                cell.tapToEditLabel.text = @"";
                cell.orderPriceLabel.text = [NSString stringWithFormat:@"$%.02f", _taxes];
                cell.titleLabelWidth.constant = self.frame.size.width;
                [cell layoutIfNeeded];
                
            }else if (indexPath.row == 1){
                OrderThreeTableViewCell *cell = (OrderThreeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OrderThreeTableViewCell" forIndexPath:indexPath];
                theCell = cell;
                theCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.orderTitleLabel.text = @"Delivery Fee";
                cell.orderDescriptionLabel.text = @"";
                cell.tapToEditLabel.text = @"";
                cell.orderPriceLabel.text = [NSString stringWithFormat:@"$%.02f", 0.0];
                cell.titleLabelWidth.constant = self.frame.size.width;
                [cell layoutIfNeeded];

                
            }else if (indexPath.row == 2){
                
                OrderThreeTableViewCell *cell = (OrderThreeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OrderThreeTableViewCell" forIndexPath:indexPath];
                theCell = cell;
                theCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.orderTitleLabel.text = @"Discount";
                cell.orderDescriptionLabel.text = @"";
                cell.tapToEditLabel.text = @"";
                
                if(_discount>0){
                    cell.orderPriceLabel.text = [NSString stringWithFormat:@"-$%d.00", _discount];
                } else {
                    cell.orderPriceLabel.text = [NSString stringWithFormat:@"$%d.00", _discount];
                }
            } else if (indexPath.row == 3) {
                OrderFourTableViewCell *cell = (OrderFourTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OrderFourTableViewCell" forIndexPath:indexPath];
                theCell = cell;
                theCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.orderTitleLabel.text = @"Total";
                cell.orderPriceLabel.text = [NSString stringWithFormat:@"$%.02f", _finalTotal];
            }
            
            else if (indexPath.row == 4){
                OrderTwoTableViewCell *cell = (OrderTwoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OrderTwoTableViewCell" forIndexPath:indexPath];
                theCell = cell;
                theCell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.sliderIconImageView.hidden = true;
                cell.orderTitleLabel.text = @"Delivery Information";
            }else if (indexPath.row == 5){
                OrderFiveTableViewCell *cell = (OrderFiveTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"OrderFiveTableViewCell" forIndexPath:indexPath];
                theCell = cell;
                
                cell.orderTitleLabel.text = @"When";
                cell.orderDescriptionLabel.text = @"Tap to edit";
                if (_isPastOrder) {
                    cell.orderDescriptionLabel.text = @"";
                }
                
                if (!_deliveryDay) {
                    _deliveryDay = @"Now";
                }
                    
                [cell.orderButton setTitle: _deliveryDay forState:UIControlStateNormal];
                
                if (!_isPastOrder){
                    [cell.orderButton addTarget:self
                                     action:@selector(showPicker)
                           forControlEvents:UIControlEventTouchUpInside];
                    [cell.orderButton setEnabled:YES];
                }else{
                    [cell.orderButton setEnabled:NO];
                }
                
                //theCell.selectionStyle = UITableViewCellSelectionStyleGray;
                theCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            break;
        }
        default:
            break;
    }
    
    //cell.textLabel.text = @"YO";
    return theCell;
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView{
    return 8;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    switch (row) {
        case 0:
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: [NSDate date]];
            return @"Now";
            break;
        }
        case 1:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:[NSDate date]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            return dayName;
            break;
        }
        case 2:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(2*24*60*60) sinceDate:[NSDate date]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            return dayName;
            break;
        }
        case 3:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(3*24*60*60) sinceDate:[NSDate date]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            return dayName;
            break;
        }
        case 4:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(4*24*60*60) sinceDate:[NSDate date]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            return dayName;
            break;
        }
        case 5:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(5*24*60*60) sinceDate:[NSDate date]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            return dayName;
            break;
        }
        case 6:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(6*24*60*60) sinceDate:[NSDate date]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            return dayName;
            break;
        }
        case 7:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(7*24*60*60) sinceDate:[NSDate date]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            return dayName;
            break;
        }
            
        default:
        {
            return @"ERROR";
            break;
        }
    }
}

- (void)czpickerView:(CZPickerView *)pickerView
didConfirmWithItemAtRow:(NSInteger)row{
    switch (row) {
        case 0:
        {
            NSDate *today = [NSDate date];
            _deliveryDate = today;
            
            _deliveryDay = @"Now";
            break;
        }
        case 1:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(24*60*60) sinceDate:[NSDate date]];
            _deliveryDate = tomorrow;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            
            _deliveryDay = dayName;
            
            break;
        }
        case 2:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(2*24*60*60) sinceDate:[NSDate date]];
            _deliveryDate = tomorrow;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            
            _deliveryDay = dayName;
            break;
        }
        case 3:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(3*24*60*60) sinceDate:[NSDate date]];
            _deliveryDate = tomorrow;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            
            _deliveryDay = dayName;
            break;
        }
        case 4:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(4*24*60*60) sinceDate:[NSDate date]];
            _deliveryDate = tomorrow;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            
            _deliveryDay = dayName;
            break;
        }
        case 5:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(5*24*60*60) sinceDate:[NSDate date]];
            _deliveryDate = tomorrow;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            
            _deliveryDay = dayName;
            break;
        }
        case 6:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(6*24*60*60) sinceDate:[NSDate date]];
            _deliveryDate = tomorrow;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            
            _deliveryDay = dayName;
            break;
        }
        case 7:
        {
            NSDate *tomorrow = [NSDate dateWithTimeInterval:(7*24*60*60) sinceDate:[NSDate date]];
            _deliveryDate = tomorrow;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE"];
            NSString *dayName = [dateFormatter stringFromDate: tomorrow];
            
            _deliveryDay = dayName;
            break;
        }
            
        default:
        {
            break;
        }
    }
    
    _appDelegate.deliveryDate = _deliveryDate;
    _appDelegate.deliveryDay = _deliveryDay;
    [_tableView reloadData];
}

-(void) showPicker{
    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:@"Delivery Date"
                                                   cancelButtonTitle:@"Cancel"
                                                  confirmButtonTitle:@"Confirm"];
    picker.delegate = self;
    picker.dataSource = self;
    [picker show];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_isPastOrder){
        NSLog(@"here");
        return;
    }
    
    if (indexPath.section == 3 && indexPath.row == 3){
        //[self showDeliveryInstructionsPopup];
        return;
    }else if (indexPath.section == 3 && indexPath.row == 5){
        NSLog(@"show picker!");
        [self showPicker];
    }
    
    if (indexPath.section == 1 || indexPath.section == 2) {
        NSString *packageName = [[NSString alloc] init];
        
        if (indexPath.section == 1){
            packageName = [_packageKeys objectAtIndex:indexPath.row];
        }else if (indexPath.section == 2){
            packageName = [_extraKeys objectAtIndex:indexPath.row];
        }
        
        EditPackageCollectionViewController *destViewController = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:@"EditPackage"];
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
        [self.parentViewController.navigationController presentViewController:navigationController animated:YES completion:^{
        }];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint vel = [recognizer velocityInView:self];
    if (vel.y > 0) {
        _tableView.scrollEnabled = false;
    }
    
    float yPosition = self.frame.origin.y;
    float height = self.bounds.size.height;
    
    NSLog(@"Hi: %f", yPosition/height);

        if (yPosition/height < .3f) {
            
            CGPoint translation = [recognizer translationInView:self];
            if (!(_isUp && translation.y < 0)){
                recognizer.view.center = CGPointMake(self.frame.size.width/2,
                                                     recognizer.view.center.y + translation.y*.4);
            }
            [recognizer setTranslation:CGPointMake(0, 0) inView:self];
            //return;
        }
 
    
    
    CGPoint translation = [recognizer translationInView:self];
    
    recognizer.view.center = CGPointMake(self.frame.size.width/2,
                                         recognizer.view.center.y + translation.y);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if ((_isUp && yPosition/height > 0.3f) || (!_isUp && yPosition/height >= 0.9f)) {
            [UIView animateWithDuration:0.25 animations:^{
                self.frame = CGRectMake(0, _initialPosition.y+7, self.frame.size.width, self.frame.size.height);
                //_tableView.userInteractionEnabled = false;
                _tableView.scrollEnabled = false;
            } completion:^(BOOL finished) {
                _isUp = false;
                [UIView animateWithDuration:0.2 animations:^{
                    self.frame = CGRectMake(0, _initialPosition.y, self.frame.size.width, self.frame.size.height);
                    } completion:^(BOOL finished) {
                }];
            }];
        } else if ((!_isUp && yPosition/height < 0.9f)){
            [UIView animateWithDuration:0.25 animations:^{
                
            self.frame = CGRectMake(0, self.superview.frame.size.height - self.frame.size.height-6, self.frame.size.width, self.frame.size.height);
            
                _tableView.scrollEnabled = true;
                //_tableView.userInteractionEnabled = true;
            } completion:^(BOOL finished) {
                _isUp = true;
                [UIView animateWithDuration:0.2 animations:^{
                    self.frame = CGRectMake(0, self.superview.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
                } completion:^(BOOL finished) {
                }];
            }];
        }
    }
    
    if (_isUp) {
        //_tableView.scrollEnabled = true;
    }
}


-(NSString *)calculateBasketItemCount {
    
    NSString *basketString;
    NSArray *array = [_theExtraPackage_itemsDictionary objectForKey:@"Food"];
    NSArray *array2 = [_theExtraPackage_itemsDictionary objectForKey:@"Drink"];
    NSArray *array3 = _thePackage_itemsDictionary.allKeys;
    NSMutableArray *finalArray = [[NSMutableArray alloc] init];
    [finalArray addObjectsFromArray:array];
    [finalArray addObjectsFromArray:array2];
    [finalArray addObjectsFromArray:array3];
    
    if (finalArray.count > 0) {
    
        if (finalArray.count == 1) {
            basketString = [NSString stringWithFormat:@"%@", [finalArray objectAtIndex:0]];
        } else {
            basketString = [NSString stringWithFormat:@"%@ and %lu more", [finalArray objectAtIndex:0], finalArray.count-1];
        }
        
        NSLog(@"Yooo: %@", basketString);
    }
    
    return basketString;
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
                //NSLog(@"We can deliver");
                _canOrder = true;
            } else {
                
                NSLog(@"we can't deliver!");
                _canOrder = false;
            }
        }
    }];
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

-(void)showAddressAlert {
    
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Address Info" message:@"Before making any purchases on Stockd, you must first add your address information." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //    [alert show];
    
    AddressViewController *destViewController = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:@"AddressVC"];
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
    [self.parentViewController.navigationController presentViewController:navigationController animated:YES completion:^{
    }];
}

-(void)showNewAddressAlert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Address Info" message:@"Before making any purchases on Stockd, you must first add your address information. If you previously saved your address information, you must update it now to continue with your order." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    AddressViewController *destViewController = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:@"AddressVC"];
    destViewController.parent = self;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:destViewController];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Address Info"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
    [self.parentViewController.navigationController presentViewController:navigationController animated:YES completion:^{
    }];
    
}

-(void)showAddPhoneNumberAlert {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Phone Number" message:@"Before making any purchases on Stockd, you must first add your mobile phone number." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
    PhoneTableViewController *destViewController = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:@"Phone"];
    destViewController.parent = self;
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:destViewController];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Phone Info"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
    [self.parentViewController.navigationController presentViewController:navigationController animated:YES completion:^{
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
    [order setObject:self.deliveryDate forKey:@"deliveryFor"];
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
    
    [ProgressHUD dismiss];
    _justPlacedOrder = true;
    [_tableView reloadData];
    
    if (_isUp) {
        [UIView animateWithDuration:0.5 animations:^{
            self.frame = CGRectMake(0, _initialPosition.y, self.frame.size.width, self.frame.size.height);
            _tableView.userInteractionEnabled = false;
        } completion:^(BOOL finished) {
            _isUp = false;
        }];
    }
    
    if ([_appDelegate package_itemsDictionary] !=nil) {
        [[_appDelegate package_itemsDictionary] removeAllObjects];
    }
    
    if ([_appDelegate extraPackage_itemsDictionary] !=nil) {
        [[_appDelegate extraPackage_itemsDictionary] removeAllObjects];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        [_tableView reloadData];
        [self getMostRecentOrder];
    } completion:^(BOOL finished) {
        
    }];
    
    
    
//    ConfirmationTableViewController *cvc = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:@"Confirmation"];
//    cvc.subtotal = _finalTotal;
//    UINavigationController *navigationController =
//    [[UINavigationController alloc] initWithRootViewController:cvc];
//    UIBarButtonItem *newBackButton =
//    [[UIBarButtonItem alloc] initWithTitle:@""
//                                     style:UIBarButtonItemStylePlain
//                                    target:nil
//                                    action:nil];
//    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
//    
//    [self.parentViewController.navigationController pushViewController:cvc animated:YES];
    
    
    
}

-(void)showError:(NSError *)error {
    
    //NSLog(@"Error: %@", error);
    [TSMessage showNotificationInViewController:self.parentViewController.navigationController
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

-(void)getStockedTapped:(id)sender{
    [self placeOrder];
}

-(void) placeOrder{
    int totalNumber = 0;
    for (NSString* extraPackageKey in _theExtraPackage_itemsDictionary){
        for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:extraPackageKey]){
            totalNumber += [[[_theExtraPackage_itemsDictionary valueForKey:extraPackageKey] valueForKey:itemNameKey] itemQuantity];
        }
    }
    
    if (_thePackage_itemsDictionary.count + totalNumber == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cart Empty" message:@"Your cart is empty. Add a package or two before checking out!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
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
        
        //CHANGE!!
        if (_finalTotal<=0.00) {
            
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
                
                PaymentTableViewController *destViewController = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:@"Payment"];
                destViewController.parent = self;
                UINavigationController *navigationController =
                [[UINavigationController alloc] initWithRootViewController:destViewController];
                UIBarButtonItem *newBackButton =
                [[UIBarButtonItem alloc] initWithTitle:@"Payment Info"
                                                 style:UIBarButtonItemStylePlain
                                                target:nil
                                                action:nil];
                [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
                [self.parentViewController.navigationController presentViewController:navigationController animated:YES completion:^{
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


-(void)showDeliveryInstructionsPopup {
    
    DeliveryInstructionsPopupViewController *dvc = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:@"PopupTwo"];
    dvc.view.frame = CGRectMake(0, 0, 270.0f, 190.0f);
    [self.parentViewController presentPopUpViewController:dvc];
    
    [dvc.cancelButton addTarget:self.parentViewController action:@selector(dismissPopUpViewController) forControlEvents:UIControlEventTouchUpInside];
    [dvc.continueButton addTarget:self.parentViewController action:@selector(dismissPopUpViewController) forControlEvents:UIControlEventTouchUpInside];
    [dvc.continueButton addTarget:self action:@selector(getStockedTapped:) forControlEvents:UIControlEventTouchUpInside];
    [dvc.cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)cancelButtonTapped {
    
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"hasShownDeliveryInstructions"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)showBoozeTerms {
    
    AlcoholPolicyViewController *cvc = [self.parentViewController.storyboard instantiateViewControllerWithIdentifier:@"AlcoholPolicy"];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:cvc];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Alcohol Policy"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self.parentViewController.navigationController navigationItem] setBackBarButtonItem:newBackButton];
    [self.parentViewController.navigationController presentViewController:navigationController animated:YES completion:^{
    }];
    
}

@end
