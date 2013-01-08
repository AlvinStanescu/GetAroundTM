//
//  RouteContainerViewController.h
//  TraficTM
//
//  Created by Alvin Stanescu on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteContainerViewController : UITableViewController
{
    NSString *type;
    NSMutableArray *lines;
}
@property (nonatomic, strong) NSString *type;

- (id)initWithStyle:(UITableViewStyle)style type:(NSString*)myType;

@end
