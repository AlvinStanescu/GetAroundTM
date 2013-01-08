//
//  GetAroundTMIAPHelper.m
//  GetAroundTM
//
//  Created by Alvin Stanescu on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GetAroundTMIAPHelper.h"

@implementation GetAroundTMIAPHelper

static GetAroundTMIAPHelper * _sharedHelper;

+ (GetAroundTMIAPHelper *) sharedHelper {
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[GetAroundTMIAPHelper alloc] init];
    return _sharedHelper;
}

- (id)init
{
    NSSet *productIdentifiers = [NSSet setWithObjects:@"com.thedamn3d.GetAroundTM.adremoval",nil];
    self = [super initWithProductIdentifiers:productIdentifiers];
    return self;
}

@end
