//
//  StationParser.h
//  TraficTM
//
//  Created by Alvin Stanescu on 11/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class StationCollection;
@interface StationParser : NSObject

+ (void)loadStationsFromPlist;
+ (NSString*)subtitleForJunction:(StationCollection*)junction;
@end
