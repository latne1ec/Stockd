//
//  FoodTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "FoodTableViewController.h"
#import "PackageDetailCollectionViewController.h"

@interface FoodTableViewController ()

@property (nonatomic, strong) PFRelation *foodRelation;
@property (nonatomic, strong) NSArray *food;
@property (nonatomic, strong) NSArray *drinks;


@end

@implementation FoodTableViewController

@synthesize tappedMenu;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Food";
    
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
    
    [self queryForFoodPackages];
    
}


-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationItem.hidesBackButton = YES;
   
}

-(void)viewWillDisappear:(BOOL)animated {
    
    self.navigationItem.hidesBackButton = YES;
}

-(void)reloadTheTable {
    
    [self.tableView reloadData];
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
    
    return self.food.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FoodTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    CALayer *btn = [cell.greenBkgView layer];
    [btn setMasksToBounds:YES];
    [btn setCornerRadius:5.0f];
    
    PFObject *object = [self.food objectAtIndex:indexPath.row];
    cell.itemNameLabel.text = [object objectForKey:@"packageName"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    //NSLog(@"Tapped Row %ld", (long)indexPath.row);
    PFObject *object = [self.food objectAtIndex:indexPath.row];
    NSString *packageName = [object objectForKey:@"packageName"];
    //NSLog(@"Package Name: %@", packageName);
    
    PackageDetailCollectionViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PackageDetail"];
    destViewController.packageName = packageName;
    destViewController.packageType = @"Food";
    
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

@end
