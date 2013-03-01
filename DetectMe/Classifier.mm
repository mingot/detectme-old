//
//  Classifier.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 28/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#include <opencv2/core/core.hpp>
#include <opencv2/ml/ml.hpp>

#import "Classifier.h"
#import "UIImage+HOG.h"
#import "UIImage+Resize.h"
#import "ConvolutionHelper.h"
#import "ImageProcessingHelper.h"

using namespace cv;


////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TrainingSet
////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation TrainingSet

@synthesize images = _images;
@synthesize groundTruthBoundingBoxes = _groundTruthBoundingBoxes;
@synthesize boundingBoxes = _boundingBoxes;
@synthesize imageFeatures = _imageFeatures;
@synthesize labels = _labels;
@synthesize dimensionsOfHogFeatures = _dimensionsOfHogFeatures;


- (void) initialFill
{
    // Create a initial set of positive and negative bounding boxes from ground truth labeled images
    
    NSMutableArray *listOfConvolutionPoints = [[NSMutableArray alloc] initWithArray:self.groundTruthBoundingBoxes];
    
    ConvolutionPoint *referenceConvPoint = [self.groundTruthBoundingBoxes objectAtIndex:0];
    float height = referenceConvPoint.xmax - referenceConvPoint.xmin;
    float width = referenceConvPoint.ymax - referenceConvPoint.ymin;
    
    for(int i=0; i<[self.images count]; i++)
    {
        for(int j=0; j<4;j++)
        {
            ConvolutionPoint *negativeExample = [[ConvolutionPoint alloc] initWithRect:CGRectMake(0, j/8, width, height) label:-1 imageIndex:i];
            
            [listOfConvolutionPoints addObject:negativeExample];
        }
    }
    
    self.boundingBoxes = [[NSArray alloc] initWithArray:listOfConvolutionPoints];
}


- (void) generateFeaturesForBoundingBoxes
{
    // Convert the bounding boxes to hog features
    
    //Allocate memory for the features and the labels
    self.labels = (float *) malloc([self.boundingBoxes count]*sizeof(float));
    
    // transform each bounding box into hog feature space
    HogFeature *hogFeature;
    
    for(int i=0; i<[self.boundingBoxes count]; i++)
    {
        ConvolutionPoint *boundingBox = [self.boundingBoxes objectAtIndex:i];
        
        //get the image contained in the bounding box
        UIImage *wholeImage = [self.images objectAtIndex:boundingBox.imageIndex];
        UIImage *img = [wholeImage croppedImage:[boundingBox rectangleForImage:wholeImage]];
        CGSize newSize;
        newSize.height = img.size.height/3;
        newSize.width = img.size.width/3;
        
        UIImage *resizedImage = [img resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
        
        hogFeature = [resizedImage obtainHogFeaturesReturningHog];
        self.dimensionsOfHogFeatures = hogFeature.dimensionOfHogFeatures;
        if(i==0) self.imageFeatures = (double *) malloc([self.boundingBoxes count]*hogFeature.totalNumberOfFeatures*sizeof(double));
        
        //add the label
        *(self.labels + i) = (float) boundingBox.label;
        
        //add the hog features
        for(int j=0; j<hogFeature.totalNumberOfFeatures; j++)
            *(self.imageFeatures + i*hogFeature.totalNumberOfFeatures + j) = *(hogFeature.features + j);
        NSLog(@"Bounding box %d, first hogFeature:%f", i, *hogFeature.features);
    }
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Classifier
////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface Classifier ()

@property (strong, nonatomic) NSArray *boundingBoxes;
@property (strong, nonatomic) NSArray *labels;


// Update the weight vector of the classifier given a trained CvSVM
- (void) updateSvmWeights:(CvSVM) svmModel;

@end


@implementation Classifier


- (id) initWithWeights:(double *)weights number:(int *)numberWeigths
{
    if(self = [super init])
    {
        self.weightsDimensions = numberWeigths;
        for(int i=0; i <numberWeigths[0]*numberWeigths[1]*numberWeigths[2]; i++)
            *(self.svmWeights +i) = *(weights +i);
    }
    
    return self;
}

- (void) train:(TrainingSet *) trainingSet;
{
    
    //begin loop
    int numIterations = 1;
    for (int i=0; i<numIterations; i++)
    {
        
        //Initialization of weights: initial train with initial positives and random negatives
        if(i==0) [trainingSet initialFill];
        [trainingSet generateFeaturesForBoundingBoxes];
        
        // Set up training data
        float *labels = trainingSet.labels;
        self.weightsDimensions = trainingSet.dimensionsOfHogFeatures;
        int numOfFeatures = self.weightsDimensions[0]*self.weightsDimensions[1]*self.weightsDimensions[2];
        int numOfTrainingSamples = [trainingSet.boundingBoxes count];
        float *listOfHogFeaturesFloat = (float *) malloc(numOfFeatures*numOfTrainingSamples*sizeof(float));
        
        for(int i=0; i<numOfFeatures*numOfTrainingSamples; i++)
            *(listOfHogFeaturesFloat+i) = (float) *(trainingSet.imageFeatures + i);
        
        Mat labelsMat(numOfTrainingSamples,1,CV_32FC1, labels); //labels
        Mat trainingDataMat(numOfTrainingSamples, numOfFeatures, CV_32FC1, listOfHogFeaturesFloat); //training data
        
        // Set up SVM's parameters
        CvSVMParams params;
        params.svm_type    = CvSVM::C_SVC;
        params.kernel_type = CvSVM::LINEAR;
        params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
        
        // Train the SVM
        CvSVM SVM;
        SVM.train(trainingDataMat, labelsMat, Mat(), Mat(), params);
        //std::cout << trainingDataMat << std::endl; //output learning matrix
        
        //update weights
        int numSupportVectors = SVM.get_support_vector_count();
        numOfFeatures = SVM.get_var_count();
        const CvSVMDecisionFunc *dec = SVM.decision_func;
        self.svmWeights = (double *) calloc((numOfFeatures+1),sizeof(double));
        
        for (int i = 0; i < numSupportVectors; ++i)
        {
            float alpha = *(dec[0].alpha + i);
            const float *supportVector = SVM.get_support_vector(i);
            for(int j=0;j<numOfFeatures;j++)
                *(self.svmWeights + j) += (double) alpha * *(supportVector+j);
        }
        *(self.svmWeights + numOfFeatures) = - (double) dec[0].rho; // The sign of the bias and rho have opposed signs.
        
        NSLog(@"bias: %f", - dec[0].rho);
        NSLog(@"%d, %d, %d", self.weightsDimensions[0], self.weightsDimensions[1], self.weightsDimensions[2]);
        
        // Get new bounding boxes by running the detector
        NSArray *newBoundingBoxes = [self detect:[trainingSet.images objectAtIndex:0] minimumThreshold:-1 pyramids:10];
        NSLog(@"number of bb obtained: %d", [newBoundingBoxes count]);
        
        //retrain with the updated weights
        free(listOfHogFeaturesFloat);
    }
}

- (NSArray *) detect:(UIImage *)image minimumThreshold:(double) detectionThreshold pyramids:(int) numberPyramids
{
    int totalFeatures = self.weightsDimensions[0]*self.weightsDimensions[1]*self.weightsDimensions[2];
    double *templateWeights = (double *) malloc((totalFeatures + 3)*sizeof(double));
    *(templateWeights) = self.weightsDimensions[0];
    *(templateWeights + 1) = self.weightsDimensions[1];
    *(templateWeights + 2) = self.weightsDimensions[2];
    
    for(int i=0; i<totalFeatures; i++)
        *(templateWeights + 3 + i) = *(self.svmWeights + i);
    
    
    NSMutableArray *candidateBoundingBoxes = [[NSMutableArray alloc] init];
    
    // TODO: choose max size for the image
    // int maxsize = (int) (max(image.size.width,image.size.height));
    // Pongo de tamaño maximo 300 por poner algo --> poderlo escoger.
    int maxsize = 300;
    
    CGImageRef resizedImage = [ImageProcessingHelper resizeImage:image.CGImage withRect:maxsize];
    double sc = pow(2, 1.0/numberPyramids);
    
    //int *max = malloc(2*nm*interval*sizeof(int));
    //double *scores = malloc(sizeof(double)*nm*interval);
    
    //    clock_t start = clock(); //Trace execution time
    
    [candidateBoundingBoxes addObjectsFromArray:[ConvolutionHelper convTempFeat:resizedImage withTemplate:templateWeights orientation:image.imageOrientation]];
    
    for (int i = 1; i<numberPyramids; i++) { //Pyramid calculation
        
        CGImageRef scaledImage = [ImageProcessingHelper scaleImage:resizedImage scale:1/pow(sc, i)];
        [candidateBoundingBoxes addObjectsFromArray: [ConvolutionHelper convTempFeat:scaledImage
                                                                        withTemplate:templateWeights
                                                                         orientation:image.imageOrientation]];
        
        CGImageRelease(scaledImage);
    }
    
    NSLog(@"candidate bounding boxes: %d", [candidateBoundingBoxes count]);
    NSArray *nmsArray = [ConvolutionHelper nms:candidateBoundingBoxes maxOverlapArea:0.25 minScoreThreshold:detectionThreshold];
    
    free(templateWeights);
    return nmsArray;
    
}



- (void) updateSvmWeights:(CvSVM) svmModel
{    
    int numSupportVectors = svmModel.get_support_vector_count();
    int numOfFeatures = svmModel.get_var_count();
    
    const CvSVMDecisionFunc *dec = svmModel.decision_func;
    self.svmWeights = (double *) calloc((numOfFeatures+1),sizeof(double));
    
    for (int i = 0; i < numSupportVectors; ++i)
    {
        float alpha = *(dec[0].alpha + i);
        const float *supportVector = svmModel.get_support_vector(i);
        for(int j=0;j<numOfFeatures;j++)
            *(self.svmWeights + j) += (double) alpha * *(supportVector+j);
    }
    *(self.svmWeights + numOfFeatures) = - (double) dec[0].rho; // The sign of the bias and rho have opposed signs.

}


- (void) storeSvmWeightsAsTemplateWithName:(NSString *)templateName
{
    
}



@end
