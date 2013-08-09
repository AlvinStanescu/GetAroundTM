//
//  StationsViewController.h
//  GetAroundTM
//
//  Created by Alvin Stanescu on 21.09.2012.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class JunctionDetailViewController;
@class StationCollection;

#define EMPTY_SPACE 3

@interface JunctionsViewController : UITableViewController <UISearchBarDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    NSMutableArray	*filteredListContent;	// The content filtered as a result of a search.
    
    // The saved state of the search UI if a memory warning removed the view.
    NSString		*savedSearchTerm;
    NSInteger		savedScopeButtonIndex;
    BOOL			searchWasActive;
    CLLocation      *currentLocation;
    NSTimer         *timer;
}

@property (retain, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (retain, nonatomic) JunctionDetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableArray *filteredListContent;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic) BOOL searchWasActive;

- (void)finishSearchWithString:(NSString *)searchString;
- (void)getMyLocation:(id)sender;
- (void)finishedUpdatingLocation:(NSTimer*)timer;
- (CLLocation *)getLastLocation;

@end
