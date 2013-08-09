//
//  PersistentAdTabBarController.m
//  TraficTM
//
//  Created by Alvin Stanescu on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PersistentAdTabBarController.h"
#import "Constants.h"



@implementation PersistentAdTabBarController




@synthesize junctionsNavigationController = _junctionsNavigationController;
@synthesize routesNavigationController = _routesNavigationController;
@synthesize infoNavigationController = _infoNavigationController;
@synthesize mapsViewController = _mapsViewController;
@synthesize favoritesViewController = _favoritesViewController;



#define TABBAR_HEIGHT   49.0
//#define AD_REFRESH_PERIOD 30.0

- (id)init
{
    self = [super init];
    if (self)
    {
        // Favorites View Controller init
        FavoritesViewController *favoritesViewController = [[FavoritesViewController alloc] initWithStyle:UITableViewStyleGrouped];
        self.favoritesViewController = [[UINavigationController alloc] initWithRootViewController:favoritesViewController];
        // Junctions View Controller init
        JunctionsViewController *junctionsViewController = [[JunctionsViewController alloc] initWithNibName:@"JunctionsViewController" bundle:nil];
        self.junctionsNavigationController = [[UINavigationController alloc] initWithRootViewController:junctionsViewController];

        // Routes View Controller init
     //   CGRect noNavBarframe = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
        RoutesViewController *routesViewController = [[RoutesViewController alloc] initWithFrame:self.view.frame];
        self.routesNavigationController = [[UINavigationController alloc] initWithRootViewController:routesViewController];
   //     [self.routesNavigationController.navigationBar setHidden:YES];
        [self.routesNavigationController setDelegate:routesViewController];
        
        // Info View Controller init
        InfoViewController *infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
        self.infoNavigationController = [[UINavigationController alloc] initWithRootViewController:infoViewController];
        
        // Maps View Controller init
        self.mapsViewController = [[MapsViewController alloc] initWithNibName:@"MapsViewController" bundle:nil];
        [self.mapsViewController setJunctionNavigationController:self.junctionsNavigationController];
        [self.mapsViewController setRouteNavigationController:self.routesNavigationController];
#if defined(PURPLE_COLOR_UI)
        if ([self.tabBar respondsToSelector:@selector(setSelectedImageTintColor:)])
            [self.tabBar setSelectedImageTintColor:[[Constants defaultConstants] objectColor]];
        if ([self.favoritesViewController.navigationBar respondsToSelector:@selector(setTintColor:)])
            [self.favoritesViewController.navigationBar setTintColor:[[Constants defaultConstants] objectColor]];
        if ([self.routesNavigationController.navigationBar respondsToSelector:@selector(setTintColor:)])
            [self.routesNavigationController.navigationBar setTintColor:[[Constants defaultConstants] objectColor]];
        if ([self.junctionsNavigationController.navigationBar respondsToSelector:@selector(setTintColor:)])
            [self.junctionsNavigationController.navigationBar setTintColor:[[Constants defaultConstants] objectColor]];
        if ([self.infoNavigationController.navigationBar respondsToSelector:@selector(setTintColor:)])
            [self.infoNavigationController.navigationBar setTintColor:[[Constants defaultConstants] objectColor]];

#endif
        UITabBarItem *favoritesTbItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:0];
        UITabBarItem *junctionTbItem = [[UITabBarItem alloc] initWithTitle:junctionsViewController.title image:[UIImage imageNamed:@"station.png"] tag:1];
        UITabBarItem *routesTbItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Routes", nil) image:[UIImage imageNamed:@"route.png"] tag:2];
        UITabBarItem *infoTbItem = [[UITabBarItem alloc] initWithTitle:@"Extra" image:[UIImage imageNamed:@"info.png"] tag:3];
        UITabBarItem *mapTbItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Maps", nil) image:[UIImage imageNamed:@"get.png"] tag:4];
        
        self.favoritesViewController.tabBarItem = favoritesTbItem;
        self.junctionsNavigationController.tabBarItem = junctionTbItem;
        self.routesNavigationController.tabBarItem = routesTbItem;
        self.infoNavigationController.tabBarItem = infoTbItem;
        self.mapsViewController.tabBarItem = mapTbItem;
        
        NSArray *viewControllers = [NSArray arrayWithObjects:self.favoritesViewController,self.junctionsNavigationController,self.routesNavigationController, self.mapsViewController, self.infoNavigationController, nil];
        [self setViewControllers:viewControllers];     
    }
    return self;
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
    

}

- (void)viewDidUnload {
	[super viewDidUnload];
  
    self.favoritesViewController = nil;
    self.junctionsNavigationController = nil;
    self.routesNavigationController = nil;
    self.mapsViewController = nil;
    self.infoNavigationController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:YES];
/*    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"com.thedamn3d.GetAroundTM.adremoval"])
    {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        {
            adBannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0, 0.0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
        }
        else
        {
            adBannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(20.0, 0.0, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height)];
        }

        adBannerView.adUnitID = MY_PUBLISHER_ID;
        adBannerView.rootViewController = self;
        [adBannerView setDelegate:self];
        [self requestNewAd:nil];
    }
*/
 }

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

}

- (void)requestNewAd:(NSTimer*)timer
{
//    if (adBannerView) {
//        _request = [GADRequest request];
//        _request.testDevices = [NSArray arrayWithObjects:
//                               GAD_SIMULATOR_ID,
//                               nil];
//        
//        CLLocation *lastLocation = nil;
//        
//        if ([[[self.junctionsNavigationController viewControllers] objectAtIndex:0] respondsToSelector:@selector(getLastLocation)])
//        {
//            lastLocation = [(JunctionsViewController*)[[self.junctionsNavigationController viewControllers] objectAtIndex:0] getLastLocation];
//        }
//        if (lastLocation) {
//            [_request setLocationWithLatitude:lastLocation.coordinate.latitude
//                                   longitude:lastLocation.coordinate.longitude
//                                    accuracy:lastLocation.horizontalAccuracy];
//        }
//        else
//        {
//            // default to Timisoara, Romania
//            [_request setLocationWithLatitude:45.749444 longitude:21.227222 accuracy:10000.0];
//        }
//        [adBannerView loadRequest:_request];
//    }
}


- (void)displayAd
{
//    adLoaded = YES;
//    for (UIView *view in self.view.subviews) {
//        if (![view isKindOfClass:[UITabBar class]]) {
//            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
//            {
//                [view setFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, view.frame.size.height - GAD_SIZE_320x50.height)];
//            }
//            else
//            {
//                [view setFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, view.frame.size.height - GAD_SIZE_728x90.height)];
//            }
//            [view setNeedsDisplay];
//        }
//    }
//
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
//    {
//        adBannerView.frame = CGRectMake(0.0, self.view.frame.size.height - TABBAR_HEIGHT - GAD_SIZE_320x50.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height);
//    }
//    else
//    {
//        adBannerView.frame = CGRectMake(20.0, self.view.frame.size.height - TABBAR_HEIGHT - GAD_SIZE_728x90.height, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height);
//    }
//
//    [[self view] addSubview:adBannerView];
//#ifdef DEBUG
//    NSLog(@"Received ad.");    
//#endif
//    if (reloadAdTimer != nil) [reloadAdTimer invalidate];
//    reloadAdTimer = [NSTimer scheduledTimerWithTimeInterval:AD_REFRESH_PERIOD 
//                                     target:self 
//                                    selector:@selector(refreshAd:) 
//                                   userInfo:nil 
//                                    repeats:NO];
}





@end
