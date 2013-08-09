//
//  MapsViewController.h
//  GetAroundTM
//
//  Created by Alvin Stanescu on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class StationCollection;
@interface MapsViewController : UIViewController <UISearchBarDelegate, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL pickerViewActivated;
    BOOL displayAllStations;
    StationCollection *route;
}
@property (retain, nonatomic) IBOutlet MKMapView* mapView;
@property (retain, nonatomic) IBOutlet UISearchBar* searchBar;
@property (retain, nonatomic) IBOutlet UINavigationBar* navBar;
@property (retain, nonatomic) UINavigationController *junctionNavigationController;
@property (retain, nonatomic) UINavigationController *routeNavigationController;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *routeBarButtonItem;
@property (unsafe_unretained, nonatomic) IBOutlet UIBarButtonItem *findMeBarButtonItem;

- (IBAction)changeRoute:(id)sender;
- (IBAction)trackLocation:(id)sender;
- (void)loadStations;

@end
