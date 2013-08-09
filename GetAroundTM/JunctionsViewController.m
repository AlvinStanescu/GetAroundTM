//
//  StationsViewController.m
//  GetAroundTM
//
//  Created by Alvin Stanescu on 21.09.2012.
//
//

#import "JunctionsViewController.h"
#import "JunctionDetailViewController.h"
#import "Constants.h"
#import "Station.h"
#import "StationCollection.h"

@interface JunctionsViewController ()

@end

@implementation JunctionsViewController

@synthesize mySearchBar;
@synthesize detailViewController = _detailViewController, filteredListContent, savedSearchTerm, searchWasActive;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Stations",nil);
        self.searchWasActive = NO;
        
        UIBarButtonItem *getLocation = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Find me",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(getMyLocation:)];
        [[self navigationItem] setRightBarButtonItem:getLocation];
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // create a filtered list that will contain products for the search results table
    self.filteredListContent = [NSMutableArray arrayWithCapacity:[[[Constants defaultConstants] junctions] count]];
    [[self mySearchBar] setDelegate:self];
#ifdef PURPLE_COLOR_UI
    [[self mySearchBar] setTintColor:[[Constants defaultConstants] objectColor]];
#endif
    
    if ([self savedSearchTerm])
    {
        [[self mySearchBar] setText:[self savedSearchTerm]];
        self.savedSearchTerm = nil;
    }
    
    [self.tableView reloadData];
    self.tableView.scrollEnabled = YES;
}

- (void)viewDidUnload
{
    self.filteredListContent = nil;
    [self setMySearchBar:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.detailViewController = nil;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.detailViewController = nil;
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (searchWasActive)
    {
        return 1;
    }
    else {
        return (26 + EMPTY_SPACE);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    /*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
    if (searchWasActive)
    {
        return  [self.filteredListContent count];
    }
    else
    {
        if (section > (EMPTY_SPACE - 1))
        {
            return totalStations[section-EMPTY_SPACE];
        }
        else {
            return 0;
        }
    }
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StationCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        //     [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    
    NSString *junctionName;
    StationCollection *myJunction;
    
    NSInteger realRow = 0;
    
    for (NSInteger i = 0; i < ([indexPath section]-EMPTY_SPACE); i++)
    {
        realRow += totalStations[i];
    }
    
    realRow += [indexPath row];
    
    if (searchWasActive)
    {
        junctionName = [[self.filteredListContent objectAtIndex:[indexPath row]] name];
        myJunction = [self.filteredListContent objectAtIndex:[indexPath row]];
    }
    else
    {
        junctionName = [[[[Constants defaultConstants] junctions] objectAtIndex:realRow] name];
        myJunction = [[[Constants defaultConstants] junctions] objectAtIndex:realRow];
    }
    [[cell textLabel] setText:junctionName];
    [[cell detailTextLabel] setText:[myJunction description]];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger realRow = 0;
    
    for (NSInteger i = 0; i < ([indexPath section]-EMPTY_SPACE); i++)
    {
        realRow += totalStations[i];
    }
    
    realRow += [indexPath row];
    
    StationCollection *myJunction;
    if (searchWasActive)
    {
        myJunction = [self.filteredListContent objectAtIndex:[indexPath row]];
    }
    else
    {
        myJunction = [[[Constants defaultConstants] junctions] objectAtIndex:realRow];
    }
    
    self.detailViewController = [[JunctionDetailViewController alloc] initWithNibName:@"JunctionDetailViewController" bundle:nil junction:myJunction];
    [self.navigationController pushViewController:self.detailViewController animated:YES];
    
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *returnString = @"";
    if (searchWasActive)
    {
        returnString = NSLocalizedString(@"Search Results", nil);
    }
    else {
        if (section > (EMPTY_SPACE-1)){
            if (totalStations[section - EMPTY_SPACE] > 0 ) {
                const unichar sectionHeader = 0x41+section - EMPTY_SPACE;
                NSString *cString = [NSString stringWithCharacters:&sectionHeader length:1];
                returnString = cString;
            }
            
        }
    }
    return returnString;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    if(searchWasActive)
        return nil;
    else
    {
        for (int i=0; i< EMPTY_SPACE; i++){
            [tempArray addObject:@""];
        }
        for (int i='A'; i <= 'V';i++)
        {
            unichar sectionHeader = i;
            NSString *cString = [NSString stringWithCharacters:&sectionHeader length:1];
            [tempArray addObject:cString];
        }
        
        return tempArray;
    }
}


#pragma mark - Location Tracking

- (void)getMyLocation:(id)sender
{
    [[[self navigationItem] rightBarButtonItem] setStyle:UIBarButtonItemStyleDone];
    [locationManager startUpdatingLocation];
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:5
                                             target:self
                                           selector:@selector(finishedUpdatingLocation:)
                                           userInfo:nil
                                            repeats:NO];
    
    self.detailViewController = nil;
    
}

- (void)finishedUpdatingLocation:(NSTimer*)timer
{
    double smallestDistance = 9999.0;
    NSUInteger junctionIndex = 0;
    
    [locationManager stopUpdatingLocation];
    [[[self navigationItem] rightBarButtonItem] setStyle:UIBarButtonItemStyleBordered];
    
    NSUInteger idx = 0;
    for (StationCollection *aJunction in [[Constants defaultConstants] junctions]) {
        for (NSNumber *aStationIndex in aJunction.stations) {
            Station *aStation = [[[Constants defaultConstants] stations] objectAtIndex:[aStationIndex unsignedIntegerValue]];
            double latitudeDistance = [[aStation location] coordinate].latitude - currentLocation.coordinate.latitude;
            latitudeDistance = fabs(latitudeDistance);//(latitudeDistance < 0)?(-1)*latitudeDistance:latitudeDistance;
            double longitudeDistance = [[aStation location] coordinate].longitude - currentLocation.coordinate.longitude;
            longitudeDistance = fabs(longitudeDistance);//(longitudeDistance < 0)?(-1)*longitudeDistance:longitudeDistance;
            double totalDistance = latitudeDistance + longitudeDistance;
            if (totalDistance < smallestDistance) {
                smallestDistance = totalDistance;
                junctionIndex = idx;
            }
            
            
        }
        idx++;
    }
    if (smallestDistance < 1.0) {
        if (!self.detailViewController) {
            self.detailViewController = [[JunctionDetailViewController alloc] initWithNibName:@"JunctionDetailViewController" bundle:nil junction:[[[Constants defaultConstants] junctions] objectAtIndex:junctionIndex]];
            [self.navigationController pushViewController:self.detailViewController animated:YES];
        }
    }
    else
    {
        UIAlertView *tooFarAwayAlert = [[UIAlertView alloc] initWithTitle:@"Too far" message:@"You are too far from Timisoara to be close to any station." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [tooFarAwayAlert show];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    currentLocation = newLocation;
}

- (CLLocation *)getLastLocation
{
    return currentLocation;
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[self.filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    if (searchText) {
        for (StationCollection *junction in [[Constants defaultConstants] junctions])
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
            BOOL result = [predicate evaluateWithObject:junction.name];
            
            if (result)
            {
                [self.filteredListContent addObject:junction];
            }
            
        }
        [self setSearchWasActive:YES];
        [self setSavedSearchTerm:searchText];
    }
    else
    {
        [self setSearchWasActive:NO];
        [self setSavedSearchTerm:nil];
    }
    
    [[self tableView] reloadData];
}

#pragma mark -
#pragma mark UISearchBar Delegate Methods

- (void)finishSearchWithString:(NSString *)searchString {
    
    // Conduct the search. In this case, simply report the search term used.
    [self filterContentForSearchText:searchString];
    [mySearchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    if ([[aSearchBar text] isEqualToString:@""]) {
        searchWasActive = NO;
        savedSearchTerm = nil;
        [[self tableView] reloadData];
    }
    else [self filterContentForSearchText:[aSearchBar text]];
    mySearchBar.showsCancelButton = NO;
    [mySearchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    mySearchBar.showsCancelButton = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    // When the search string changes, filter the recents list accordingly.
    if ([searchText isEqualToString:@""]) {
        searchWasActive = NO;
        savedSearchTerm = nil;
        [[self tableView] reloadData];
    }
    else {
        [self filterContentForSearchText:searchText];
    }
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    
    // When the search button is tapped, add the search term to recents and conduct the search.
    [self finishSearchWithString:[aSearchBar text]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self setSearchWasActive:NO];
    [self setSavedSearchTerm:nil];
    mySearchBar.showsCancelButton = NO;
    [mySearchBar setText:nil];
    [mySearchBar resignFirstResponder];
    [[self tableView] reloadData];
}


@end
