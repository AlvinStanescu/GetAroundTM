//
//  StationParser.m
//  TraficTM
//
//  Created by Alvin Stanescu on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StationParser.h"
#import "Station.h"
#import "Constants.h"
#import "StationCollection.h"

@implementation StationParser

+ (void)loadStationsFromPlist
{
    NSString *path = [[Constants defaultConstants] getStationsDataFileName];
    NSDictionary *stDict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *containedStations = [stDict objectForKey:@"ItemsList"];
    
    // station generation
    void (^enumBlock)(id, NSUInteger, BOOL*) = ^(id obj, NSUInteger idx, BOOL *stop){
        NSDictionary *aStation = (NSDictionary *)obj;

        NSNumber *lineId = [aStation valueForKey:@"LineID"];
        NSNumber *stationId = [aStation valueForKey:@"StationID"];
        NSNumber *latitude = [aStation valueForKey:@"Latitude"];
        NSNumber *longitude = [aStation valueForKey:@"Longitude"];
        NSString *jName = [aStation valueForKey:@"JunctionStationName"]==nil?@"":[aStation valueForKey:@"JunctionStationName"];
        NSString *shortName = [aStation valueForKey:@"ShortStationName"];
        
        Station *oneStation = [[Station alloc] initWithLineId:[lineId intValue] lineName:[aStation valueForKey:@"LineName"] stationId:[stationId intValue] name:[aStation valueForKey:@"RawStationName"] longName:[aStation valueForKey:@"FriendlyStationName"] shortName:shortName junctionName:jName latitude:[latitude doubleValue] longitude:[longitude doubleValue]];
        [[[Constants defaultConstants] stations] addObject:oneStation];
        

    };
    [containedStations enumerateObjectsUsingBlock:enumBlock];
    
    // line generation
    void (^generateRoutes)(id, NSUInteger, BOOL*) = ^(id obj, NSUInteger idx, BOOL *stop){       
        
        static int previousLineId = 9999;
        static StationCollection *aRoute;
        
        if ([(Station*)obj lineId] != previousLineId) {
            //new route - add previous route to the route array
            if (idx) {
                [[[Constants defaultConstants] routes] addObject:aRoute];
            }
            aRoute = [[StationCollection alloc] init];
            [aRoute setName:[obj lineName]];
            [[aRoute stations] addObject:obj];
        }
        else {
            //same junction
            [[aRoute stations] addObject:obj];
        }
        previousLineId = [obj lineId];
        //add the junction immediately if it is the last station to be processed
        if (idx == ([[[Constants defaultConstants] stations] count] - 1 )) {
            [[[Constants defaultConstants] routes] addObject:aRoute];   
        }
    };   
    [[[Constants defaultConstants] stations] enumerateObjectsUsingBlock:generateRoutes];
    
    // junction generation
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"shortName"
                                                                   ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [[[Constants defaultConstants] stations] sortUsingDescriptors:sortDescriptors];

    void (^generateJunctions)(id, NSUInteger, BOOL*) = ^(id obj, NSUInteger idx, BOOL *stop){
        static NSString *previousName = @"";
        static StationCollection *aJunction;
        
        if ([(Station*)obj shortName] != previousName && [[(Station*)obj shortName] length]) {
            // new junction - add previous junction to the junction array
            if (idx) {
                // add its description before adding it to the junctions array
                [aJunction setDescription:[StationParser subtitleForJunction:aJunction]];
                [[[Constants defaultConstants] junctions] addObject:aJunction];
                
                const char *shortName_char = [previousName cStringUsingEncoding:NSUTF8StringEncoding];
                char letter = shortName_char[0];
                totalStations[letter-'A']++;
            }
            // initialize the new junction
            aJunction = [[StationCollection alloc] init];
            [aJunction setCoordinate:[[(Station*)obj location] coordinate]];
            [aJunction setName:[obj shortName]];
            [[aJunction stations] addObject:[NSNumber numberWithUnsignedInteger:idx]];
        }
#ifdef DEBUG
        else if (![[(Station*)obj shortName] length]) {
            //not a junction - add previous junction to the junction array (this should never happen - as we use the shortName instead, and every entry has a shortName, but just in case)
            if (idx) {
                // add its description before adding it to the junctions array
                [aJunction setDescription:[StationParser subtitleForJunction:aJunction]];
                                
                [[[Constants defaultConstants] junctions] addObject:aJunction];
            }
            aJunction = [[StationCollection alloc] init];
            [aJunction setCoordinate:[[(Station*)obj location] coordinate]];
            [aJunction setName:[obj name]];
            [[aJunction stations] addObject:[NSNumber numberWithUnsignedInteger:idx]];
        }
#endif
        else {
            //same junction
            [[aJunction stations] addObject:[NSNumber numberWithUnsignedInteger:idx]];
        }
        previousName = [[obj shortName] copy];
        //add the junction immediately if it is the last station to be processed
        if (idx == [[[Constants defaultConstants] stations] count]) {
            // add its description and coordinates before adding it to the junctions array
            [aJunction setDescription:[StationParser subtitleForJunction:aJunction]];
            
            [[[Constants defaultConstants] junctions] addObject:aJunction];   
            // increments the totalStations number
            const char *shortName_char = [previousName cStringUsingEncoding:NSUTF8StringEncoding];
            char letter = shortName_char[0];
            totalStations[letter-'A']++;
        }
    };
    [[[Constants defaultConstants] stations] enumerateObjectsUsingBlock:generateJunctions]; 

}

+ (NSString*)subtitleForJunction:(StationCollection*)junction
{
    NSMutableString* subtitle = [[NSMutableString alloc] init];
    NSMutableArray* lines = [[NSMutableArray alloc] init];
    
    for (NSNumber *idx in [junction stations])
    {
        BOOL contained = NO;
        Station *theStation = [[[Constants defaultConstants] stations] objectAtIndex:[idx unsignedIntValue]];
        
        for (NSString *line in lines)
        {
            if ([line isEqualToString:[theStation lineName]]) contained = YES;
        }
        if (!contained) [lines addObject:[[theStation lineName] copy]];
    }
    
    for (NSString *line in lines)
    {
        [subtitle appendFormat:@"%@, ",line];
    }
    NSRange rng;
    rng.length = 2;
    rng.location = [subtitle length] - 2;
    
    [subtitle replaceCharactersInRange:rng withString:@""];
    return subtitle;
}

@end
