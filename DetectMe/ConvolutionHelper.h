//
//  ConvolutionHelper.h
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 07/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DetectView.h"





@interface ConvolutionHelper : NSObject

+ (NSArray *)convTempFeat:(CGImageRef)image //Return the points with a score greater than -1
             withTemplate:(double *) templateValues
              orientation:(int)orientation;

+ (NSArray *) convPyraFeat:(UIImage *)image //Convolution using pyramid
              withTemplate:(double *) templateValues
                  pyramids:(int )numberPyramids
            scoreThreshold:(double)scoreThreshold;
              
+ (void) convolution:(double *)result matrixA:(double *)matrixA :(int *)sizeA matrixB:(double *)matrixB :(int *)sizeB;

+ (NSArray *)nms:(NSArray *)convolutionPointsCandidates maxOverlapArea:(double)overlap minScoreThreshold:(double)scoreThreshold;


@end



@interface ConvolutionPoint : NSObject

@property (strong,nonatomic) NSNumber *score;
@property (strong,nonatomic) NSNumber *xmin;
@property (strong,nonatomic) NSNumber *xmax;
@property (strong,nonatomic) NSNumber *ymin;
@property (strong,nonatomic) NSNumber *ymax;


@end