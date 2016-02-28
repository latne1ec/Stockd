//
//  PreviousOrdersViewController.m
//  Stockd
//
//  Created by Alex Consel on 2016-02-22.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "PreviousOrdersViewController.h"
#import "AppDelegate.h"
#include "CartItemObject.h"
#include "CartTableViewController.h"

@interface PreviousOrdersViewController ()
@property (nonatomic, strong) NSString* currentUserID;
@property (nonatomic, strong) NSMutableArray* allPreviousOrders;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableDictionary *itemsDictionary;
@end

@implementation PreviousOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    [self queryForPackageItems];

    self.title = @"Past Orders";
    
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.layer.masksToBounds = YES;
    self.tableView.clipsToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialBkg"]];
    [self.tableView setBackgroundView:imageView];
    
    self.tableView.tableFooterView = [UIView new];
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
                    _itemsDictionary[item[@"itemPackage"]] = [[NSMutableDictionary alloc] init];
                }
                [_itemsDictionary[item[@"itemPackage"]] setObject:item forKey:item[@"itemName"]];
            }
            
            if ([PFUser currentUser]) {
                _currentUserID = [PFUser currentUser].objectId;
                [self getAllPreviousOrders];
            }
        }
        //NSLog(@"Dictionary: %@", _itemsDictionary);
    }];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allPreviousOrders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    PreviousOrderCell *cell = (PreviousOrderCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    PFObject *object = [self.allPreviousOrders objectAtIndex:indexPath.row];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM'-'dd'-'yyyy'";
    NSDate *date = [df stringFromDate:object.createdAt];
    
    cell.orderNameLabel.text = object[@"orderPackages"];
    
    cell.priceLabel.text = [NSString stringWithFormat:@"$%.02f", [object[@"price"] floatValue]];
    
    cell.deliveryDateLabel.tag = indexPath.row;
    cell.deliveryDateLabel.text = [NSString stringWithFormat:@"Delivered %@", date];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PFObject *order = [self.allPreviousOrders objectAtIndex:indexPath.row];
    
    _appDelegate.pastOrderPackage_itemsDictionary = [[NSMutableDictionary alloc] init];
    _appDelegate.pastOrderExtraPackage_itemsDictionary = [[NSMutableDictionary alloc] init];
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    PFQuery *query = [PFQuery queryWithClassName:@"PackageOrder"];
    [query whereKey:@"orderID" equalTo:order.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 0) {

            } else {
                for (PFObject *object in objects){
                    if ([object[@"isPackage"] boolValue] == YES){
                        NSString *thePackageName = object[@"packageName"];
                        [[_appDelegate pastOrderPackage_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:thePackageName];
                        
                        NSArray *allItemsName = object[@"itemsID"];
                        NSArray *allItemsQt = object[@"itemsQt"];
                        
                        for (int i = 0; i < allItemsName.count; i++){
                            PFObject* itemPFObj = [[_itemsDictionary valueForKey:thePackageName]valueForKey: allItemsName[i]];
                            
                            id theItem = [[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity:[allItemsQt[i] integerValue] price:[itemPFObj[@"itemPrice"] floatValue]];
                            
                            [[[_appDelegate pastOrderPackage_itemsDictionary] valueForKey:thePackageName] setObject:theItem forKey:allItemsName[i]];
                        }
                    }else{
                        NSString *thePackageName = object[@"packageName"];
                        [[_appDelegate pastOrderExtraPackage_itemsDictionary] setObject:[[NSMutableDictionary alloc] init] forKey:thePackageName];
                        
                        NSArray *allItemsName = object[@"itemsID"];
                        NSArray *allItemsQt = object[@"itemsQt"];
                        
                        for (int i = 0; i < allItemsName.count; i++){
                            PFObject* itemPFObj = [[_itemsDictionary valueForKey:thePackageName]valueForKey: allItemsName[i]];
                            
                            id theItem = [[CartItemObject alloc] initItem:itemPFObj[@"itemName"] detail:itemPFObj[@"itemQuantity"] quantity:[allItemsQt[i] integerValue] price:[itemPFObj[@"itemPrice"] floatValue]];
                            
                            [[[_appDelegate pastOrderExtraPackage_itemsDictionary] valueForKey:thePackageName] setObject:theItem forKey:allItemsName[i]];
                        }
                    }
                }
            }
            CartTableViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Cart"];
            cvc.thePackage_itemsDictionary = [_appDelegate pastOrderPackage_itemsDictionary];
            cvc.theExtraPackage_itemsDictionary = [_appDelegate pastOrderExtraPackage_itemsDictionary];
            [self.navigationController pushViewController:cvc animated:YES];
        } else {
            NSLog(@"%@", error);
        }
    }];
}

-(void)getAllPreviousOrders{
    
    [ProgressHUD show:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Orders"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            if (objects.count == 0) {
                self.noPreviousOrders = [[UILabel alloc] init];
                self.noPreviousOrders.frame = CGRectMake(0, self.view.frame.size.height/3, self.view.frame.size.width, 100);
                self.noPreviousOrders.textAlignment = NSTextAlignmentCenter;
                //label.center = self.view.center;
                self.noPreviousOrders.text = @"no previous orders";
                self.noPreviousOrders.backgroundColor = [UIColor clearColor];
                self.noPreviousOrders.textColor = [UIColor colorWithWhite:1.0 alpha:0.9];
                self.noPreviousOrders.font = [UIFont fontWithName:@"BELLABOO-Regular" size:18];
                [self.view addSubview:self.noPreviousOrders];
            } else {
                self.noPreviousOrders.hidden = YES;
                [self.noPreviousOrders removeFromSuperview];
            }
            [ProgressHUD dismiss];
            self.allPreviousOrders = [objects mutableCopy];
            [self.tableView reloadData];
            
        } else {
            [ProgressHUD showError:@"Network Error"];
        }
    }];
}

@end
