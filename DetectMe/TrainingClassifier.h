//
//  TrainingClassifier.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 21/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TrainingClassifier : NSObject
{
    double *listOfHogFeatures; //array of pointers to the hog features of each image
    int numOfFeatures;
    float *svmWeights;
    int blocks[3]; //HOG features size
}


@property (strong,nonatomic) NSArray *listOfTrainingImages; //UIImages actually
//template solution


- (void) trainTheClassifier;

@end
