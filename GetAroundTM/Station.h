//
//  Station.h
//  TraficTM
//
//  Created by Alvin Stanescu on 11/8/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface Station : NSObject <MKAnnotation>
{
    int lineId;
    NSString *lineName;
    int stationId;
    NSString *name;
    NSString *longName;
    NSString *shortName;
    NSString *junctionName;
    CLLocation *location;
}

- (id)initWithLineId:(int)myLineId lineName:(NSString *)myLineName stationId:(int)myStationId name:(NSString *)myName longName:(NSString *)myLongName shortName:(NSString *)myShortName junctionName:(NSString *)myJunctionName latitude:(double)myLatitude longitude:(double)myLongitude;
- (int)lineId;
- (int)stationId;

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

@property (nonatomic, retain) NSString *lineName;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *longName;
@property (nonatomic, retain) NSString *shortName;
@property (nonatomic, retain) NSString *junctionName;
@property (nonatomic, retain) CLLocation *location;

@end
