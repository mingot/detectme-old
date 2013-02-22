//
//  TrainingClassifier.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 21/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "TrainingClassifier.h"
#import "HOGFeature.h"

@implementation TrainingClassifier

@synthesize listOfTrainingImages = _listOfTrainingImages;


- (void) trainTheClassifier
{
    [self obtainHOGFeatures];
}



- (void) obtainHOGFeatures
{
    int numImages = [self.listOfTrainingImages count];
    listOfHogFeatures = malloc(numImages*sizeof(double));
    HOGFeature *hogFeature = [[HOGFeature alloc] initWithNumberCells:8];
    
    
    for(int i=0; i<[self.listOfTrainingImages count]; i++)
    {

        int blocks[3]; //number of cells of the hog descriptor of the image (image hog size)
        double *feat = NULL; //initialization of the pointer to the features
        UIImage *uImage = [self.listOfTrainingImages objectAtIndex:i];
        CGImageRef imageRef =[uImage CGImage];
        
        
        feat = [hogFeature HOGOrientationWithDimension:blocks forImage:imageRef withPhoneOrientation:uImage.imageOrientation];
        
        NSLog(@"%d, %d, %d", blocks[0], blocks[1], blocks[2]);
//        if(i==0)
//            for(int j=0; j<blocks[0]*blocks[1]*blocks[2] ;j++)
//                NSLog(@"%f", *(feat +j));
        
        listOfHogFeatures = feat;
        listOfHogFeatures ++;
    }
}



@end
