//
//  Classifier.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 28/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TrainingSet : NSObject

@property (strong, nonatomic) NSMutableArray *images; //UIImage
@property (strong, nonatomic) NSMutableArray *groundTruthBoundingBoxes; //ConvolutionPoint

@property (strong, nonatomic) NSArray *boundingBoxes;
@property double *imageFeatures; //the features for the wole trainingset
@property float *labels; //the corresponding labels
@property int *dimensionsOfHogFeatures;

// Given a training set of images and ground truth bounding boxes it generates
// a set of positive and negative bounding boxes for training
- (void) initialFill;

// Generates the hog features given the bounding boxes
- (void) generateFeaturesForBoundingBoxes;



@end



@interface Classifier : NSObject
{
    double *classifierWeights;
    int templateBlocksX;
    int templateBlocksY;
    int templateFeatures;
}


// Initialization of the classifier given the weight vectors of it
- (id) initWithWeights:(double *)weights number:(int *)numberWeigths;

// Train the classifier given an initial set formed by Images and ground
// truth bounding boxes containing positive examples
- (void) train:(TrainingSet *) trainingSet;

// Detect object in the image and return array of convolution
// points for the indicated number of pyramids and detection threshold
- (NSArray *) detect:(UIImage *) image
    minimumThreshold:(double) detectionThreshold
            pyramids:(int) numberPyramids; //return array of convolution points


@end