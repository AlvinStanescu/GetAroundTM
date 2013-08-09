//
//  FavoritesViewController.m
//  GetAroundTM
//
//  Created by Alvin Stanescu on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoritesViewController.h"
#import "Constants.h"
#import "JunctionDetailViewController.h"
#import "RoutesDetailViewController.h"
#import "StationCollection.h"

#define kStationsSection 0
#define kRoutesSection 1

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController

@synthesize detailViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"Favorites", nil);
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.detailViewController = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == kStationsSection)
    {
        return [[[Constants defaultConstants] favoriteStations] count];
    }
    else {
        return [[[Constants defaultConstants] favoriteRoutes] count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* placeholderText = NSLocalizedString(@"\n\nNo stations or routes added.\n\nYou can add your favorites stations and routes here for easy access by tapping the \"Add to Favorites\" button for your most frequently used station or route.",nil);
    
    if (section == kStationsSection)
    {
        if ([[[Constants defaultConstants] favoriteStations] count] > 0)
        {
            return NSLocalizedString(@"Stations", nil);
        }
        else {
            if ([[[Constants defaultConstants] favoriteRoutes] count] == 0)
                return placeholderText;
            else
                return @"";
        }
    }
    else {
        if ([[[Constants defaultConstants] favoriteRoutes] count] > 0)
        {
            return NSLocalizedString(@"Routes", nil);
        }
        else {
            return @"";
        }
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoritesCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if ([indexPath section] == kStationsSection)
    {
        [[cell textLabel] setText:[[[Constants defaultConstants] favoriteStations] objectAtIndex:[indexPath row]]];
    }
    else {
        [[cell textLabel] setText:[[[Constants defaultConstants] favoriteRoutes] objectAtIndex:[indexPath row]]];
    }
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if ([indexPath section] == kStationsSection)
        {
            [[[Constants defaultConstants] favoriteStations] removeObjectAtIndex:[indexPath row]];
        }
        else {
            [[[Constants defaultConstants] favoriteRoutes] removeObjectAtIndex:[indexPath row]];
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];

    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if ([fromIndexPath section] == [toIndexPath section])
    {
        if ([fromIndexPath section] == kStationsSection)
        {
            NSString *stationAtIndexPath = [NSString stringWithString:[[[Constants defaultConstants] favoriteStations] objectAtIndex:[fromIndexPath row]]];
            [[[Constants defaultConstants] favoriteStations] removeObjectAtIndex:[fromIndexPath row]];
            [[[Constants defaultConstants] favoriteStations] insertObject:stationAtIndexPath atIndex:[toIndexPath row]];
        }
        else {
            NSString *routeAtIndexPath = [NSString stringWithString:[[[Constants defaultConstants] favoriteRoutes] objectAtIndex:[fromIndexPath row]]];
            [[[Constants defaultConstants] favoriteRoutes] removeObjectAtIndex:[fromIndexPath row]];
            [[[Constants defaultConstants] favoriteRoutes] insertObject:routeAtIndexPath atIndex:[toIndexPath row]];
        }
    }
}


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    if ([indexPath section] == kStationsSection) {
        NSString *junctionName = [[[Constants defaultConstants] favoriteStations] objectAtIndex:[indexPath row]];
        StationCollection *selectedJunction;
        for (StationCollection* aJunction in [[Constants defaultConstants] junctions]) {
            NSComparisonResult comparison = [[aJunction name] compare:junctionName];
            if (!comparison) {
                selectedJunction = aJunction;
                break;
            }
        }
        self.detailViewController = nil;
        self.detailViewController = [[JunctionDetailViewController alloc] initWithNibName:@"JunctionDetailViewController" bundle:nil junction:selectedJunction];
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
    else {
            NSString *routeName = [[[Constants defaultConstants] favoriteRoutes] objectAtIndex:[indexPath row]];
            StationCollection *selectedRoute;
            for (StationCollection* aRoute in [[Constants defaultConstants] routes]) {
                NSComparisonResult comparison = [[aRoute name] compare:routeName];
                if (!comparison) {
                    selectedRoute = aRoute;
                    break;
                }
            }
            self.detailViewController = nil;
            self.detailViewController = [[RoutesDetailViewController alloc] initWithNibName:@"RoutesDetailViewController" bundle:nil junction:selectedRoute];
            [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
}

@end
