//
//  BoozeTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/6/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "BoozeTableViewController.h"

@interface BoozeTableViewController ()

@property (nonatomic, strong) NSArray *booze;


@end

@implementation BoozeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"21+";
    
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
    
    [self queryForBoozePackages];
    
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return NO;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.booze.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    BoozeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    CALayer *btn = [cell.greenBkgView layer];
    [btn setMasksToBounds:YES];
    [btn setCornerRadius:5.0f];
    
    PFObject *object = [self.booze objectAtIndex:indexPath.row];
    cell.packageNameLabel.text = [object objectForKey:@"packageName"];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Tapped Row %ld", (long)indexPath.row);
    PFObject *object = [self.booze objectAtIndex:indexPath.row];
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
//                                     style:UIBarButtonItemStyleBordered
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

@end
