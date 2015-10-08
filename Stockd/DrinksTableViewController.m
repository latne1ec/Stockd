//
//  DrinksTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "DrinksTableViewController.h"

@interface DrinksTableViewController ()

@property (nonatomic, strong) NSArray *drinks;

@end

@implementation DrinksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Drinks";
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
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
    
    [self queryForDrinkPackages];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.drinks.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DrinksTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    // Configure the cell...
    
    CALayer *btn = [cell.greenBkgView layer];
    [btn setMasksToBounds:YES];
    [btn setCornerRadius:5.0f];
    
    PFObject *object = [self.drinks objectAtIndex:indexPath.row];
    cell.packageNameLabel.text = [object objectForKey:@"packageName"];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Tapped Row %ld", (long)indexPath.row);
    PFObject *object = [self.drinks objectAtIndex:indexPath.row];
    NSString *packageName = [object objectForKey:@"packageName"];
    NSLog(@"Package Name: %@", packageName);
    
    PackageDetailViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PackageDetail"];
    destViewController.packageName = packageName;
    
    [self.navigationController pushViewController:destViewController animated:YES];
    [ProgressHUD show:nil];
    
//    UINavigationController *navigationController =
//    [[UINavigationController alloc] initWithRootViewController:destViewController];
//    UIBarButtonItem *newBackButton =
//    [[UIBarButtonItem alloc] initWithTitle:@"Address Info"
//                                     style:UIBarButtonItemStylePlain
//                                    target:nil
//                                    action:nil];
//    [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
//    [ProgressHUD show:nil];
//    [self.navigationController presentViewController:navigationController animated:YES completion:^{
//    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 74;
    }
    return 0;
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

@end
