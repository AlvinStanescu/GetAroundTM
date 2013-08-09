//
//  tappableImageView.h
//  TraficTM
//
//  Created by Alvin Stanescu on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TAPPABLE_IV_IPHONE (float)144.0
#define TAPPABLE_IV_RETINA (float)288.0
#define TAPPABLE_IV_IPAD   (float)288.0

@interface TappableImageView : UIImageView
{

}
@property (retain) id delegate;
@property (strong, nonatomic) UILabel *label;
@property (nonatomic, retain) NSString *name;

- (void)doInitialSetup;
- (id)initWithImage:(UIImage *)image name:(NSString *)ivName frame:(CGRect)frame;
- (void)testTap;

@end
