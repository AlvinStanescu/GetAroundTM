//
//  TappableImageViewDelegate.h
//  TraficTM
//
//  Created by Alvin Stanescu on 12/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TappableImageView;
@protocol TappableImageViewDelegate <NSObject>

- (void)tappedImageView:(TappableImageView*)tIV;

@end
