//
//  TrainingClassifier.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 21/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#include <opencv2/core/core.hpp>
#include <opencv2/ml/ml.hpp>

#import "TrainingClassifier.h"
#import "HOGFeature.h"
#import "FileStorageHelper.h"


using namespace cv;

@implementation TrainingClassifier

@synthesize listOfTrainingImages = _listOfTrainingImages;



- (void) trainTheClassifier
{
    // Get the HOG Features of each image and store it in listOfH
    listOfHogFeatures = [self obtainHOGFeatures];
    
    int numOfTrainingSamples = [self.listOfTrainingImages count];
    
    
    // Set up training data
    float *labels = (float *) malloc(numOfTrainingSamples*sizeof(float));
    for(int i=0; i<numOfTrainingSamples; i++)
    {
        *(labels+i) = -1.0;
        if(i%5==0) *(labels+i)=1.0;
    }
    float *listOfHogFeatures2 = (float *) malloc(numOfFeatures*sizeof(float));
    for(int i=0; i<numOfFeatures*numOfTrainingSamples;i++)
        *(listOfHogFeatures2+i) = (float) *(listOfHogFeatures+i);
    
    Mat labelsMat(numOfTrainingSamples,1,CV_32FC1, labels); //labels
    Mat trainingDataMat(numOfTrainingSamples,numOfFeatures , CV_32FC1, listOfHogFeatures2); //training data
    
    // Set up SVM's parameters
    CvSVMParams params;
    params.svm_type    = CvSVM::C_SVC;
    params.kernel_type = CvSVM::LINEAR;
    params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
    
    // Train the SVM
    CvSVM SVM;
    SVM.train(trainingDataMat, labelsMat, Mat(), Mat(), params);            
    std::cout << trainingDataMat << std::endl; //output learning matrix
    
    // get the svm weights by multiplying the support vectors by the alpha values
    int numSupportVectors = SVM.get_support_vector_count();
    const CvSVMDecisionFunc *dec = SVM.decision_func;
    svmWeights = (float *) calloc((numOfFeatures+1),sizeof(float));
    for (int i = 0; i < numSupportVectors; ++i)
    {
        float alpha = *(dec[0].alpha + i);
        const float *supportVector = SVM.get_support_vector(i);
        for(int j=0;j<numOfFeatures;j++)
            *(svmWeights + j) += alpha * *(supportVector+j);
    }
    *(svmWeights + numOfFeatures) = - dec[0].rho; //FIXME: the sign of rho vs. the bias term!
    
    // write the template to a file
    [FileStorageHelper writeTemplate:svmWeights withSize:blocks withTitle:@"prova.txt"];
}



- (double *) obtainHOGFeatures
{
    int numOfTrainingSamples = [self.listOfTrainingImages count];
    HOGFeature *hogFeature = [[HOGFeature alloc] initWithNumberCells:8];
    double *feat;
    double *result;
    
    for(int i=0; i<numOfTrainingSamples; i++)
    {
        UIImage *uImage = [self.listOfTrainingImages objectAtIndex:i];
        feat = [hogFeature HOGOrientationWithDimension:blocks forImage:[uImage CGImage] withPhoneOrientation:uImage.imageOrientation];
        
        if(i==0)
        {
            //FIXME: why hog features are -1 in the last dimension??
            numOfFeatures = blocks[0]*blocks[1]*(blocks[2]-1);
            result = (double *) malloc(numOfTrainingSamples*numOfFeatures*sizeof(double));
        }

        NSLog(@"%d, %d, %d", blocks[0], blocks[1], blocks[2]);
        
        // copy values from feat to listOfHogFeatures
        for(int j=0; j<numOfFeatures; j++)
            *(result + i*numOfFeatures + j) = *(feat + j);
    }
    return(result);
}

- (void) saveTemplate
{
    
}

@end
