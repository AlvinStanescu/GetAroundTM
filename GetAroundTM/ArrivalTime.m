//
//  ArrivalTime.m
//  TraficTM
//
//  Created by Alvin Stanescu on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ArrivalTime.h"
@interface ArrivalTime ()
- (BOOL)parseStationWithData:(NSString *)stationData;
@end
@implementation ArrivalTime

- (BOOL)parseStationWithData:(NSString *)stationData
{
 return NO;   
}

- (NSString *)firstArrival
{
    return firstArrival;
}

- (NSString *)secondArrival
{
    return secondArrival;
}

- (void)setArrivalData:(NSData *)arrivalData
{
    NSString *htmlCheck = [[NSString alloc] initWithData:arrivalData
                                                encoding:NSUTF8StringEncoding];
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"Sosire[12]:\\s(\\d|[*.:>])+"
                                                                           options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:htmlCheck
                                      options:0
                                        range:NSMakeRange(0, [htmlCheck length])];
    BOOL first = YES;
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = NSMakeRange(match.range.location + 9, match.range.length - 9);
        NSMutableString *arrival = [[NSMutableString alloc] initWithString:[htmlCheck substringWithRange:matchRange]];
        if (([arrival length] == 1) || ([arrival length] == 2 && ![arrival isEqualToString:@".."] && ![arrival isEqualToString:@">>"]))
        {
            [arrival appendString:@" min"];
        }
        if (first) {
            firstArrival = [NSString stringWithString:arrival];
            first = NO;
        }
        else secondArrival = [NSString stringWithString:arrival];
        
    }
}

@end
