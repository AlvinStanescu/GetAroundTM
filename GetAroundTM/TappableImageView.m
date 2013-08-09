//
//  tappableImageView.m
//  TraficTM
//
//  Created by Alvin Stanescu on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TappableImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TappableImageView
@synthesize label, name, delegate;

- (id)initWithImage:(UIImage *)image name:(NSString *)ivName frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setImage:image];
        self.name = [NSString stringWithString:ivName];
        [self doInitialSetup];
    }
    return self;
}

- (void)testTap
{
    if ([delegate respondsToSelector:@selector(tappedImageView:)]) {
        [delegate performSelector:@selector(tappedImageView:) withObject:self];
    }
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([delegate respondsToSelector:@selector(tappedImageView:)]) {
        [delegate performSelector:@selector(tappedImageView:) withObject:self];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInitialSetup];

    }
    return self;
}

- (void)doInitialSetup
{
    self.layer.cornerRadius = 12.0f;
    self.layer.masksToBounds = YES;
    // converts to bitmap
    self.layer.shouldRasterize = YES;
    
    self.userInteractionEnabled = YES;
    float labelOriginOffset;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        labelOriginOffset = self.bounds.size.height==144.0?120.0:240.0;
    else
        labelOriginOffset = 250.0;
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.origin.x, labelOriginOffset, self.bounds.size.width, 20.0)];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        [self.label setFont:[UIFont fontWithName:@"Helvetica Neue" size:22.0]];
    else
        [self.label setFont:[UIFont fontWithName:@"Helvetica Neue" size:26.0]];
    [self.label setText:name];
    [self.label setTextAlignment:UITextAlignmentCenter];
    [self.label setTextColor:[UIColor whiteColor]];
    [self.label setShadowColor:[UIColor blackColor]];
    [self.label setShadowOffset:CGSizeMake(2.0, 2.0)];
    [self.label setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.0]];
    [self addSubview:label];
}

@end
