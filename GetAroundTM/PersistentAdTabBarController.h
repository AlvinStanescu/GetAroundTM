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





@interface PersistentAdTabBarController : UITabBarController <UITabBarDelegate>


@property (nonatomic) CGRect adBannerFrame;


@property (retain, nonatomic) UINavigationController *junctionsNavigationController;
@property (retain, nonatomic) UINavigationController *routesNavigationController;
@property (retain, nonatomic) UINavigationController *infoNavigationController;
@property (retain, nonatomic) UINavigationController *favoritesViewController;
@property (retain, nonatomic) MapsViewController *mapsViewController;



@end