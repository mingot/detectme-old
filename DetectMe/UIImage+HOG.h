//
//  UIImage+HOG.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 26/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HogFeature : NSObject
{
    @public int numBlocksX;
    @public int numBlocksY;
    @public int numFeatures;
    @public double *features;
}

@end

@interface UIImage (HOG)


- (HogFeature *) obtainHogFeaturesReturningHog;
- (double *) obtainHogFeatures;
- (int *) obtainDimensionsOfHogFeatures;
- (UIImage *) convertToHogImage;

+ (UIImage *) hogImageFromFeatures:(double *)hogFeatures withSize:(int *)blocks;


@end
