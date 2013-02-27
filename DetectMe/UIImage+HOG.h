//
//  UIImage+HOG.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 26/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HOG)

- (double *) obtainHogFeatures;
- (int *) obtainDimensionsOfHogFeatures;
- (UIImage *) convertToHogImage;

+ (UIImage *) hogImageFromFeatures:(double *)hogFeatures withSize:(int *)blocks;


@end
