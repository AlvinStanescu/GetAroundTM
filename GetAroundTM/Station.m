//
//  Station.m
//  TraficTM
//
//  Created by Alvin Stanescu on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Station.h"
#import <CoreLocation/CoreLocation.h>

@implementation Station

@synthesize name, longName, shortName, junctionName, location, lineName;

- (id)initWithLineId:(int)myLineId lineName:(NSString *)myLineName stationId:(int)myStationId name:(NSString *)myName longName:(NSString *)myLongName shortName:(NSString *)myShortName junctionName:(NSString *)myJunctionName latitude:(double)myLatitude longitude:(double)myLongitude
{
    self = [super init];
    if (self) {
        lineId = myLineId;
        lineName = [myLineName copy];
        stationId = myStationId;
        name = [myName copy];
        longName = [myLongName copy];
        shortName = [myShortName copy];
        junctionName = [myJunctionName copy];
        location = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)myLatitude longitude:(CLLocationDegrees)myLongitude];
    }
    return self;
}

- (int)lineId
{
    return lineId;
}

- (int)stationId
{
    return stationId;
}

- (NSString*)title
{
    return shortName;
}

- (NSString*)subtitle
{
    return lineName;
}

- (CLLocationCoordinate2D)coordinate
{
    return location.coordinate;
}
@end
