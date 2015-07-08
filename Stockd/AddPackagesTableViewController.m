//
//  AddPackagesTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "AddPackagesTableViewController.h"
#import "CameraViewController.h"
#import "BBBadgeBarButtonItem.h"


@interface AddPackagesTableViewController ()


@property (nonatomic, strong) NSArray *booze;
@property (nonatomic, strong) NSMutableArray *packages;
@property (nonatomic, strong) NSMutableDictionary *itemsDictionary;




@end

@implementation AddPackagesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.packages = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Orders"];
    [query whereKey:@"orderNumber" equalTo:self.orderNumber];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            
        }
        else {
            self.order = object;
            NSLog(@"Order: %@", self.order);
        }
    }];
    
    
    self.title = @"Add Packages";
    self.navigationItem.backBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.tableFooterView = [UIView new];

    //Nav Bar Back Button Color
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(closeTheController)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cartIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(goToCartScreen)];
    
    
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
    
    [self queryForFoodPackages];
    [self queryForDrinkPackages];
    [self queryForBoozePackages];
    
    [self queryForPackageItems];
    
}

-(void)closeTheController {
    //[ProgressHUD show:nil];
    CameraViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Camera"];
    [self.navigationController pushViewController:cvc animated:NO];
    
}

-(void)goToCartScreen {
    
    NSLog(@"Cart: %@", self.packages);
    if (self.packages.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cart Empty" message:@"Your cart is empty. Add a package or two before checking out!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    else {
    
    CartTableViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Cart"];
    cvc.packages = self.packages;
        cvc.items = _itemsDictionary;
    [self.navigationController pushViewController:cvc animated:YES];
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [ProgressHUD dismiss];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    //[[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor clearColor]];

//    [[UIView appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"initialBkg"]]];
    
    
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setFont:[UIFont fontWithName:@"BELLABOO-Regular" size:24]];

    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextAlignment:NSTextAlignmentCenter];
    [[UILabel appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTextColor:[UIColor whiteColor]];
    
    [[UIButton appearanceWhenContainedIn:[UITableViewHeaderFooterView class], nil] setTintColor:[UIColor blackColor]];
    
    
    if (section == 0) {
        return @"Food";
    }
    if (section == 1) {
        return @"Drinks";
    }
    if (section == 2) {
        return @"Booze";
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = [UIColor clearColor];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (self.tableView.contentOffset.y > 100) {
        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 38;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    if (section == 0) {
        return self.food.count;
    }
    if (section == 1) {
        return self.drinks.count;
    }
    if (section == 2) {
        return 0;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    PackageTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    CALayer *btn = [cell.greenBkgView layer];
    [btn setMasksToBounds:YES];
    [btn setCornerRadius:5.0f];
    
    if (indexPath.section == 0) {
        
        PFObject *object = [self.food objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        cell.packageNameLabel.text = [NSString stringWithFormat:@"+ %@", packageName];
        
        if (![self.packages containsObject:packageName]) {
            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            
            
        } else {
            
            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
        }
        
    return cell;
        
    }
    
    if (indexPath.section == 1) {
        PFObject *object = [self.drinks objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        cell.packageNameLabel.text = [NSString stringWithFormat:@"+ %@", packageName];
        
        if (![self.packages containsObject:packageName]) {
            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            
            
        } else {
            
            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
        }

        return cell;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PackageTableCell *cell = (PackageTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        PFObject *object = [self.food objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        if ([self.packages containsObject:packageName]) {
            [self.packages removeObject:packageName];
            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            
        } else {
            
            [self.packages addObject:packageName];
            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
        }
    }
    else {
        
        PFObject *object = [self.drinks objectAtIndex:indexPath.row];
        NSString *packageName = [object objectForKey:@"packageName"];
        if ([self.packages containsObject:packageName]) {
            [self.packages removeObject:packageName];
            cell.greenBkgView.backgroundColor = [UIColor colorWithRed:0.314 green:0.89 blue:0.761 alpha:1];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"+ %@", packageName];
            
        } else {
            [self.packages addObject:packageName];
            cell.greenBkgView.backgroundColor = [UIColor lightGrayColor];
            cell.packageNameLabel.text = [ NSString stringWithFormat:@"- %@", packageName];
        }
    }
}

-(void)queryForFoodPackages {
    
    [ProgressHUD show:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Packages"];
    [query whereKey:@"packageCategory" equalTo:@"Food"];
    [query orderByAscending:@"packageName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:@"Error"];
        }
        else {
            [ProgressHUD dismiss];
            self.food = objects;
            [self.tableView reloadData];
        }
    }];
}

-(void)queryForDrinkPackages {
    
    [ProgressHUD show:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Packages"];
    [query whereKey:@"packageCategory" equalTo:@"Drinks"];
    [query orderByAscending:@"packageName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:@"Error"];
        }
        else {
            [ProgressHUD dismiss];
            self.drinks = objects;
            [self.tableView reloadData];
        }
    }];
}

-(void)queryForBoozePackages {
    
    [ProgressHUD show:nil];
    PFQuery *query = [PFQuery queryWithClassName:@"Packages"];
    [query whereKey:@"packageCategory" equalTo:@"21+"];
    [query orderByAscending:@"packageName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            [ProgressHUD showError:@"Error"];
        }
        else {
            [ProgressHUD dismiss];
            self.booze = objects;
            [self.tableView reloadData];
        }
    }];
}

-(void)queryForPackageItems {
    
    _itemsDictionary = [[NSMutableDictionary alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Items"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
        }
        else {
            for(int i=0; i<[objects count]; i++){
                id item = objects[i];
                if(!_itemsDictionary[item[@"itemPackage"]]){
                    _itemsDictionary[item[@"itemPackage"]] = [[NSMutableArray alloc] init];
                }
                [_itemsDictionary[item[@"itemPackage"]] addObject:item];
            }
        }
    }];
}



@end
