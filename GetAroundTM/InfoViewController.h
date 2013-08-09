//
//  InfoViewController.h
//  GetAroundTM
//
//  Created by Alvin Stanescu on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@class InAppPurchaseViewController;
@interface InfoViewController : UIViewController <NSURLConnectionDataDelegate, UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    NSMutableData *receivedData;
    NSDictionary *dbData;
    IBOutlet UILabel *databaseLabel;
    IBOutlet UIProgressView *progressBar;
    NSString *oldDatabaseLabelText;
    float byteLength;
    float downloadedLength;
    InAppPurchaseViewController *inAppPurchaseViewController;
}
- (IBAction)checkNewDatabase:(id)sender;
- (IBAction)showCredits:(id)sender;
- (IBAction)showStationMap:(id)sender;
- (void)timeout:(id)arg;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSURLConnection *connection;
@property (retain) MBProgressHUD *hud;
@end
