//
//  RoutesViewController.h
//  TraficTM
//
//  Created by Alvin Stanescu on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TappableImageViewDelegate.h"

@class TappableImageView;
@interface RoutesViewController : UIViewController <TappableImageViewDelegate, UINavigationControllerDelegate>
{
    CGRect myFrame;
    TappableImageView *busImageView;
    TappableImageView *expressImageView;
    TappableImageView *tramImageView;
    TappableImageView *trolleyImageView;
 //   BOOL presentedView;
}

- (id)initWithFrame:(CGRect)frame;

@end
