
//  Constants.m
//  TraficTM
//
//  Created by Alvin Stanescu on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"
#import "Station.h"

static Constants *defaultConstants = nil;
int totalStations[('Z'-'A'+1)] = {0};

@interface Constants () 

+ (NSString *)archivePath;
@end

@implementation Constants

@synthesize stations, routes, favoriteStations, junctions, objectColor;
@synthesize databaseDate = _databaseDate;
@synthesize appDelegate = _appDelegate;
+ (NSString *)archivePath
{
    return pathInDocumentDirectory(@"fav.data");
}

+ (NSString *)archivePathForRoutes
{
    return pathInDocumentDirectory(@"fav_routes.data");
}

- (void)loadFavorites
{
    favoriteStations = [NSKeyedUnarchiver unarchiveObjectWithFile:[Constants archivePath]];    
    if (!favoriteStations) favoriteStations = [[NSMutableArray alloc] init];
    favoriteRoutes = [NSKeyedUnarchiver unarchiveObjectWithFile:[Constants archivePathForRoutes]];    
    if (!favoriteRoutes) favoriteRoutes = [[NSMutableArray alloc] init];
}

- (void)saveFavorites
{
    [NSKeyedArchiver archiveRootObject:favoriteStations toFile:[Constants archivePath]];
    [NSKeyedArchiver archiveRootObject:favoriteRoutes toFile:[Constants archivePathForRoutes]];
}

- (NSMutableArray*)favoriteStations
{
    return favoriteStations;
}

- (NSMutableArray*)favoriteRoutes
{
    return favoriteRoutes;
}

- (id)init
{
    self = [super init];
    if (!stations)
    {
        routes = [[NSMutableArray alloc] init];
        stations = [[NSMutableArray alloc] init];
        junctions = [[NSMutableArray alloc] init];
        objectColor = [UIColor colorWithRed:0.613 green:0.172 blue:0.8 alpha:1.0];
    }
    return self;
}

+ (Constants *)defaultConstants
{
    if (!defaultConstants)
        defaultConstants = [[Constants alloc] init];
    
    return defaultConstants;
}
+ (void)reinit
{
    defaultConstants = nil;
    defaultConstants = [[Constants alloc] init];
}

- (NSString *)getStationsDataFileName
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSDictionary *defaultSettings = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"AppSettings.plist"]];

    NSString *finalPath = pathInDocumentDirectory(@"AppSettings.plist");
    NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    
    if (!settingsDict)
    {
        // no file is present
        // use standard database for current version
        
        NSDictionary *defaultSettings = [NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"AppSettings.plist"]];
        self.databaseDate = [defaultSettings objectForKey:@"DatabaseFileDate"];
        
        return [path stringByAppendingPathComponent:@"StationsData.plist"];
    }
    else
    {
        // check if newer version
        NSDate *otaDbDate = [settingsDict objectForKey:@"DatabaseFileDate"]; 
        if ([otaDbDate compare:[defaultSettings objectForKey:@"DatabaseFileDate"]] == 1)
        {
            // a newer database exists
            self.databaseDate = [settingsDict objectForKey:@"DatabaseFileDate"];
            return pathInDocumentDirectory([settingsDict objectForKey:@"DatabaseFile"]);
        }
        else
        {
            // load the detault database for this app version
            self.databaseDate = [defaultSettings objectForKey:@"DatabaseFileDate"];
            
            return [path stringByAppendingPathComponent:@"StationsData.plist"];

        }
    }
}

- (void)setStationsDataFileName:(NSString *)fileName dateCreated:(NSDate *)date
{
    NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] init];
    [settingsDict setValue:fileName forKey:@"DatabaseFile"];
    [settingsDict setValue:date forKey:@"DatabaseFileDate"];
    [settingsDict writeToFile:pathInDocumentDirectory(@"AppSettings.plist") atomically:YES];
}
                
@end
