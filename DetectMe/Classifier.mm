//
//  Classifier.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 28/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#include <opencv2/core/core.hpp>
#include <opencv2/ml/ml.hpp>
#include <stdlib.h>

#import "Classifier.h"
#import "UIImage+HOG.h"
#import "UIImage+Resize.h"
#import "ConvolutionHelper.h"
#import "ImageProcessingHelper.h"

using namespace cv;

#define debugging YES


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


- (void) initialFill
{
    // Create a initial set of positive and negative bounding boxes from ground truth labeled images
    
    self.boundingBoxes = [[NSMutableArray alloc] initWithArray:self.groundTruthBoundingBoxes];
    
    ConvolutionPoint *referenceConvPoint = [self.groundTruthBoundingBoxes objectAtIndex:0];
    float height = referenceConvPoint.xmax - referenceConvPoint.xmin;
    float width = referenceConvPoint.ymax - referenceConvPoint.ymin;
    
    
    double randomX;
    double randomY;
    
    for(int i=0; i<[self.images count]; i++)
    {
        ConvolutionPoint *groundTruth = [self.groundTruthBoundingBoxes objectAtIndex:i];
        
        int num=100;
        for(int j=0; j<num/2;j++)
        {
            if(j%4==0)
            {
                randomX = 0;
                randomY = j*1.0/num;
            }else if(j%4==1){
                randomX = j*1.0/num;
                randomY = 0;
            }else if(j%4==2){
                randomX = 1 - width;
                randomY = j*1.0/num;
            }else{
                randomX = j*1.0/num;
                randomY = 1-height;
            }
            
            ConvolutionPoint *negativeExample = [[ConvolutionPoint alloc] initWithRect:CGRectMake(randomX, randomY, width, height) label:-1 imageIndex:i];
            
            if([negativeExample fractionOfAreaOverlappingWith:groundTruth]<0.1)
                [self.boundingBoxes addObject:negativeExample];
        }
    }
    
    self.numberOfTrainingExamples = [self.boundingBoxes count];
}


- (void) generateFeaturesForBoundingBoxesWithTemplateSize:(CGSize)templateSize
{    
    //Allocate memory for the features and the labels
    self.labels = (float *) malloc([self.boundingBoxes count]*sizeof(float));
    
    // transform each bounding box into hog feature space
    HogFeature *hogFeature;
    
    for(int i=0; i<[self.boundingBoxes count]; i++)
    {
        ConvolutionPoint *boundingBox = [self.boundingBoxes objectAtIndex:i];
        
        //get the image contained in the bounding box and resized it with the template size
        UIImage *wholeImage = [self.images objectAtIndex:boundingBox.imageIndex];
        UIImage *img = [wholeImage croppedImage:[boundingBox rectangleForImage:wholeImage]];
        UIImage *resizedImage = [img resizedImage:templateSize interpolationQuality:kCGInterpolationDefault];
        
        
        //calculate the hogfeatures of the image
        hogFeature = [resizedImage obtainHogFeaturesReturningHog];
        if(i==0) self.imageFeatures = (double *) malloc([self.boundingBoxes count]*hogFeature.totalNumberOfFeatures*sizeof(double));
        
        //add the label
        self.labels[i] = (float) boundingBox.label;
        
        //add the hog features
        for(int j=0; j<hogFeature.totalNumberOfFeatures; j++)
            *(self.imageFeatures + i*hogFeature.totalNumberOfFeatures + j) = hogFeature.features[j];
    }
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Classifier
////////////////////////////////////////////////////////////////////////////////////////////////////////


@interface Classifier ()
{
    CGSize templateSize;
}

@property double *supportVectors;
@property int numSupportVectors;

// Update the weight vector of the classifier given a trained CvSVM
- (void) updateSvmWeights:(CvSVM) svmModel;

//Sets the size of the template and obtain the dimension of the features from it.
- (void) obtainTemplateSize:(TrainingSet *) trainingSet;

// Add hog features from support vectors to the current hog features from bounding boxes
- (void) addSupportVectorsToTrainingSet:(TrainingSet *) trainingSet;


@end


@implementation Classifier


@synthesize svmWeights = _svmWeights;
@synthesize weightsDimensions = _weightsDimensions;

//private
@synthesize supportVectors = _supportVectors;
@synthesize numSupportVectors = _numSupportVectors;


#pragma mark -
#pragma mark Classifier Public Methods


- (id) initWithTemplateWeights:(double *)templateWeights
{
    if(self = [super init])
    {
        self.weightsDimensions = (int *) malloc(3*sizeof(int));
        self.weightsDimensions[0] = (int) templateWeights[0];
        self.weightsDimensions[1] = (int) templateWeights[1];
        self.weightsDimensions[2] = (int) templateWeights[2];
        
        int numberOfSvmWeights = self.weightsDimensions[0]*self.weightsDimensions[1]*self.weightsDimensions[2] + 1; //+1 for the bias 
        self.svmWeights = (double *) malloc(numberOfSvmWeights*sizeof(double));
        for(int i=0; i <numberOfSvmWeights; i++) 
            self.svmWeights[i] = templateWeights[3 + i];
    }
    
    return self;
}



- (void) train:(TrainingSet *) trainingSet;
{
    
    // Get the template size and get hog feautures dimension
    [self obtainTemplateSize:trainingSet];
    int numOfFeatures = self.weightsDimensions[0]*self.weightsDimensions[1]*self.weightsDimensions[2];
    
    if(debugging)
    {
        NSLog(@"template size: %f, %f", templateSize.height, templateSize.width);
        NSLog(@"dimensions of hog features: %d %d %d", self.weightsDimensions[0],self.weightsDimensions[1],self.weightsDimensions[2]);
    }
        
    //Initialization of weights: initial train with initial positives and random negatives
    [trainingSet initialFill];
    [trainingSet generateFeaturesForBoundingBoxesWithTemplateSize: templateSize];
    
    //convergence loop
    int numIterations = 1;
    for (int i=0; i<numIterations; i++)
    {
        // Set up training data
        if(debugging) NSLog(@"Number of Training Examples: %d", trainingSet.numberOfTrainingExamples);
        
        // cast the hog features to float
        float *listOfHogFeaturesFloat = (float *) malloc(numOfFeatures*trainingSet.numberOfTrainingExamples*sizeof(float));
        for(int i=0; i<numOfFeatures*trainingSet.numberOfTrainingExamples; i++)
            listOfHogFeaturesFloat[i] = (float) trainingSet.imageFeatures[i];
        
        Mat labelsMat(trainingSet.numberOfTrainingExamples,1,CV_32FC1, trainingSet.labels);
        Mat trainingDataMat(trainingSet.numberOfTrainingExamples, numOfFeatures, CV_32FC1, listOfHogFeaturesFloat); 

        
        // Set up SVM's parameters
        CvSVMParams params;
        params.svm_type    = CvSVM::C_SVC;
        params.kernel_type = CvSVM::LINEAR;
        params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        //Train the SVM, update weights and store support vectors
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        CvSVM SVM;
        SVM.train(trainingDataMat, labelsMat, Mat(), Mat(), params);
        //std::cout << trainingDataMat << std::endl; //output learning matrix
        
        //update weights and store the support vectors
        
        int numSupportVectors = SVM.get_support_vector_count();
        const CvSVMDecisionFunc *dec = SVM.decision_func;
        self.svmWeights = (double *) calloc((numOfFeatures+1),sizeof(double));
        self.supportVectors = (double *) malloc(numOfFeatures*numSupportVectors*sizeof(double));
        
        for (int i = 0; i < numSupportVectors; ++i)
        {
            float alpha = dec[0].alpha[i];
            const float *supportVector = SVM.get_support_vector(i);
            
            for(int j=0;j<numOfFeatures;j++)
            {
                // add to get the weights
                self.svmWeights[j] += (double) alpha * supportVector[j];
                
                //store the support vector
                *(self.supportVectors + i*numSupportVectors +j) = (double) supportVector[j];
            }
        }
        self.svmWeights[numOfFeatures] = - (double) dec[0].rho; // The sign of the bias and rho have opposed signs.
        
        [self storeTemplateMatching:trainingSet];
        
        if(debugging)
        {
            NSLog(@"bias: %f", - dec[0].rho);
            NSLog(@"self.weightDimensions: %d, %d, %d", self.weightsDimensions[0], self.weightsDimensions[1], self.weightsDimensions[2]);
        }
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        //Update bounding boxes
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        // Get new bounding boxes by running the detector
        NSArray *newBoundingBoxes = [self detect:[trainingSet.images objectAtIndex:0] minimumThreshold:-1 pyramids:10 usingNms:NO];
        if(debugging) NSLog(@"number of bb obtained: %d", [newBoundingBoxes count]);
        
        //remove all current bounding boxes
        [trainingSet.boundingBoxes removeAllObjects];
        
        //the rest that are less than an overlap threshold are considered negatives
        ConvolutionPoint *groundTruthBoundingBox = [trainingSet.groundTruthBoundingBoxes objectAtIndex:0];
        for(int j=0; j<[newBoundingBoxes count]; j++)
        {
            ConvolutionPoint *boundingBox = [newBoundingBoxes objectAtIndex:j];
            double overlapArea = [boundingBox fractionOfAreaOverlappingWith:groundTruthBoundingBox];
            boundingBox.label = -1;
            boundingBox.imageIndex = 0;
            [trainingSet.boundingBoxes addObject:boundingBox];
            
            if (overlapArea > 0)
            {
                //TODO: New positive example to gain robustness!!
            }
        }
        
        //generate the hog features for the new bounding boxes
        [trainingSet generateFeaturesForBoundingBoxesWithTemplateSize:templateSize];
        
        //Add the current support vectors to the new hog features generated
        [self addSupportVectorsToTrainingSet:trainingSet];
        
        free(listOfHogFeaturesFloat);
    }
}



- (NSArray *) detect:(UIImage *)image
    minimumThreshold:(double) detectionThreshold
            pyramids:(int)numberPyramids
            usingNms:(BOOL)useNms
{
    int totalFeatures = self.weightsDimensions[0]*self.weightsDimensions[1]*self.weightsDimensions[2];
    double *templateWeights = (double *) calloc((3 + totalFeatures + 1),sizeof(double));
    templateWeights[0] = self.weightsDimensions[0];
    templateWeights[1] = self.weightsDimensions[1];
    templateWeights[2] = self.weightsDimensions[2];
    
    for(int i=0; i<totalFeatures + 1; i++) //+1 for the bias term
        templateWeights[3+i] = self.svmWeights[i];
    
    
    NSMutableArray *candidateBoundingBoxes = [[NSMutableArray alloc] init];
    
    // TODO: choose max size for the image
    // int maxsize = (int) (max(image.size.width,image.size.height));
    // Pongo de tamaño maximo 300 por poner algo --> poderlo escoger.
    int maxsize = 300;
    
    CGImageRef resizedImage = [ImageProcessingHelper resizeImage:image.CGImage withRect:maxsize];
    double sc = pow(2, 1.0/numberPyramids);
    
    UIImage *imgaux = [UIImage imageWithCGImage:resizedImage];
    
    NSLog(@"h:%f, w:%f", imgaux.size.height, imgaux.size.width);
    
    [candidateBoundingBoxes addObjectsFromArray:[ConvolutionHelper convTempFeat:resizedImage
                                                                   withTemplate:templateWeights
                                                                    orientation:image.imageOrientation]];
    
    //Pyramid calculation
    for (int i = 1; i<numberPyramids; i++)
    {
        
        NSArray *result = [ConvolutionHelper convTempFeat:[ImageProcessingHelper scaleImage:resizedImage scale:1/pow(sc, i)]
                                             withTemplate:templateWeights
                                              orientation:image.imageOrientation];
        
        [candidateBoundingBoxes addObjectsFromArray: result];
//        NSLog(@"Level %d detected %d boxes",i, [candidateBoundingBoxes count]);
        
        
    }
    
    NSArray *nmsArray = candidateBoundingBoxes;
    if(useNms) nmsArray = [ConvolutionHelper nms:candidateBoundingBoxes maxOverlapArea:0.25 minScoreThreshold:19]; //19
    
    CGImageRelease(resizedImage);
    free(templateWeights);
    return nmsArray;
    
}

- (void) storeSvmWeightsAsTemplateWithName:(NSString *)templateName
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/Templates/%@",documentsDirectory,templateName];
    
    NSMutableString *content = [NSMutableString stringWithCapacity:self.weightsDimensions[0]*self.weightsDimensions[1]*self.weightsDimensions[2]+4];
    [content appendFormat:@"%d\n",self.weightsDimensions[0]];
    [content appendFormat:@"%d\n",self.weightsDimensions[1]];
    [content appendFormat:@"%d\n",self.weightsDimensions[2]];
    for (int i = 0; i<self.weightsDimensions[0]*self.weightsDimensions[1]*self.weightsDimensions[2] + 1; i++)
        [content appendFormat:@"%f\n",self.svmWeights[i]];
    
    if([content writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:NULL]){
        NSLog(@"Write Template Work!");
    }
}


- (void) storeTemplateMatching:(TrainingSet *) trainingSet;
{
    HogFeature *hogFeature;
    
    UIImage *wholeImage = [trainingSet.images objectAtIndex:0];
    UIImage *img = [wholeImage croppedImage:[[trainingSet.boundingBoxes objectAtIndex:0] rectangleForImage:wholeImage]];
    UIImage *resizedImage = [img resizedImage:templateSize interpolationQuality:kCGInterpolationDefault];
    
    hogFeature = [resizedImage obtainHogFeaturesReturningHog];

    for(int i=0; i<hogFeature.totalNumberOfFeatures;i++)
        self.svmWeights[i] = hogFeature.features[i];
    
    //bias term as 0
    self.svmWeights[hogFeature.totalNumberOfFeatures] = 0;

}

#pragma mark -
#pragma mark Classifier Private Methods

- (void) obtainTemplateSize:(TrainingSet *) trainingSet
{
    
    //select first groundtruth bounding box
    ConvolutionPoint *sampleBoundingBox = [trainingSet.groundTruthBoundingBoxes objectAtIndex:0];
    
    UIImage *wholeImage = [trainingSet.images objectAtIndex:sampleBoundingBox.imageIndex];
    UIImage *img = [wholeImage croppedImage:[sampleBoundingBox rectangleForImage:wholeImage]];
    
    
    templateSize.height = img.size.height*0.6;
    templateSize.width = img.size.width*0.6;
    
    // And store dimension of hog features for it
    self.weightsDimensions = [[img resizedImage:templateSize interpolationQuality:kCGInterpolationDefault] obtainDimensionsOfHogFeatures];
    
    
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
            self.svmWeights[j] += (double) alpha * supportVector[j];
    }
    self.svmWeights[numOfFeatures] = - (double) dec[0].rho; // The sign of the bias and rho have opposed signs.

}

- (void) addSupportVectorsToTrainingSet:(TrainingSet *) trainingSet
{
    int numFeatures = self.weightsDimensions[0]*self.weightsDimensions[1]*self.weightsDimensions[2];
    double *totalFeatures = (double *) malloc((self.numSupportVectors + [trainingSet.boundingBoxes count])*numFeatures*sizeof(double));
    
    //copy support vectors
    for(int i=0; i<self.numSupportVectors*numFeatures;i++)
        totalFeatures[i] = self.supportVectors[i];
    
    //copy bounding boxes features
    for(int i=0; i<[trainingSet.boundingBoxes count]*numFeatures; i++)
        totalFeatures[self.numSupportVectors*numFeatures + i] = trainingSet.imageFeatures[i];
    
    //return this vector to the TrainingSet object
    trainingSet.imageFeatures = (double *) malloc((self.numSupportVectors + [trainingSet.boundingBoxes count])*numFeatures*sizeof(double));

    for(int i=0; i<(self.numSupportVectors + [trainingSet.boundingBoxes count])*numFeatures; i++)
        trainingSet.imageFeatures[i] = totalFeatures[i];
    
    //FIXME: UPDATE THE LABELS!!
}


@end
