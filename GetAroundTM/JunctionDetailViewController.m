//
//  DetailViewController.m
//  TraficTM
//
//  Created by Alvin Stanescu on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "JunctionDetailViewController.h"
#import "StationCollection.h"
#import "Station.h"
#import "Constants.h"
#import "ArrivalTime.h"

@interface JunctionDetailViewController ()
- (void)refreshData:(id)sender;
@end

@implementation JunctionDetailViewController

@synthesize currentJunction;

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:NSLocalizedString(@"Loading", nil)];
    hud.userInteractionEnabled = NO;
    self.tableView.scrollEnabled = NO;
    [hud setRemoveFromSuperViewOnHide:YES];
    ShowNetworkActivityIndicator();
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    hud = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    if (!finishedLoading)
    {
        [connection cancel];
        currentRouteIndex = 0;
        HideNetworkActivityIndicator();
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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
        [self getRouteDetails:0];
//        tableView = (UITableView*)[self view];
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshData:)];
        [[self navigationItem] setRightBarButtonItem:refreshButton];
        favorited = [self checkIfFavorited];
    }
    return self;
}

#pragma mark -
#pragma mark Station Functions

- (void)refreshData:(id)sender
{
    finishedLoading = NO;
    currentRouteIndex = 0;
    htmlData = [[NSMutableData alloc] init];
    arrivalTimes = [[NSMutableArray alloc] init];
    if (hud != nil) [MBProgressHUD hideHUDForView:self.view animated:YES];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud setLabelText:NSLocalizedString(@"Loading", nil)];
    ShowNetworkActivityIndicator();
    [self getRouteDetails:0];
}

- (void)getRouteDetails:(int)routeIndex
{
    NSNumber *vehicle = [[currentJunction stations] objectAtIndex:routeIndex];
    Station *theStation = [[[Constants defaultConstants] stations] objectAtIndex:[vehicle unsignedIntegerValue]];
    NSString *lineId = [[NSNumber numberWithInt:[theStation lineId]] stringValue];
    NSString *stationId = [[NSNumber numberWithInt:[theStation stationId]] stringValue];
    NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://www.ratt.ro/txt/afis_msg.php?id_traseu="];
    //append with route Id
    [urlString appendString:lineId];
    [urlString appendString:@"&id_statie="];
    [urlString appendString:stationId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    connection = [[NSURLConnection alloc] initWithRequest:req
                                                 delegate:self
                                         startImmediately:YES];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [htmlData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (currentRouteIndex == ([[currentJunction stations] count] - 1)) {
        ArrivalTime *arrivalTime = [[ArrivalTime alloc] init];
        [arrivalTime setArrivalData:htmlData];
        [arrivalTimes addObject:arrivalTime];
        finishedLoading = YES;
        self.tableView.scrollEnabled = YES;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        hud = nil;
        HideNetworkActivityIndicator();
        [[self tableView] reloadData];
    }
    else {
        ArrivalTime *arrivalTime = [[ArrivalTime alloc] init];
        [arrivalTime setArrivalData:htmlData];
        [arrivalTimes addObject:arrivalTime];
        [self getRouteDetails:++currentRouteIndex];
        htmlData = [[NSMutableData alloc] init];
    }
    
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    // tbd - label showing error
    #ifdef DEBUG
    NSLog(@"There was an error while getting the data. Check your internet connection.\n");
	#endif
    UIAlertView *problem = [[UIAlertView alloc] initWithTitle:@"Retrieval Error" message:@"There was an error while retrieving the data. Check your internet connection." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [conn cancel];
    self.tableView.scrollEnabled = YES;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    HideNetworkActivityIndicator();
    [problem show];
}

#pragma mark -
#pragma mark Table View Methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ([[currentJunction stations] count] + 1);
}
- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if (section > 0) return 2;
    else {
        if (favorited)
            return 0;
        else return 1;
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section])
    {
        static NSString *CellIdentifier = @"RouteCell";
        UITableViewCell *cell = [[self tableView] dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                          reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (!([indexPath row] % 2)) {
            [[cell textLabel] setText:NSLocalizedString(@"First Arrival",nil)];
        }
        else {
            [[cell textLabel] setText:NSLocalizedString(@"Second Arrival",nil)];
        }
        
        if (finishedLoading)
        {
            NSString *arrivalTime;
         //   NSLog(@"We are in section %d",[indexPath section]);
            if (!([indexPath row] % 2)) {
                arrivalTime = [[NSString alloc] initWithString:[[arrivalTimes objectAtIndex:([indexPath section] - 1)] firstArrival]];      
            }
            else {
                arrivalTime = [[NSString alloc] initWithString:[[arrivalTimes objectAtIndex:([indexPath section] - 1)] secondArrival]];
            }
            [[cell detailTextLabel] setText:arrivalTime];
        }
        else [[cell detailTextLabel] setText:@"?"];
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

- (BOOL)checkIfFavorited
{
    for (NSString* aName in [[Constants defaultConstants] favoriteStations])
    {
        NSComparisonResult comparison = [[currentJunction name] compare:aName];
        if (!comparison)
            return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        NSString *theJunctionName = [[NSString alloc] initWithString:[currentJunction name]];
        if (!favorited) {
            // Add to favorites
            [[[Constants defaultConstants] favoriteStations] addObject:theJunctionName];
            favorited = YES;
            UITableViewCell *thisCell = [[self tableView] cellForRowAtIndexPath:indexPath];
            [[thisCell textLabel] setTextColor:[UIColor grayColor]];
            [[thisCell textLabel] setText:NSLocalizedString(@"Added",nil)];
            [thisCell setUserInteractionEnabled:NO];
            [thisCell setSelected:NO animated:YES];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section > 0 ) {
        NSNumber *stationNo = [[currentJunction stations] objectAtIndex:(section-1)];
        Station *thisStation = [[[Constants defaultConstants] stations] objectAtIndex:[stationNo unsignedIntegerValue]];
        NSMutableString *name = [[NSMutableString alloc] initWithString:[thisStation lineName]];
        [name appendString:@" - "];
        [name appendString:[thisStation longName]];
        return name;    
    }
    else return @"";
}

@end
