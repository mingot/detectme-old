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

+ (NSArray *)convTempFeat:(UIImage *)image //Return the points with a score greater than -1
             withTemplate:(double *)templateValues;

+ (void) convolution:(double *)result matrixA:(double *)matrixA :(int *)sizeA matrixB:(double *)matrixB :(int *)sizeB;

+ (NSArray *)nms:(NSArray *)convolutionPointsCandidates maxOverlapArea:(double)overlap minScoreThreshold:(double)scoreThreshold;

@end



@interface ConvolutionPoint : NSObject

@property double score;
@property double xmin;
@property double xmax;
@property double ymin;
@property double ymax;

@property int label;
@property int imageIndex;
@property CGRect rectangle;

-(id) initWithRect:(CGRect)initialRect label:(int)label imageIndex:(int)imageIndex;
- (CGRect) rectangleForImage:(UIImage *)image;
- (double) fractionOfAreaOverlappingWith:(ConvolutionPoint *) cp;

@end