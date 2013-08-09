//
//  MapsViewController.m
//  GetAroundTM
//
//  Created by Alvin Stanescu on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapsViewController.h"
#import "Constants.h"
#import "Station.h"
#import "StationCollection.h"
#import "JunctionDetailViewController.h"
#import "RoutesDetailViewController.h"
#import "PersistentAdTabBarController.h"

@interface MapsViewController ()

@end

@implementation MapsViewController

@synthesize mapView = _mapView;
@synthesize searchBar = _searchBar;
@synthesize navBar = _navBar;
@synthesize routeNavigationController = _routeNavigationController;
@synthesize junctionNavigationController = _junctionNavigationController;
@synthesize pickerView = _pickerView;
@synthesize routeBarButtonItem = _routeBarButtonItem;
@synthesize findMeBarButtonItem = _findMeBarButtonItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"Route - All",nil);
        pickerViewActivated = NO;
        displayAllStations = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navBar setTintColor:[[Constants defaultConstants] objectColor]];
    [self.searchBar setTintColor:[[Constants defaultConstants] objectColor]];
    self.searchBar.showsScopeBar = NO;
    [self loadStations];
}

- (void)viewDidUnload
{
    [self setPickerView:nil];
    [self setPickerView:nil];
    [self setRouteBarButtonItem:nil];
    [self setFindMeBarButtonItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)loadStations
{
    CLLocationCoordinate2D center;
    
    if (displayAllStations)
    {
        for (StationCollection* aJunction in [[Constants defaultConstants] junctions]) 
        {
            [self.mapView addAnnotation:aJunction];
        }
        
        // center on the city's central area
        center = CLLocationCoordinate2DMake(45.755869,21.228805);
    }
    else
    {
        for (Station *aStation in [route stations]) {
            [self.mapView addAnnotation:aStation];
        }
        Station *centerStation = [[route stations] objectAtIndex:([[route stations] count]/4)];
        center = [[centerStation location] coordinate];
    }
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(center, 1500.0, 1500.0) animated:YES];

}
#pragma mark -
#pragma mark Map View Methods

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView* pinView;
    if ([annotation isKindOfClass:[Station class]] || [annotation isKindOfClass:[StationCollection class]])
    {      
        static NSString* stationAnnotationId = @"stationAnnotationId";

        pinView = (MKPinAnnotationView *)
        [theMapView dequeueReusableAnnotationViewWithIdentifier:stationAnnotationId];
        if (!pinView)
        {
            // if an existing pin view was not available, create one
            pinView = [[MKPinAnnotationView alloc]
                                                   initWithAnnotation:annotation reuseIdentifier:stationAnnotationId];
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            // add a detail disclosure button to the callout which will open a new view controller page
            //
            // note: you can assign a specific call out accessory view, or as MKMapViewDelegate you can implement:
            //  - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
            //
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self
                            action:nil
                  forControlEvents:UIControlEventTouchUpInside];
            pinView.rightCalloutAccessoryView = rightButton;
        }
        else
        {
            pinView.annotation = annotation;
        }

        if (displayAllStations)
        {
            if ([[annotation subtitle] length] > 15)
            {
                pinView.pinColor = MKPinAnnotationColorRed;
            }
            else {
                if ([[annotation subtitle] length] > 10)
                {
                    pinView.pinColor = MKPinAnnotationColorPurple;
                }
                else {
                    pinView.pinColor = MKPinAnnotationColorGreen;
                }
            }
        }
        else {
            pinView.pinColor = MKPinAnnotationColorRed;
        }
    }
    else {
        // user location track
        static NSString* userLocationId = @"userLocationId"; 
        pinView = (MKPinAnnotationView *)
        [theMapView dequeueReusableAnnotationViewWithIdentifier:userLocationId];
        [pinView setAnimatesDrop:NO];

    }
    
    return pinView;

}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSString *stationName = [(StationCollection*)[view annotation] name];
    
    if (displayAllStations)
    {
        StationCollection *selectedJunction;
        for (StationCollection* aJunction in [[Constants defaultConstants] junctions]) 
        {
            NSComparisonResult comparison = [[aJunction name] compare:stationName];
            if (!comparison) {
                selectedJunction = aJunction;
                break;
            }
        }
    
        JunctionDetailViewController *detailViewController = [[JunctionDetailViewController alloc] initWithNibName:@"JunctionDetailViewController" bundle:nil junction:selectedJunction];
        [self.junctionNavigationController popToRootViewControllerAnimated:NO];
        [self.junctionNavigationController pushViewController:detailViewController animated:NO];
        [(PersistentAdTabBarController*)self.parentViewController setSelectedIndex:1];
    }
    else {
        RoutesDetailViewController *routeDetailViewController = [[RoutesDetailViewController alloc] initWithNibName:@"RoutesDetailViewController" bundle:nil junction:route];
        [self.routeNavigationController popToRootViewControllerAnimated:NO];
        [self.routeNavigationController pushViewController:routeDetailViewController animated:NO];
        [(PersistentAdTabBarController*)self.parentViewController setSelectedIndex:2];
        

    }
}

#pragma mark -
#pragma mark PickerView Related Methods

- (IBAction)changeRoute:(id)sender {
    if (pickerViewActivated)
    {
        [self.routeBarButtonItem setStyle:UIBarButtonItemStyleBordered];
        [self.routeBarButtonItem setTitle:NSLocalizedString(@"Route", nil)];
        [self.pickerView setHidden:YES];
        NSMutableString *titleString = [NSMutableString stringWithString:NSLocalizedString(@"Route", nil)];
        NSString *stationName;
        
        if ([self.pickerView selectedRowInComponent:0])
        {
            route = [[[Constants defaultConstants] routes] objectAtIndex:([self.pickerView selectedRowInComponent:0]-1)];
            stationName = [route name];
            displayAllStations = NO;
        }
        else {
            displayAllStations = YES;
            stationName = NSLocalizedString(@"All", nil);
        }
        [titleString appendFormat:@" - %@",stationName];
        [[self.navBar.items objectAtIndex:0] setTitle:titleString];
        pickerViewActivated = NO;
        
        // logic for setting the stations
        [[self mapView] removeAnnotations:[[self mapView] annotations]];
        [self loadStations];
    }
    else 
    {
        [self.pickerView setHidden:NO];
        [self.routeBarButtonItem setStyle:UIBarButtonItemStyleDone];
        [self.routeBarButtonItem setTitle:NSLocalizedString(@"Set", nil)];
        pickerViewActivated = YES;
    }
}

- (IBAction)trackLocation:(id)sender {
    if ([self.mapView userTrackingMode] != MKUserTrackingModeNone)
    {
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
        [self.mapView setShowsUserLocation:NO];
        [self.findMeBarButtonItem setStyle:UIBarButtonItemStyleBordered];
        [self.findMeBarButtonItem setTitle:NSLocalizedString(@"Find me", nil)];

    }
    else
    {
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
        [self.findMeBarButtonItem setStyle:UIBarButtonItemStyleDone];
        [self.findMeBarButtonItem setTitle:NSLocalizedString(@"Stop", nil)];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0)
    {
        return NSLocalizedString(@"All", nil);
    }
    else {
        return ([[[[Constants defaultConstants] routes] objectAtIndex:(row - 1)] name]);
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

// Called by the picker view when it needs the number of components. (required)
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
// Called by the picker view when it needs the number of rows for a specified component. (required)
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return ([[[Constants defaultConstants] routes] count] + 1);
}

#pragma mark -
#pragma mark Search Bar Delegate Methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;

}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [[self searchBar] endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar 
{
    for (int i=0; i < [[self.mapView annotations] count];i++)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", [aSearchBar text]];
        BOOL result = [predicate evaluateWithObject:[[[self.mapView annotations] objectAtIndex:i] title]];
        
        if (result)
        {
            [self.mapView setCenterCoordinate:[[[self.mapView annotations] objectAtIndex:i] coordinate] animated:YES];
            [self.mapView selectAnnotation:[[self.mapView annotations] objectAtIndex:i] animated:YES];
            break;
        }
    }
    [aSearchBar resignFirstResponder];
}
@end
