//
//  Junction.h
//  TraficTM
//
//  Created by Alvin Stanescu on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface StationCollection : NSObject <MKAnnotation>
{
}
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *stations;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

@end
