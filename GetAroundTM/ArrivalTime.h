//
//  ArrivalTime.h
//  TraficTM
//
//  Created by Alvin Stanescu on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArrivalTime : NSObject <NSXMLParserDelegate>
{
    NSString *firstArrival;
    NSString *secondArrival;
}

- (void)setArrivalData:(NSData *)arrivalData;
- (NSString *)firstArrival;
- (NSString *)secondArrival;
@end
