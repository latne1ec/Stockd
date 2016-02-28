//
//  PreviousOrdersViewController.m
//  Stockd
//
//  Created by Alex Consel on 2016-02-22.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "PreviousOrdersViewController.h"

@interface PreviousOrdersViewController ()
@property (nonatomic, strong) NSString* currentUserID;
@property (nonatomic, strong) NSMutableArray* allPreviousOrders;
@end

@implementation PreviousOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Past Orders";
    
    self.tableView.layer.masksToBounds = YES;
    self.tableView.clipsToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialBkg"]];
    [self.tableView setBackgroundView:imageView];
    
    
    self.tableView.tableFooterView = [UIView new];
    
    if ([PFUser currentUser]) {
        _currentUserID = [PFUser currentUser].objectId;
        [self getAllPreviousOrders];
    }
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
    
    cell.deliveryDateLabel.tag = indexPath.row;
    cell.deliveryDateLabel.text = [NSString stringWithFormat:@"Delivered %@", date];

    return cell;
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
