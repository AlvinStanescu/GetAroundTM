//
//  Junction.m
//  TraficTM
//
//  Created by Alvin Stanescu on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "StationCollection.h"

@implementation StationCollection
@synthesize description = _description;
@synthesize name = _name;
@synthesize coordinate = _coordinate;
@synthesize stations = _stations;

- (id)init
{
    self = [super init];
    if (self) {
        _stations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString*)title
{
    return _name;
}

- (NSString*)subtitle
{
    return _description;
}
@end
