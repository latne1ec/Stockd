//
//  HelpTableViewController.m
//  Stockd
//
//  Created by Evan Latner on 7/2/15.
//  Copyright (c) 2015 Stockd. All rights reserved.
//

#import "HelpTableViewController.h"
#import "TermsViewController.h"


@interface HelpTableViewController ()

@end

@implementation HelpTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.tableView.tableFooterView = [UIView new];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"initialBkg"]];
    [self.tableView setBackgroundView:imageView];
    
    
    //Nav Bar Back Button Color
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"initialBkg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.layer.masksToBounds = YES;
    self.tableView.clipsToBounds = YES;
    
    //Navigation Bar Title Properties
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor clearColor];
    shadow.shadowOffset = CGSizeMake(0, .0);
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName,
                                                          [UIFont fontWithName:@"BELLABOO-Regular" size:22], NSFontAttributeName, nil]];
    
    self.navigationController.navigationItem.hidesBackButton = YES;
    self.title = @"Help";
    
    [TSMessage setDefaultViewController:self];
    [TSMessage setDelegate:self];

}

-(void)viewWillAppear:(BOOL)animated {
    
    self.navigationItem.hidesBackButton = YES;
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    //[self.navigationController.navigationBar setHidden:YES];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu{
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) return _firstCell;
    if (indexPath.row == 1) return _thirdCell;
    if (indexPath.row == 2) return _fourthCell;
    
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0) {
        
        
//        TourViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Tour"];
//        destViewController.view.alpha = 0.0;
//        [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
//            
//            destViewController.view.alpha = 1.0;
//            [self.navigationController pushViewController:destViewController animated:NO];
//            
//        } completion:^(BOOL finished) {
//            
//        }];
        
        [CATransaction begin];
        TourViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Tour"];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        CATransition *transition = [CATransition animation];
        transition.removedOnCompletion = YES;
        [transition setType:kCATransitionFade];
        [self.navigationController.view.layer addAnimation:transition forKey:[NSString stringWithFormat:@"someAnimation_%f",(double)[[NSDate date] timeIntervalSince1970]]];
        //navigationController.navigationBar.hidden = YES;
        
        [self.navigationController pushViewController:destViewController animated:NO];
        [CATransaction commit];

    }

    if (indexPath.row == 1) {
        
        [self sendEmail];
    }
    
    if (indexPath.row == 2) {
        
        TermsViewController *destViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Terms"];
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:destViewController];
        UIBarButtonItem *newBackButton =
        [[UIBarButtonItem alloc] initWithTitle:@"Terms of Service"
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
        [[navigationController navigationItem] setBackBarButtonItem:newBackButton];
        [self.navigationController presentViewController:navigationController animated:YES completion:^{
        }];
        
    }
}

-(void)sendEmail {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] initWithNibName:nil bundle:nil];
        [composeViewController setMailComposeDelegate:self];
        [composeViewController setToRecipients:@[@"matt.mason@getstockd.co"]];
        [composeViewController setSubject:@"Contact Stockd"];
        
        [[composeViewController navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
        
        [[composeViewController navigationBar] setTintColor: [UIColor blackColor]];
        
        [self presentViewController:composeViewController animated:YES completion:^{
           
            }];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    if (error) {
        NSLog(@"Error");
    }
    
    else if (result == 2) {
        
        [TSMessage showNotificationInViewController:self.navigationController
                                              title:@"Success"
                                           subtitle:@"Message sent successfully"
                                              image:nil
                                               type:TSMessageNotificationTypeSuccess
                                           duration:TSMessageNotificationDurationAutomatic
                                           callback:nil
                                        buttonTitle:nil
                                     buttonCallback:^{}
                                         atPosition:TSMessageNotificationPositionNavBarOverlay
                               canBeDismissedByUser:YES];

    }
    
    NSLog(@"Result: %u", result);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
