//
//  RoutesDetailViewController.h
//  TraficTM
//
//  Created by Alvin Stanescu on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@class StationCollection;
#import <UIKit/UIKit.h>

@interface RoutesDetailViewController : UITableViewController <NSURLConnectionDataDelegate>
{
    StationCollection *currentJunction;
    NSURLConnection *connection;
    NSMutableData *htmlData;
    NSMutableArray *arrivalTimes;
    UITableViewCell *favCell;
    
    int currentRouteIndex;
    BOOL finishedLoading;
    BOOL favorited;
}

@property (retain, nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic, retain) StationCollection *currentJunction;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil junction:(StationCollection *)myJunction;
- (void)getRouteDetails:(int)routeIndex;
- (BOOL)checkIfFavorited;

@end
