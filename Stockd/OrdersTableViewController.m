//
//  OrdersTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 2/26/16.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "OrdersTableViewController.h"

@interface OrdersTableViewController ()

@property (nonatomic, strong) NSMutableArray *previousOrders;


@end

@implementation OrdersTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialBkg"]];
    [self.tableView setBackgroundView:imageView];
    
    [self getPastOrders];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.previousOrders.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    return cell;
}

-(void)getPastOrders {
    
    PFQuery *q = [PFQuery queryWithClassName:@"Orders"];
    [q whereKey:@"user" equalTo:[PFUser currentUser]];
    [q orderByDescending:@"createdAt"];
    [q findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
        } else {
         
            self.previousOrders = [objects mutableCopy];
            [self.tableView reloadData];
        }
    }];
}

@end
