//
//  ConvolutionHelper.h
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 07/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HOGFeature.h"
#import "DetectView.h"





@interface ConvolutionHelper : NSObject

+ (NSArray *)convTempFeat:(CGImageRef)image //Return the points with a score greater than -1
             withTemplate:(double *) templateValues
              orientation:(int)orientation 
           withHogFeature:(HOGFeature *)hogFeature;

+ (NSArray *) convPyraFeat:(UIImage *)image //Convolution using pyramid
              withTemplate:(double *) templateValues
              inDetectView:(DetectView *)detectView
            withHogFeature:(HOGFeature *)hogFeature
                  pyramids:(int )numberPyramids;
              

+ (NSArray *) convPyraFeatFromFile:(UIImage *)image
                      withTemplate:(double *)templateValues
                       withMaxSize:(int)maxSize
                    withHogFeature:(HOGFeature *)hogFeature;

+ (NSArray *)nms:(NSArray *)c //Compute non maximum supression
                :(double) overlap;


@end



@interface ConvolutionPoint : NSObject

@property (strong,nonatomic) NSNumber *score;
@property (strong,nonatomic) NSNumber *xmin;
@property (strong,nonatomic) NSNumber *xmax;
@property (strong,nonatomic) NSNumber *ymin;
@property (strong,nonatomic) NSNumber *ymax;


@end