//
//  TrainingClassifier.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 21/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TrainingSet : NSObject


@property (strong, nonatomic) NSArray *listOfImages; //UIImage
@property (strong, nonatomic) NSArray *listOfBoundingBoxes; //CGRectmake
@property (strong, nonatomic) NSArray *listOfPositives; //UIImage
@property (strong, nonatomic) NSArray *listOfNegatives; //UIImage

@property double *imageFeatures; //the features for the wole trainingset
@property int *labels; //the corresponding labels

// Convert the list of positiva and negative images in features to pass to the SVM
- (void) convertImagesToFeatures;

@end




@interface TrainingClassifier : NSObject
{
    double *listOfHogFeatures; //array of pointers to the hog features of each image
    int numOfFeatures;
    float *svmWeights;
    @public int *blocks; //HOG features size
}

@property (strong,nonatomic) NSArray *listOfTrainingImages; //UIImages

- (float *) trainTheClassifier;

@end
