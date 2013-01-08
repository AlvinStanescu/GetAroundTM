//
//  PersistentAdTabBarController.h
//  TraficTM
//
//  Created by Alvin Stanescu on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JunctionsViewController.h"
#import "RoutesViewController.h"
#import "InfoViewController.h"
#import "MapsViewController.h"
#import "FavoritesViewController.h"

#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"



@interface PersistentAdTabBarController : UITabBarController <UITabBarDelegate, GADBannerViewDelegate>
{
    NSTimer *reloadAdTimer;
    GADBannerView *adBannerView;
}

@property (nonatomic) CGRect adBannerFrame;
@property (retain, nonatomic) GADRequest *request;

@property (retain, nonatomic) UINavigationController *junctionsNavigationController;
@property (retain, nonatomic) UINavigationController *routesNavigationController;
@property (retain, nonatomic) UINavigationController *infoNavigationController;
@property (retain, nonatomic) UINavigationController *favoritesViewController;
@property (retain, nonatomic) MapsViewController *mapsViewController;



- (void)requestNewAd:(NSTimer*)timer;
- (void)refreshAd:(NSTimer*)timer;
- (void)removeAdFromDisplay;
- (void)displayAd;
- (void)stopTimer;

@end