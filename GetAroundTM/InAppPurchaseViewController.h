//
//  InAppPurchaseViewController.h
//  GetAroundTM
//
//  Created by Alvin Stanescu on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class InfoViewController;
@interface InAppPurchaseViewController : UITableViewController
{
    InfoViewController *infoViewController;
}
- (IBAction)buyButtonTapped:(id)sender;
- (id)initWithStyle:(UITableViewStyle)style masterViewController:(InfoViewController *)infoVc;
- (void)productPurchased:(NSNotification *)notification;
- (void)productPurchaseFailed:(NSNotification *)notification;

@end
