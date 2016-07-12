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
@property (weak, nonatomic) IBOutlet UITextField *apartmentNumberTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) GMSPlacesClient* placesClient;
@property (strong, nonatomic) MKLocalSearch* localsearch;
@property (strong, nonatomic) CLLocationManager* locationManager;
@property (strong, nonatomic) NSMutableArray* places;
@property (strong, nonatomic) NSMutableArray* searchResults;
@property (strong, nonatomic) UITapGestureRecognizer* tapGesture;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (nonatomic, strong) NSString *oldUserAddress;


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
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    swipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipe];
    
    //self.title = @"Address Info";
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _validEntry = NO;
    
    _addressTextField.delegate = self;
    _apartmentNumberTextField.delegate = self;
    
    _placesClient = [[GMSPlacesClient alloc] init];
    
    [self.view layoutIfNeeded];
    _tableViewHeight.constant = 0;
    [self.view layoutIfNeeded];
    
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.image = [UIImage imageNamed:@"initialBkg@2x"];
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    if ([[PFUser currentUser] objectForKey:@"address"]){
        _addressTextField.text = [[PFUser currentUser] objectForKey:@"address"];
        _validEntry = YES;
        
    }
    
    if ([[PFUser currentUser] objectForKey:@"apartmentNumber"]){
        _apartmentNumberTextField.text = [[PFUser currentUser] objectForKey:@"apartmentNumber"];
    }
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    
    self.saveButton.layer.cornerRadius = 3.5;
    self.saveButton.backgroundColor = [UIColor colorWithRed:0.333 green:0.812 blue:0.478 alpha:1];
    //self.saveButton.titleLabel.font = [UIFont fontWithName:@"BELLABOO" size:18];
    
    
    NSString *oldUserStreet = [[PFUser currentUser] objectForKey:@"streetName"];
    NSString *oldUserCity = [[PFUser currentUser] objectForKey:@"userCity"];
    NSString *oldUserState = [[PFUser currentUser] objectForKey:@"userState"];
    NSString *oldUserZip = [[PFUser currentUser] objectForKey:@"zipCode"];
    NSString *oldUserApartmentNumber = [[PFUser currentUser] objectForKey:@"aptDormNumber"];
    self.oldUserAddress = [NSString stringWithFormat:@"%@, %@, %@, %@",oldUserStreet, oldUserCity, oldUserState, oldUserZip];
    
    NSLog(@"Old user address: %@", self.oldUserAddress);
    
    if (oldUserStreet != nil) {
     
        _addressTextField.text = self.oldUserAddress;
        _apartmentNumberTextField.text = oldUserApartmentNumber;
        
        [_placesClient autocompleteQuery:self.oldUserAddress bounds:nil filter:nil callback:^(NSArray * _Nullable results, NSError * _Nullable error) {
            if (error){
                NSLog(@"Autocomplete error \(error)");
            }
            
            if (results.count == 0) {
                
            } else {
            
            
            _searchResults = [results mutableCopy];
            NSLog(@"search results %@", self.searchResults);
            NSString* placeID = [[self.searchResults objectAtIndex:0] placeID];
            
            [_placesClient lookUpPlaceID:placeID callback:^(GMSPlace *place, NSError *error) {
                if (error != nil) {
                    NSLog(@"Place Details error %@", [error localizedDescription]);
                    return;
                }
                
                if (place != nil) {
                    self.validEntry = YES;
                    
                    _thePlace = place;
                    NSLog(@"Place name %@", place.name);
                    NSLog(@"Place address %@", place.formattedAddress);
                    NSLog(@"Place placeID %@", place.placeID);
                    NSLog(@"Place attributions %@", place.attributions);

                }
            }];
            }
        }];
    }
    
    self.tableView.layer.cornerRadius = 4;
}

-(void)viewWillAppear:(BOOL)animated {
    
    if (_comingFromCart) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Address Info" message:@"Before making a purchase on Stockd, please add your address information. If you previously added your address, please update it to continue with your order. We promise this will be the last time we ask." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        alert.delegate = self;
        alert.tag = 101;
        [alert show];
        
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 101) {
        //dismiss alert and show next alert if old user address exists
        if (buttonIndex == 0) {
            //show alert
            NSLog(@"dismissed alert");
            
            NSString *oldUserStreet = [[PFUser currentUser] objectForKey:@"streetName"];
            
            if (oldUserStreet != nil) {
             
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Does this look okay?" message:self.oldUserAddress delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Update", nil];
                
                alert.delegate = self;
                alert.tag = 102;
                [alert show];
            }
        }
    }
    
    if (alertView.tag == 102) {
        if (buttonIndex == 0) {
            //Cancel
        } else if (buttonIndex == 1) {
            //User Tapped Update
            UIButton *sender;
            
            [self onSave:sender];
        }
    }
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if ([_addressTextField isFirstResponder]) {
        [_addressTextField resignFirstResponder];
    } else if ([_apartmentNumberTextField isFirstResponder]) {
        
        [_apartmentNumberTextField resignFirstResponder];
    }

    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == _addressTextField){
        if (_addressTextField.text.length > 0){
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
    
    [_addressTextField resignFirstResponder];
    [_apartmentNumberTextField resignFirstResponder];
    //NSLog(@"Place: %@", _thePlace.formattedAddress);
    
    NSString *userAddress = [[PFUser currentUser] objectForKey:@"address"];
    NSString *userAptNumber = [[PFUser currentUser] objectForKey:@"apartmentNumber"];
    NSString *userZip = [[PFUser currentUser] objectForKey:@"zipCode"];
    
    if ([userAddress isEqualToString:_addressTextField.text]) {
        
//        if ([userAptNumber isEqualToString:_apartmentNumberTextField.text]) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already Saved" message:@"Your address has already been saved, you're good to go!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            
//            [alert show];
//            alert.tag = 55;
//            alert.delegate = self;
//            return;
//        } else {
//            
//        }
    }
    
//    if (_thePlace.formattedAddress == nil) {
//        NSLog(@"gotcha");
//        [TSMessage showNotificationInViewController:self.navigationController
//                                              title:@"Error"
//                                           subtitle:@"Invalid Address"
//                                              image:nil
//                                               type:TSMessageNotificationTypeError
//                                           duration:TSMessageNotificationDurationAutomatic
//                                           callback:nil
//                                        buttonTitle:nil
//                                     buttonCallback:^{}
//                                         atPosition:TSMessageNotificationPositionNavBarOverlay
//                               canBeDismissedByUser:YES];
//
//
//        return;
//    }

    if ([_addressTextField.text length] <1) {
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Error"
                                           subtitle:@"Invalid Address"
                                              image:nil
                                               type:TSMessageNotificationTypeError
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:^{}
                                         atPosition:TSMessageNotificationPositionNavBarOverlay
                               canBeDismissedByUser:YES];
        
        return;
    }
    
    if (!_validEntry){
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Error"
                                           subtitle:@"Invalid Address"
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
        
        [ProgressHUD show:nil];
        PFGeoPoint *theLocation = [PFGeoPoint geoPointWithLatitude:_thePlace.coordinate.latitude longitude:_thePlace.coordinate.longitude];
        
        if (_thePlace){
            NSArray* dic = [_thePlace valueForKey:@"addressComponents"];
            NSLog(@"Diction CODE: %@", dic);
            for (int i=0;i<[dic count];i++) {
                if ([[[dic objectAtIndex:i] valueForKey:@"type"] isEqualToString:@"postal_code"]) {
                    zipCode = [[dic objectAtIndex:i] valueForKey:@"name"];
                    NSLog(@"ZipCode: %@",[[dic objectAtIndex:i] valueForKey:@"name"]);
                }
            }
        }else if ([[PFUser currentUser] objectForKey:@"address"] != nil){
            zipCode = [[PFUser currentUser] objectForKey:@"zipCode"];
            theLocation = [[PFUser currentUser] objectForKey:@"userLocation"];
        }
        
        if (!_thePlace) {
            
            if (_comingFromCart) {
             
                [ProgressHUD dismiss];
                _addressTextField.text = @"";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"We couldn't find that address. Please re-enter your address and tap save. " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                
                [alert show];
                
                return;
            }
        }
        
        
        PFUser *user = [PFUser currentUser];
        [user setObject:zipCode forKey:@"zipCode"];
        [user setObject:_addressTextField.text forKey:@"address"];
        [user setObject:_apartmentNumberTextField.text forKey:@"apartmentNumber"];
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
                
                PFUser *user = [PFUser currentUser];
                [user removeObjectForKey:@"aptDormNumber"];
                [user removeObjectForKey:@"streetName"];
                [user removeObjectForKey:@"userState"];
                [user removeObjectForKey:@"userCity"];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error) {
                        [ProgressHUD showError:@"Error"];
                    } else {
                    
                        [self checkIfParticipatingArea];
                    }
                }];
                
            }
        }];
    }
}

-(void)checkIfParticipatingArea {
    
    NSString *userZip = [[PFUser currentUser] objectForKey:@"zipCode"];
    
    NSLog(@"user zip : %@", userZip);
    
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
                if (_comingFromCart) {
                    
                } else {
                    [parent addressMessage];
                }
            }];
        }
    }];
}

- (void)popBack {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"We are sorry but Stockd isn't serving your area yet. We'll notify you as soon as we are!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
    alert.tag = 55;
    alert.delegate = self;
    
    [self onClose:self];
}


- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        //[parent addressMessage];
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
