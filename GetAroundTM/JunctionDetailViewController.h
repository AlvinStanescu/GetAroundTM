//
//  DetailViewController.h
//  TraficTM
//
//  Created by Alvin Stanescu on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
@class StationCollection;
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface JunctionDetailViewController : UITableViewController <NSURLConnectionDataDelegate>
{
    MBProgressHUD *hud;
    StationCollection *currentJunction;
    NSURLConnection *connection;
    NSMutableData *htmlData;
    NSMutableArray *arrivalTimes;
    UITableViewCell *favCell;

    int currentRouteIndex;
    BOOL finishedLoading;
    BOOL favorited;
}

@property (nonatomic, retain) StationCollection *currentJunction;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil junction:(StationCollection *)myJunction;
- (void)getRouteDetails:(int)routeIndex;
- (BOOL)checkIfFavorited;

@end
