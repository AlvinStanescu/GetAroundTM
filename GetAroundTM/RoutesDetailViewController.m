//
//  RoutesDetailViewController.m
//  TraficTM
//
//  Created by Alvin Stanescu on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RoutesDetailViewController.h"
#import "StationCollection.h"
#import "Station.h"
#import "Constants.h"
#import "ArrivalTime.h"

@interface RoutesDetailViewController ()
- (void)refreshData:(id)sender;
@end

@implementation RoutesDetailViewController

@synthesize errorLabel;
@synthesize currentJunction;
@synthesize tableView;
@synthesize activityIndicator;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] addSubview:activityIndicator];
    [[self view] addSubview:errorLabel];
    [[self activityIndicator] setHidesWhenStopped:YES];
    [[self activityIndicator] startAnimating];
    ShowNetworkActivityIndicator();
}

- (void)viewDidUnload
{
    [self setActivityIndicator:nil];
    [self setErrorLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getRouteDetails:0];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshData:)];
    [[self navigationItem] setRightBarButtonItem:refreshButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    if (!finishedLoading)
    {
        [connection cancel];
        currentRouteIndex = 0;
        HideNetworkActivityIndicator();
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil junction:(StationCollection *)myJunction
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = [myJunction name];
        currentJunction = myJunction;
        finishedLoading = NO;
        currentRouteIndex = 0;
        htmlData = [[NSMutableData alloc] init];
        arrivalTimes = [[NSMutableArray alloc] init];
        tableView = (UITableView*)[self view];        
        favorited = [self checkIfFavorited];
    }
    return self;
}

#pragma mark -
#pragma mark Route Functions

- (BOOL)checkIfFavorited
{
    for (NSString* aName in [[Constants defaultConstants] favoriteRoutes])
    {
        NSComparisonResult comparison = [[currentJunction name] compare:aName];
        if (!comparison)
            return YES;
    }
    return NO;
}

- (void)refreshData:(id)sender
{
    finishedLoading = NO;
    currentRouteIndex = 0;
    htmlData = [[NSMutableData alloc] init];
    arrivalTimes = [[NSMutableArray alloc] init];
    [[self activityIndicator] startAnimating];
    ShowNetworkActivityIndicator();
    [self getRouteDetails:0];
}

- (void)getRouteDetails:(int)routeIndex
{
    Station *theStation = [[currentJunction stations] objectAtIndex:routeIndex];
    NSString *lineId = [[NSNumber numberWithInt:[theStation lineId]] stringValue];
    NSString *stationId = [[NSNumber numberWithInt:[theStation stationId]] stringValue];
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://www.ratt.ro/txt/afis_msg.php?id_traseu="];
    //append with route Id
    [urlString appendString:lineId];
    [urlString appendString:@"&id_statie="];
    [urlString appendString:stationId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:YES];
    ShowNetworkActivityIndicator();
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [htmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (currentRouteIndex == ([[currentJunction stations] count] - 1)) {
        ArrivalTime *arrivalTime = [[ArrivalTime alloc] init];
        [arrivalTime setArrivalData:htmlData];
        [arrivalTimes addObject:arrivalTime];
        finishedLoading = YES;
        [[self activityIndicator] stopAnimating];
        HideNetworkActivityIndicator();
        [[self tableView] reloadData];
    }
    else {
        ArrivalTime *arrivalTime = [[ArrivalTime alloc] init];
        [arrivalTime setArrivalData:htmlData];
        [arrivalTimes addObject:arrivalTime];
        [self getRouteDetails:++currentRouteIndex];
        htmlData = [[NSMutableData alloc] init];
        [[self tableView] reloadData];
    }
    
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"There was an error while getting the data. Check your internet connection.\n");
#endif
    UIAlertView *problem = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Retrieval Error",nil) message:NSLocalizedString(@"There was an error while retrieving the data. Check your internet connection.",nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [conn cancel];
    [activityIndicator stopAnimating];
    HideNetworkActivityIndicator();
    [problem show];
}

#pragma mark -
#pragma mark Table View Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if (favorited)
    {
        return [[currentJunction stations] count];
    }
    else {
        return [[currentJunction stations] count] + 1;
    }

}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // if this route is not favorited, increase the real index path by 1 for routes to make space
    // for the favorite cell
    NSInteger row = [indexPath row];
    if (!favorited) row--;

    if (([indexPath row] > 0) || (favorited))
    {
        static NSString *CellIdentifier = @"RouteCell";
        UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                          reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        Station *thisStation = [[currentJunction stations] objectAtIndex:row];
        [[cell textLabel] setText:[thisStation shortName]];

        if (arrivalTimes != nil)
        {
            if ([arrivalTimes count] > row)
            {
                NSString* arrivalTime = [[NSString alloc] initWithString:[[arrivalTimes objectAtIndex:row] firstArrival]];
                [[cell detailTextLabel] setText:arrivalTime];
            }
            else [[cell detailTextLabel] setText:@"?"];
        }           
        else [[cell detailTextLabel] setText:@"?"];
    
        [[cell detailTextLabel] setTextColor:[UIColor purpleColor]];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"FavCell";
        if (!favCell) {
            favCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [[favCell textLabel] setText:NSLocalizedString(@"Add to favorites",nil)];
            UIImage *favImg = [UIImage imageNamed:@"favorites.png"];
            [[favCell imageView] setImage:favImg];
        }
        return favCell;
    }

}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0) {
        NSString *theJunctionName = [[NSString alloc] initWithString:[currentJunction name]];
        if (!favorited) {
            // Add to favorites
            [[[Constants defaultConstants] favoriteRoutes] addObject:theJunctionName];
            favorited = YES;
            UITableViewCell *thisCell = [[self tableView] cellForRowAtIndexPath:indexPath];
            [[thisCell textLabel] setTextColor:[UIColor grayColor]];
            [[thisCell textLabel] setText:NSLocalizedString(@"Added",nil)];
            [thisCell setUserInteractionEnabled:NO];
            [thisCell setSelected:NO animated:YES];
        }
    }
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
        Station *thisStation = [[currentJunction stations] objectAtIndex:(NSUInteger)section];
        NSMutableString *name = [[NSMutableString alloc] initWithString:[thisStation lineName]];
        [name appendString:@" - "];
        [name appendString:[thisStation longName]];
        return name;    
}
*/


@end
