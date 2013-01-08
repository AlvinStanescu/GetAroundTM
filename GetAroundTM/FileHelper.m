//
//  FileHelper.m
//  TraficTM
//
//  Created by Alvin Stanescu on 11/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FileHelper.h"

NSString *pathInDocumentDirectory (NSString *fileName)
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDir = [documentDirectories objectAtIndex:0];
    
    return [documentDir stringByAppendingPathComponent:fileName];
}