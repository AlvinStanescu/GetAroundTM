//
//  RoutesViewController.m
//  TraficTM
//
//  Created by Alvin Stanescu on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RoutesViewController.h"
#import "TappableImageView.h"
#import "TappableImageViewDelegate.h"
#import "RouteContainerViewController.h"
#import "GADBannerView.h"
#import <QuartzCore/QuartzCore.h>

#define NAVBAR_HEIGHT 44.0

@implementation RoutesViewController

- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
/*        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"com.thedamn3d.GetAroundTM.adremoval"])
        {
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
            {
                myFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - GAD_SIZE_320x50.height);
            }
            else
            {
                myFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height - GAD_SIZE_728x90.height);
            }
        }
        else {
            myFrame = frame;
        }*/
        myFrame = frame;
        self.title = NSLocalizedString(@"Routes",nil);
     //   presentedView = YES;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:myFrame];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    float size;
    float adSize = 0.0;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        size = [UIScreen mainScreen].bounds.size.width == 320.0?TAPPABLE_IV_IPHONE:TAPPABLE_IV_RETINA;
        adSize = GAD_SIZE_320x50.height;
    }
    else
    {
        size = TAPPABLE_IV_IPAD;
        adSize = GAD_SIZE_728x90.height;
    }
    CGFloat leftX, rightX, topY, bottomY;/*
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"com.thedamn3d.GetAroundTM.adremoval"])
    {
        // Ads present
        leftX = ((self.view.frame.size.width / 2.0) - size) / 2.0;
        rightX = leftX + (self.view.frame.size.width / 2.0);
        topY = (((self.view.frame.size.height - adSize - 20.0)/ 2.0) - size) / 2.0;
        bottomY = topY + ((self.view.frame.size.height - adSize - 20.0)/ 2.0);
    }
    else {*/
        leftX = ((self.view.frame.size.width / 2.0) - size) / 2.0;
        rightX = leftX + (self.view.frame.size.width / 2.0);
        topY = (((self.view.frame.size.height - 20.0)/ 2.0) - size) / 2.0;
        bottomY = topY + ((self.view.frame.size.height - 80.0)/ 2.0);
    //}
       
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)                                                       
    {
        busImageView = [[TappableImageView alloc] initWithImage:[UIImage imageNamed:@"autobuz.png"] name:NSLocalizedString(@"Bus Lines",nil) frame:CGRectMake(leftX, topY, size, size)];
        expressImageView = [[TappableImageView alloc] initWithImage:[UIImage imageNamed:@"em.png"] name:NSLocalizedString(@"E/M Lines",nil) frame:CGRectMake(rightX, topY, size, size)];
        tramImageView = [[TappableImageView alloc] initWithImage:[UIImage imageNamed:@"tramvai.png"] name:NSLocalizedString(@"Tram Lines",nil) frame:CGRectMake(leftX, bottomY, size, size)];
        trolleyImageView = [[TappableImageView alloc] initWithImage:[UIImage imageNamed:@"troleibuz.png"] name:NSLocalizedString(@"Trolley Lines",nil) frame:CGRectMake(rightX, bottomY, size, size)];
    }
    else
    {
        busImageView = [[TappableImageView alloc] initWithImage:[UIImage imageNamed:@"autobuz@2x.png"] name:NSLocalizedString(@"Bus Lines",nil) frame:CGRectMake(leftX, topY, size, size)];
        expressImageView = [[TappableImageView alloc] initWithImage:[UIImage imageNamed:@"em@2x.png"] name:NSLocalizedString(@"E/M Lines",nil) frame:CGRectMake(rightX, topY, size, size)];
        tramImageView = [[TappableImageView alloc] initWithImage:[UIImage imageNamed:@"tramvai@2x.png"] name:NSLocalizedString(@"Tram Lines",nil) frame:CGRectMake(leftX, bottomY, size, size)];
        trolleyImageView = [[TappableImageView alloc] initWithImage:[UIImage imageNamed:@"troleibuz@2x.png"] name:NSLocalizedString(@"Trolley Lines",nil) frame:CGRectMake(rightX, bottomY, size, size)];            
    }
    [busImageView setDelegate:self];
    [expressImageView setDelegate:self];
    [tramImageView setDelegate:self];
    [trolleyImageView setDelegate:self];
    
    [self.view addSubview:busImageView];
    [self.view addSubview:expressImageView];
    [self.view addSubview:tramImageView];
    [self.view addSubview:trolleyImageView];

}

- (void)viewDidUnload
{
    [busImageView removeFromSuperview];
    [expressImageView removeFromSuperview];
    [tramImageView removeFromSuperview];
    [trolleyImageView removeFromSuperview];
    busImageView = nil;
    expressImageView = nil;
    tramImageView = nil;
    trolleyImageView = nil;
    [super viewDidUnload];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self)
    {
        self.navigationController.navigationBarHidden = YES;
     //   presentedView = YES;
        
    }
    else
    {
        self.navigationController.navigationBarHidden = NO;
     //   presentedView = NO;
    }
}

- (void)tappedImageView:(TappableImageView *)tIV
{  
    RouteContainerViewController *rcvc = [[RouteContainerViewController alloc] initWithStyle:UITableViewStylePlain type:tIV.name];
    [[self navigationController] pushViewController:rcvc animated:YES];
//    [self.navigationController.navigationBar setHidden:NO];
}

@end
