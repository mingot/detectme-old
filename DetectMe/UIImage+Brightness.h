//
//  UIImage+Brightness.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 04/03/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Brightness)

- (UIImage*)saturateImage:(int)amount;

- (UIImage *) brightImage:(float)amount;

@end

