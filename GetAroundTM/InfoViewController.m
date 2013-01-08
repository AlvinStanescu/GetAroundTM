//
//  InfoViewController.m
//  GetAroundTM
//
//  Created by Alvin Stanescu on 1/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"
#import "StationMapViewController.h"
#import "Constants.h"
#import "StationParser.h"
#import "AppDelegate.h"
#import "PersistentAdTabBarController.h"
#import "GetAroundTMIAPHelper.h"
#import "Reachability.h"
#import "InAppPurchaseViewController.h"
#import "IAPHelper.h"

@implementation InfoViewController
@synthesize tableView;
@synthesize connection = _connection;
@synthesize hud = _hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Extra";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];

        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    databaseLabel = nil;
    progressBar = nil;
    self.hud = nil;
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDate *creationDate = [[Constants defaultConstants] databaseDate];
    NSMutableString *newVersion = [[NSMutableString alloc] initWithString:NSLocalizedString(@"Database built on ", nil)];
    NSString* datePart = [NSDateFormatter localizedStringFromDate: creationDate 
                                                        dateStyle: NSDateFormatterShortStyle 
                                                        timeStyle: NSDateFormatterNoStyle];
    NSString* timePart = [NSDateFormatter localizedStringFromDate: creationDate 
                                                        dateStyle: NSDateFormatterNoStyle 
                                                        timeStyle: NSDateFormatterShortStyle];
    [newVersion appendString:datePart];
    [newVersion appendString:NSLocalizedString(@" at ", nil)];
    [newVersion appendString:timePart];
    [newVersion appendString:NSLocalizedString(@" used.", nil)];
    [databaseLabel setText:newVersion];
    [super viewWillAppear:animated];
}

#pragma mark - In App Purchase

- (IBAction)inAppPurchase:(id)sender {
    
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
#ifdef DEBUG
        NSLog(@"No Internet connection");
#endif
    } else {
            [[GetAroundTMIAPHelper sharedHelper] requestProducts];
            self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            _hud.labelText = NSLocalizedString(@"Loading... ", nil);
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];
    }
}

- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    self.hud = nil;
    
}

- (void)productsLoaded:(NSNotification *)notification {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    inAppPurchaseViewController = [[InAppPurchaseViewController alloc] initWithStyle:UITableViewStylePlain masterViewController:self];
    [[self navigationController] pushViewController:inAppPurchaseViewController animated:YES];
}

- (void)timeout:(id)arg {
    
    _hud.labelText = NSLocalizedString(@"Timeout!", nil);
    _hud.detailsLabelText = NSLocalizedString(@"Please try again later.", nil);
  //  _hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.jpg"]] autorelease];
//	_hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
    
}

#pragma mark - OTA database download

- (IBAction)checkNewDatabase:(id)sender {
    ShowNetworkActivityIndicator();
    dbData = [[NSDictionary alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://80.97.161.97/getaroundtm/AppSettings.plist"]];
    HideNetworkActivityIndicator();
    if (dbData == nil)
    {
        UIAlertView *problem = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Retrieval Error",nil) message:NSLocalizedString(@"Database server is down.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [problem show];
    }
    else
    {
        // database exists, check if newer version
        NSDate *dbDate = [dbData objectForKey:@"DatabaseFileDate"];
        NSComparisonResult comparison = [dbDate compare:[[Constants defaultConstants] databaseDate]];
        // if newer version exists ask the user if to download it
        if (comparison == NSOrderedDescending)
        {
            NSMutableString *newVersion = [[NSMutableString alloc] initWithString:NSLocalizedString(@"New version found, built on ", nil)];
            NSString* datePart = [NSDateFormatter localizedStringFromDate: dbDate 
                                                                dateStyle: NSDateFormatterShortStyle 
                                                                timeStyle: NSDateFormatterNoStyle];
            NSString* timePart = [NSDateFormatter localizedStringFromDate: dbDate 
                                                                dateStyle: NSDateFormatterNoStyle 
                                                                timeStyle: NSDateFormatterShortStyle];
            [newVersion appendString:datePart];
            [newVersion appendString:NSLocalizedString(@" at ", nil)];
            [newVersion appendString:timePart];
            [newVersion appendString:NSLocalizedString(@". Download?", nil)];
            
            UIAlertView *newVersionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"New version",nil) message:newVersion delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:NSLocalizedString(@"Yes", nil),nil];
            [newVersionAlertView show];          
        }
        else
        {
            UIAlertView *latestVersionAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No new version",nil) message:NSLocalizedString(@"You already have the latest database version.", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [latestVersionAlertView show];  
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0)
    {
        NSString *dbFileName = [dbData objectForKey:@"DatabaseFile"];
        NSMutableString *urlString = [[NSMutableString alloc] initWithString:@"http://80.97.161.97/getaroundtm/"];
        [urlString appendString:dbFileName];
        
        NSURLRequest *lastVersion = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:60.0];
        self.connection = [[NSURLConnection alloc] initWithRequest:lastVersion delegate:self];
        [self.connection start];
        receivedData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
    [progressBar setHidden:FALSE];
    progressBar.progress = 0.0;
//    [progressBar setNeedsDisplay];
 //   [progressBar setProgress:0.0 animated:YES];
    ShowNetworkActivityIndicator();
    oldDatabaseLabelText = databaseLabel.text;
    byteLength = (float)([response expectedContentLength] / (long long)1024);
    NSMutableString *download = [[NSMutableString alloc] initWithString:@"0.0 kB"];
    [download appendString:[NSString stringWithFormat:@" out of %2.f kB downloaded.",byteLength]];
    [databaseLabel setText:download];
    downloadedLength = 0.0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
    float dataLength = ([data length] / 1024);
    downloadedLength +=dataLength;
    progressBar.progress = (downloadedLength / byteLength);
    NSMutableString *download = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%2.f",downloadedLength]];
    [download appendString:[NSString stringWithFormat:@" out of %2.f kB downloaded.",byteLength]];
    [databaseLabel setText:download];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    progressBar.progress = 1.0;
    [databaseLabel setText:@"Database downloaded. Reloading data..."];
    HideNetworkActivityIndicator();
    [receivedData writeToFile:pathInDocumentDirectory([dbData objectForKey:@"DatabaseFile"]) atomically:YES];
    [[Constants defaultConstants] setStationsDataFileName:[dbData objectForKey:@"DatabaseFile"] dateCreated:[dbData objectForKey:@"DatabaseFileDate"]];
    
    AppDelegate *myAppDelegate = [[Constants defaultConstants] appDelegate];
    [Constants reinit];
    [StationParser loadStationsFromPlist];
    [[Constants defaultConstants] loadFavorites];
    
    myAppDelegate.persistentAdTabBarController = nil;
    myAppDelegate.persistentAdTabBarController = [[PersistentAdTabBarController alloc] init];
    myAppDelegate.window.rootViewController = myAppDelegate.persistentAdTabBarController;
    
    UIAlertView *status = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Update finished",nil) message:NSLocalizedString(@"The database was successfully updated.",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [status show];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"There was an error while getting the data. Check your internet connection.\n");
#endif
    UIAlertView *problem = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Retrieval Error",nil) message:NSLocalizedString(@"There was an error while retrieving the data. Check your internet connection.",nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [connection cancel];
    HideNetworkActivityIndicator();
    [progressBar setHidden:TRUE];
    [databaseLabel setText:oldDatabaseLabelText];
    [problem show];
}

    
#pragma mark - Credits

- (IBAction)showCredits:(id)sender {
    NSString *credits = NSLocalizedString(@"GetAroundTM v2.0\n\nCode - Alvin Stanescu\nData - Kriszti Cseh, Chagall, Florin B.\n\nIcons created by the Noun Project and users Reinaldo Weber, Bernoit Champy and Sven Hofmann from the Noun Project used.\n\nThis application is not made by RATT and comes with no warranty whatsoever. Arrival data is received via the Internet from RATT's own servers.\n\nAll rights reserved.\n© 2011-2012", nil);

    UIAlertView *creditsView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Credits", nil) message:credits delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [creditsView show];
}

#pragma mark - Station map

- (IBAction)showStationMap:(id)sender
{
    StationMapViewController *stMapViewController = [[StationMapViewController alloc] initWithNibName:@"StationMapViewController" bundle:nil];
    [[self navigationController] pushViewController:stMapViewController animated:YES];
}
@end
