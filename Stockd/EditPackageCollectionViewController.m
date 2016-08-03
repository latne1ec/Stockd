//
//  EditPackageCollectionViewController.m
//  Stockd
//
//  Created by Alex Consel on 2016-07-19.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "EditPackageCollectionViewController.h"
#import "CartTableViewController.h"
#import "PackageCollectionViewLayout.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "AppDelegate.h"


@interface EditPackageCollectionViewController ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSMutableDictionary *editedCells;
@property (nonatomic, strong) UIView *headerview;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSArray *itemKeys;
@property (nonatomic, strong) NSArray *extraKeys;

@end

@implementation EditPackageCollectionViewController

@synthesize parent,packageSize;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _appDelegate = [[UIApplication sharedApplication] delegate];
    
    PackageCollectionViewLayout* theLayout = [[PackageCollectionViewLayout alloc] init];
    theLayout.footerReferenceSize = CGSizeMake(self.collectionView.frame.size.width, 60);
    theLayout.isEdit = YES;
    
    self.collectionView.collectionViewLayout = theLayout;
    
    if (_thePackage_itemsDictionary == NULL){
        _thePackage_itemsDictionary = [_appDelegate package_itemsDictionary];
    }
    
    if (_theExtraPackage_itemsDictionary == NULL){
        _theExtraPackage_itemsDictionary = [_appDelegate extraPackage_itemsDictionary];
    }
    
    if ([_thePackage_itemsDictionary valueForKey:_packageName]){
        _itemKeys = [[_thePackage_itemsDictionary valueForKey:_packageName] allKeys];
    }else{
        _extraKeys = [[_theExtraPackage_itemsDictionary valueForKey:_packageName] allKeys];
    }
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"cancelWhite"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissViewControllerAnimated:completion:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:(UIImage *) [[UIImage imageNamed:@"updateButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(dismissViewControllerAnimated:completion:)];
    
    
    
    
    if ([_thePackage_itemsDictionary valueForKey:_packageName]){
        self.title = [NSString stringWithFormat:@"Edit %@ Package", self.packageName];
    }else {
        self.title = [NSString stringWithFormat:@"Edit Extra %@ Items", self.packageName];
    }
    
    //Nav Bar Back Button Color
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.collectionView.layer.masksToBounds = YES;
    self.collectionView.clipsToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialBkg"]];
    [self.collectionView setBackgroundView:imageView];
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [self.collectionView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        if ([_thePackage_itemsDictionary valueForKey:_packageName]){
            return [_itemKeys count];
        }else {
            return [_extraKeys count];
        }
    }
    if (section ==1) {
        return 1;
    }
    return 0;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
//    
//    return CGSizeMake(collectionView.frame.size.width,250);
//}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TheCell" forIndexPath:indexPath];
    
    if([UIScreen mainScreen].bounds.size.height <= 568.0) {
        //iPhone 5
        CGRect dasFrame = CGRectMake(54, 17, 50, 50);
        if (CGRectEqualToRect(cell.itemImageViewer.frame, dasFrame)) {
            
        } else {
            cell.itemImageViewer.frame = CGRectMake(54, 17, 50, 50);
            cell.itemImageViewer.alpha = 0.0;
            [UIView animateWithDuration:0.2 delay:0.7 options:0 animations:^{
                cell.itemImageViewer.alpha = 1.0;
            } completion:^(BOOL finished) {
                
            }];
        }
    }

    cell.isEven = (indexPath.row % 2 == 0);
    cell.showTopLine = (indexPath.row < 2);
    
    if([[_thePackage_itemsDictionary valueForKey: _packageName] count]==0 && [[_theExtraPackage_itemsDictionary valueForKey: _packageName] count]==0){
        return cell;
    }
    
    if (indexPath.section == 0) {
        
        if ([_thePackage_itemsDictionary valueForKey:_packageName]){
            cell.itemNameLabel.text = [_itemKeys objectAtIndex:indexPath.row];
            
            cell.theImageURL = [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] imageURLString];
            
            cell.itemDetailLabel.text = [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemDetail];
            cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d",[[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
            
            cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
        }else{
            cell.itemNameLabel.text = [_extraKeys objectAtIndex:indexPath.row];
            
            cell.theImageURL = [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] imageURLString];
            
            cell.itemDetailLabel.text = [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemDetail];
            cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d",[[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
            
            cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
        }
        
        //NSLog(@"Price: %.02f", price);
        
        
//        if(_editedCells[[NSString stringWithFormat:@"c%d",(int)indexPath.row]]!=nil){
//            cell.itemQuantityLabel.text = _editedCells[[NSString stringWithFormat:@"c%d",(int)indexPath.row]];
//            
//        }
        
        cell.itemQuantityLabel.hidden = true;
        
        cell.decrementButton.tag = indexPath.row;
        cell.incrementButton.tag = indexPath.row;
    }
    
    cell.itemNameLabel.minimumFontSize = 8;
    cell.itemNameLabel.adjustsFontSizeToFitWidth = YES;
    
    [cell layoutIfNeeded];
    
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(16, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return CGSizeMake(self.view.frame.size.width, 160);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionFooter) {
        UpdateCartCollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"Footer" forIndexPath:indexPath];
        
        CALayer *btn = [footerView.updateCartButton layer];
        [btn setMasksToBounds:YES];
        [btn setCornerRadius:5.0f];
        
        reusableview = footerView;
    }
    
    return reusableview;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //NSLog(@"Scroll: %f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < 0) {
        self.headerview.backgroundColor = [UIColor clearColor];
    }
    else {
        
        self.headerview.backgroundColor = [UIColor colorWithRed:0.937 green:0.349 blue:0.639 alpha:1];
    }
}


-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)incrementQuantity:(id)sender {
    
    UIButton *button = (UIButton *) sender;
    [UIView animateWithDuration:0.074 animations:^{
        button.transform = CGAffineTransformMakeScale(1.24, 1.24);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.07 animations:^{
            button.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            
        }];
    }];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    ItemCollectionViewCell *cell = (ItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if (([_packageName isEqual:@"Beer"] && [self checkValidBeerLimit]) || (![_packageName isEqual:@"Beer"] && ![_packageName isEqual:@"21+"])){
        if ([_thePackage_itemsDictionary valueForKey:_packageName]){
            [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] increaseQuantity];
            cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
            cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
        }else{
            if (![[_theExtraPackage_itemsDictionary valueForKey: _packageName] valueForKey:cell.itemNameLabel.text]){
                [[_theExtraPackage_itemsDictionary valueForKey:_packageName] setObject:[[CartItemObject alloc] initItem:cell.itemNameLabel.text detail:cell.itemDetailLabel.text quantity: 1 price:[cell.itemPriceLabel.text floatValue] imageURLString:cell.theImageURL] forKey:cell.itemNameLabel.text];
            }else{
                [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] increaseQuantity];
            }
            
            cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
            cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
        }
    }
}

- (IBAction)decrementQuantity:(id)sender {
    
    UIButton *button = (UIButton *) sender;
    [UIView animateWithDuration:0.074 animations:^{
        button.transform = CGAffineTransformMakeScale(1.24, 1.24);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.07 animations:^{
            button.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            
        }];
    }];

    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:0];
    ItemCollectionViewCell *cell = (ItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    if ([_thePackage_itemsDictionary valueForKey:_packageName]){
        [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] decreaseQuantity];
        cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
        cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
    }else{
        int value = [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] - 1;
        if (value < 1){
            [[[_theExtraPackage_itemsDictionary valueForKey: _packageName] valueForKey:cell.itemNameLabel.text] setItemQuantity:0];
            //[[_theExtraPackage_itemsDictionary valueForKey: _packageName] removeObjectForKey:cell.itemNameLabel.text];
        }else{
            [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] decreaseQuantity];
        }
        cell.itemPriceLabel.text = [NSString stringWithFormat:@"$%.02f", [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity] * [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemPrice]];
        cell.itemQuantityLabel.text = [NSString stringWithFormat:@"%d", [[[_theExtraPackage_itemsDictionary valueForKey:_packageName] valueForKey:cell.itemNameLabel.text] itemQuantity]];
    }
}

-(BOOL) checkValidBeerLimit{
    if ([_packageName isEqual:@"Beer"]){
        int maxNumOfBeers = 6;
        int totalBeers = 0;
        for (NSString* itemNameKey in [_thePackage_itemsDictionary valueForKey:_packageName]){
            CartItemObject* cartItem = [[_thePackage_itemsDictionary valueForKey:_packageName] valueForKey:itemNameKey];
            totalBeers += cartItem.itemQuantity;
        }
        
        for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:@"21+"]){
            CartItemObject* cartItem = [[_theExtraPackage_itemsDictionary valueForKey:@"21+"] valueForKey:itemNameKey];
            if ([[_appDelegate beerItemsDictionary] valueForKey:itemNameKey]){
                totalBeers += cartItem.itemQuantity;
            }
        }
        
        return totalBeers < maxNumOfBeers;
    }
    return YES;
}


- (IBAction)updateCartTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)removeEmptyExtraItems{
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    for (NSString* packagesKey in _theExtraPackage_itemsDictionary){
        for (NSString* itemNameKey in [_theExtraPackage_itemsDictionary valueForKey:packagesKey]){
            if ([[[_theExtraPackage_itemsDictionary valueForKey: packagesKey] valueForKey:itemNameKey] itemQuantity] == 0){
                [arr addObject:itemNameKey];
            }
        }
        
        for (int i = 0; i < [arr count]; i++){
            [[_theExtraPackage_itemsDictionary valueForKey: packagesKey] removeObjectForKey:[arr objectAtIndex:i]];
        }
        
        [arr removeAllObjects];
    }
    
    
}

-(void) viewWillDisappear:(BOOL)animated{
    if ([[_theExtraPackage_itemsDictionary valueForKey:_packageName] count] < 1){
        [_theExtraPackage_itemsDictionary removeObjectForKey:_packageName];
    }
    [self removeEmptyExtraItems];
    [parent removeEmptyPackages];
    [parent initializeViewController];
}


@end
