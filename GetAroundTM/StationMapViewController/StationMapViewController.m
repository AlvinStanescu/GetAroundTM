//
//  MapsViewController.m
//  GetAroundTM
//
//  Created by Alvin Stanescu on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StationMapViewController.h"

@implementation StationMapViewController
@synthesize scrollView;
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Station Map", nil);
        // Custom initialization
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [scrollView setBackgroundColor:[UIColor blackColor]];
    [scrollView setCanCancelContentTouches:NO];
    scrollView.clipsToBounds = YES;    // default is NO, we want to restrict drawing within our scrollview
    scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;

    scrollView.minimumZoomScale = 1;
    scrollView.maximumZoomScale = 5;
    scrollView.delegate = self;
    [scrollView setScrollEnabled:YES];
}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return mapView;
}


@end
