//
//  AddressViewController.m
//  Stockd
//
//  Created by Alex Consel on 2016-03-23.
//  Copyright © 2016 Stockd. All rights reserved.
//

#import "AddressViewController.h"
@import MapKit;
@import GoogleMaps;

@interface AddressViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *appartmentNumberTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) GMSPlacesClient* placesClient;
@property (strong, nonatomic) MKLocalSearch* localsearch;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSMutableArray* places;
@property (strong, nonatomic) NSMutableArray* searchResults;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;

@property (strong, nonatomic) GMSPlace* thePlace;

@property BOOL validEntry;

@end

@implementation AddressViewController

@synthesize parent;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:_tapGesture];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _validEntry = NO;
    
    _addressTextField.delegate = self;
    
    _placesClient = [[GMSPlacesClient alloc] init];
    
    [self.view layoutIfNeeded];
    _tableViewHeight.constant = 0;
    [self.view layoutIfNeeded];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"initialBkg@2x"];
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    if ([[PFUser currentUser] objectForKey:@"address"]){
        _addressTextField.text = [[PFUser currentUser] objectForKey:@"address"];
        _validEntry = YES;
    }
    
    if ([[PFUser currentUser] objectForKey:@"appartmentNumber"]){
        _appartmentNumberTextField.text = [[PFUser currentUser] objectForKey:@"appartmentNumber"];
    }
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
}

-(void) dismissKeyboard{
    [self.view endEditing:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_searchResults){
        return [_searchResults count];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"locationCell" forIndexPath:indexPath];
    
    NSAttributedString* address = [[_searchResults objectAtIndex:indexPath.row] attributedFullText];
    
    UIFont *regularFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    UIFont *boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
    
    NSMutableAttributedString* bolded = [address mutableCopy];
    [bolded enumerateAttribute:kGMSAutocompleteMatchAttribute
                       inRange:NSMakeRange(0, bolded.length)
                       options:0
                    usingBlock:^(id value, NSRange range, BOOL *stop) {
                        UIFont *font = (value == nil) ? regularFont : boldFont;
                        [bolded addAttribute:NSFontAttributeName value:font range:range];
                    }];
    cell.textLabel.attributedText = bolded;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.textLabel.attributedText){
        NSAttributedString *attributedText = cell.textLabel.attributedText;
        _addressTextField.text = attributedText.string;
        
        NSString* placeID = [[self.searchResults objectAtIndex:indexPath.row] placeID];
        
        [_placesClient lookUpPlaceID:placeID callback:^(GMSPlace *place, NSError *error) {
            if (error != nil) {
                NSLog(@"Place Details error %@", [error localizedDescription]);
                return;
            }
            
            if (place != nil) {
                self.validEntry = YES;
                
                _thePlace = place;
                
                [self.view layoutIfNeeded];
                [UIView animateWithDuration:0.1 animations:^{
                    _tableViewHeight.constant = 0;
                    [self.view layoutIfNeeded];
                } completion:^(BOOL finished) {
                    [self.view layoutIfNeeded];
                }];
                
                NSLog(@"Place name %@", place.name);
                NSLog(@"Place address %@", place.formattedAddress);
                NSLog(@"Place placeID %@", place.placeID);
                NSLog(@"Place attributions %@", place.attributions);
            } else {
                NSLog(@"No place details for %@", placeID);
            }
        }];
        [self.view addGestureRecognizer:_tapGesture];
    }
}

-(void) startSearch: (NSString*)searchString{
    MKCoordinateRegion newRegion;
    
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    

    MKLocalSearchCompletionHandler handler  = ^(MKLocalSearchResponse *response, NSError *error){
        if (error){
            NSLog(@"ERROR MAP ADDRESS");
        }else{
            self.places = [response.mapItems mutableCopy];
            
            if (self.places.count > 0){
                [self.tableView reloadData];
            }
        }
    };
    
    if (self.localsearch) {
        self.localsearch = nil;
    }
    
    _localsearch = [[MKLocalSearch alloc] initWithRequest:request];
    [_localsearch startWithCompletionHandler:handler];
}

-(void) placeAutocomplete: (NSString*) searchQuery{
    [_placesClient autocompleteQuery:searchQuery bounds:nil filter:nil callback:^(NSArray * _Nullable results, NSError * _Nullable error) {
        if (error){
            NSLog(@"Autocomplete error \(error)");
        }
        
        _searchResults = [results mutableCopy];
        if (self.tableViewHeight.constant == 0){
            [self.view layoutIfNeeded];
            [UIView animateWithDuration:0.1 animations:^{
                _tableViewHeight.constant = 175;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                [self.view layoutIfNeeded];
            }];
            [self.view removeGestureRecognizer: self.tapGesture];
        }
        [self.tableView reloadData];
    }];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _addressTextField){
        if (_addressTextField.text.length > 0 && [string  isEqual: @" "]){
            [self placeAutocomplete: _addressTextField.text];
        }else if (_addressTextField.text.length > 0 && [string  isEqual: @""]){
            if (self.tableViewHeight.constant == 175){
                [self.view layoutIfNeeded];
                [UIView animateWithDuration:0.1 animations:^{
                    _tableViewHeight.constant = 0;
                    [self.view layoutIfNeeded];
                } completion:^(BOOL finished) {
                    [self.view layoutIfNeeded];
                }];
                [self.view addGestureRecognizer: _tapGesture];
                _validEntry = NO;
            }
        }
    }
    return YES;
}

- (IBAction)onSave:(UIButton *)sender {
    if (!_validEntry){
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Error"
                                           subtitle:@"Invalid Address!"
                                              image:nil
                                               type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:^{}
                                         atPosition:TSMessageNotificationPositionNavBarOverlay
                               canBeDismissedByUser:YES];
    }else{
        NSString *zipCode = @"";
        NSArray* dic = [_thePlace valueForKey:@"addressComponents"];
        NSLog(@"Diction CODE: %@", dic);
        for (int i=0;i<[dic count];i++) {
            if ([[[dic objectAtIndex:i] valueForKey:@"type"] isEqualToString:@"postal_code"]) {
                zipCode = [[dic objectAtIndex:i] valueForKey:@"name"];
                NSLog(@"ZipCode: %@",[[dic objectAtIndex:i] valueForKey:@"name"]);
            }
        }
        NSLog(@"ZIP CODE: %@", zipCode);
        
        [ProgressHUD show:nil];
        PFGeoPoint *theLocation = [PFGeoPoint geoPointWithLatitude:_thePlace.coordinate.latitude longitude:_thePlace.coordinate.longitude];
        PFUser *user = [PFUser currentUser];
        [user setObject:zipCode forKey:@"zipCode"];
        [user setObject:_thePlace.formattedAddress forKey:@"address"];
        [user setObject:_appartmentNumberTextField.text forKey:@"appartmentNumber"];
        [user setObject:theLocation forKey:@"userLocation"];
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (error) {
                [ProgressHUD dismiss];
                [TSMessage showNotificationInViewController:self.navigationController
                                                      title:@"Eror"
                                                   subtitle:@"There was an issue saving your address information"
                                                      image:nil
                                                       type:TSMessageNotificationTypeSuccess
                                                   duration:TSMessageNotificationDurationAutomatic
                                                   callback:nil
                                                buttonTitle:nil
                                             buttonCallback:^{}
                                                 atPosition:TSMessageNotificationPositionNavBarOverlay
                                       canBeDismissedByUser:YES];
                
                
            }
            else {
                
                [self checkIfParticipatingArea];
                
            }
        }];
    }
}

-(void)checkIfParticipatingArea {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Zipcodes"];
    [query whereKey:@"zipcode" equalTo:[[PFUser currentUser] objectForKey:@"zipCode"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object == nil) {
            NSLog(@"Not in that area");
            [ProgressHUD dismiss];
            [self popBack];
            
            [[PFUser currentUser] setObject:@"NO" forKey:@"canOrder"];
            [[PFUser currentUser] saveInBackground];
        }
        else {
            
            [ProgressHUD dismiss];
            [self.tableView reloadData];
            [[PFUser currentUser] setObject:@"YES" forKey:@"canOrder"];
            [[PFUser currentUser] saveInBackground];
            [self dismissViewControllerAnimated:YES completion:^{
                [parent addressMessage];
            }];
            
            
        }
    }];
}

- (void)popBack {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"We are sorry but Stockd isn't serving your area yet. We'll notify you as soon as we are!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
    alert.tag = 55;
    alert.delegate = self;
}


- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [parent addressMessage];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
