//
//  Constants.h
//  TraficTM
//
//  Created by Alvin Stanescu on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

@class AppDelegate;

extern int totalStations[('Z'-'A'+1)];

@interface Constants : NSObject
{
    UIColor *objectColor;
    // main object array - contains all the data of all the stations
    NSMutableArray *stations;
    // contains the indexes in the stations array of all stations corresponding to each junction
    NSMutableArray *junctions;
    // contains the index in the stations array of all stations corresponding to each route
    NSMutableArray *routes; 
    
    // favorite junctions
    NSMutableArray *favoriteStations;
    // favorite routes
    NSMutableArray *favoriteRoutes;
}

@property (nonatomic, readonly) NSMutableArray *stations;
@property (nonatomic, readonly) NSMutableArray *routes;
@property (nonatomic, retain) NSMutableArray *favoriteStations;
@property (nonatomic, retain) NSMutableArray *junctions;
@property (nonatomic, readonly) UIColor *objectColor;
@property (nonatomic, retain) NSDate *databaseDate;
@property (nonatomic, assign) AppDelegate *appDelegate;

+ (Constants *)defaultConstants;
+ (void)reinit;
- (void)loadFavorites;
- (void)saveFavorites;
- (NSMutableArray *)favoriteStations;
- (NSMutableArray *)favoriteRoutes;
- (NSString *)getStationsDataFileName;
- (void)setStationsDataFileName:(NSString *)fileName dateCreated:(NSDate *)date;

@end
