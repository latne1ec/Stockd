//
//  EditPackageTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/7/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "EditPackageTableViewController.h"
#import "CartTableViewController.h"

@interface EditPackageTableViewController ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableDictionary *editedCells;

@end

@implementation EditPackageTableViewController

@synthesize parent,packageSize;


- (void)viewDidLoad {
    
    _editedCells = [[NSMutableDictionary alloc] init];
    
    if ([[self.packageName lowercaseString] isEqualToString:@"liquor"]) {
        for(int i=0; i<self.itemsToEdit.count; i++){
            NSString *name = [self.itemsToEdit objectAtIndex:i][@"itemName"];
            if([[name lowercaseString] isEqualToString:@"absolut"]){
                _editedCells[[NSString stringWithFormat:@"c%d",i]] = [NSString stringWithFormat:@"%d",packageSize];
            } else {
                _editedCells[[NSString stringWithFormat:@"c%d",i]] = @"0";
            }
        }
    } else if ([[self.packageName lowercaseString] isEqualToString:@"beer"]) {
        for(int i=0; i<self.itemsToEdit.count; i++){
            NSString *name = [self.itemsToEdit objectAtIndex:i][@"itemName"];
            if([[name lowercaseString] isEqualToString:self.beerItem]){
                
                int maxBeers = packageSize;
                
                if(maxBeers>2){
                    maxBeers = 2;
                }
                
                _editedCells[[NSString stringWithFormat:@"c%d",i]] = [NSString stringWithFormat:@"%d",maxBeers];
            } else {
            _editedCells[[NSString stringWithFormat:@"c%d",i]] = @"0";
            }
        }
    } else {
        for(int i=0; i<self.itemsToEdit.count; i++){
            
           _editedCells[[NSString stringWithFormat:@"c%d",i]] = [NSString stringWithFormat:@"%d",packageSize];
            
        }
        
    }
    
    
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    self.title = [NSString stringWithFormat:@"Edit %@ Package", self.packageName];
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
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return self.itemsToEdit.count;
    }
    if (section ==1) {
        
        return 1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    


    EditItemsTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UpdateCartTableCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"Cell2"];
    
    if([self.itemsToEdit count]==0){
        return cell;
    }
    
    
    if (indexPath.section == 0) {

    cell.itemNameLabel.text = [self.itemsToEdit objectAtIndex:indexPath.row][@"itemName"];
    cell.itemDetailLabel.text = [self.itemsToEdit objectAtIndex:indexPath.row][@"itemQuantity"];
    cell.itemQuantityLabel.text = @"1";
    
    float price = [[self.itemsToEdit objectAtIndex:indexPath.row][@"itemPrice"] floatValue];
    cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f",price];
        //NSLog(@"Price: %.02f", price);
    
        if(_editedCells[[NSString stringWithFormat:@"c%d",(int)indexPath.row]]!=nil){
            cell.itemQuantityLabel.text = _editedCells[[NSString stringWithFormat:@"c%d",(int)indexPath.row]];
            
        }
        
    cell.decrementButton.tag = indexPath.row;
    cell.incrementButton.tag = indexPath.row;
    }
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            cell2.separatorInset = UIEdgeInsetsMake(0.f, 10000.0f, 0.f, 0.0f);
        }
        
        CALayer *btn = [cell2.updateCartButton layer];
        [btn setMasksToBounds:YES];
        [btn setCornerRadius:5.0f];
        
        return cell2;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        return 70;
    }
    if (indexPath.section == 1) {
        return 122;
    }
    return 0;
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
    
}


-(NSMutableArray*)getQuantities
{
    NSIndexPath *indexPath;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for(int i=0; i<self.itemsToEdit.count; i++){
        indexPath = [NSIndexPath indexPathForRow:i inSection:0];

        PFObject* itemObject = self.itemsToEdit[i];
        
        NSString *quantity = @"1";
        if(_editedCells[[NSString stringWithFormat:@"c%d",i]]!=nil){
            quantity = _editedCells[[NSString stringWithFormat:@"c%d",i]];
            
        }
        
        [array addObject:@{@"quantity":quantity, @"item":itemObject}];
        
    }
    
    return array;
}

- (IBAction)incrementQuantity:(id)sender {
    
    if ([[self.packageName lowercaseString] isEqualToString:@"beer"]) {
        int cant = 0;
    for(int i=0; i<[[_editedCells allKeys] count]; i++){
        NSString *key = [_editedCells allKeys][i];
        cant += [_editedCells[key] intValue];
        if(cant>=2){
            break;
        }
    }
        if(cant>=2){
            return;
        }
    }
    

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    EditItemsTableCell *cell = (EditItemsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    int realQuantity = [cell.itemQuantityLabel.text intValue];
    
    if ([self.packageName isEqualToString:@"Beer"]) {
        NSLog(@"BEEERRR");
        
        if (realQuantity>=2){
            
        }
        else {
            realQuantity++;
        }
    }
    
    else if (realQuantity>=10){
        
    }
    else {
        realQuantity++;
    }
    
    cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", (int)realQuantity];
    
    _editedCells[[NSString stringWithFormat:@"c%d",(int)[sender tag]]] = [NSString stringWithFormat:@"%d", (int)realQuantity];
    
    //[self updatePrice];

}

- (IBAction)decrementQuantity:(id)sender {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    EditItemsTableCell *cell = (EditItemsTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    int realQuantity = [cell.itemQuantityLabel.text intValue];
    if(realQuantity<1){
        
    }
    else {
        realQuantity--;
    }
    
    cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", (int)realQuantity];
    
    _editedCells[[NSString stringWithFormat:@"c%d",(int)[sender tag]]] = [NSString stringWithFormat:@"%d", (int)realQuantity];
    
    //[self updatePrice];
    
}


- (IBAction)updateCartTapped:(id)sender {
    
    id edited = [self getQuantities];
    
    [parent updateQuantitiesFor:self.packageName with:edited];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
