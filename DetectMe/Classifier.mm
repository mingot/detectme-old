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

@synthesize imagesUsed = _imagesUsed;



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
        
        int num=20;
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
    // Allocate memory for the features and the labels
    self.labels = (float *) malloc([self.boundingBoxes count]*sizeof(float));
    
    // Store latest images bounding boxes used
    self.imagesUsed = [[NSMutableArray alloc] initWithCapacity:[self.boundingBoxes count]];
    
    // transform each bounding box into hog feature space
    HogFeature *hogFeature;
    
    for(int i=0; i<[self.boundingBoxes count]; i++)
    {
        ConvolutionPoint *boundingBox = [self.boundingBoxes objectAtIndex:i];
        
        //get the image contained in the bounding box and resized it with the template size
        UIImage *wholeImage = [self.images objectAtIndex:boundingBox.imageIndex];
        UIImage *img = [wholeImage croppedImage:[boundingBox rectangleForImage:wholeImage]];
        UIImage *resizedImage = [img resizedImage:templateSize interpolationQuality:kCGInterpolationDefault];
        
        [self.imagesUsed addObject:resizedImage];
        
        //calculate the hogfeatures of the image
        hogFeature = [resizedImage obtainHogFeatures];
        if(i==0) self.imageFeatures = (double *) malloc([self.boundingBoxes count]*hogFeature.totalNumberOfFeatures*sizeof(double));
        
        //add the label
        self.labels[i] = (float) boundingBox.label;
        
        //add the hog features
        for(int j=0; j<hogFeature.totalNumberOfFeatures; j++)
            self.imageFeatures[i*hogFeature.totalNumberOfFeatures + j] = hogFeature.features[j];
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

//Sets the size of the template and obtain the dimension of the features from it.
- (void) obtainTemplateSize:(TrainingSet *) trainingSet;

// Add hog features from support vectors to the current hog features from bounding boxes
- (void) addSupportVectorsToTrainingSet:(TrainingSet *)trainingSet newLabels:(float *) labels;


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



- (void) printListHogFeatures:(float *) listOfHogFeaturesFloat
{
    //Print unoriented hog features for debugging purposes
    for(int y=0; y<7; y++)
    {
        for(int x=0; x<5; x++)
        {
            for(int f = 18; f<27; f++)
            {
                printf("%f ", listOfHogFeaturesFloat[y + x*7 + f*7*5]);
//                if(f==17 || f==26) printf("  |  ");
            }
            printf("\n");
        }
        printf("\n*************************************************************************\n");
    }
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
    
    // Set up SVM's parameters
    CvSVMParams params;
    params.svm_type    = CvSVM::C_SVC;
    params.kernel_type = CvSVM::LINEAR;
    params.term_crit   = cvTermCriteria(CV_TERMCRIT_ITER, 1000, 1e-6);
    
    
    //convergence loop
    int numIterations = 5;
    for (int i=0; i<numIterations; i++)
    {
        // Set up training data
        if(debugging)
        {
            NSLog(@"\n\n ************************ Iteration 1 ********************************");
            NSLog(@"Number of Training Examples: %d", trainingSet.numberOfTrainingExamples);
            
        }
        
        // cast the hog features to float
        float *listOfHogFeaturesFloat = (float *) malloc(numOfFeatures*trainingSet.numberOfTrainingExamples*sizeof(float));
        for(int i=0; i<numOfFeatures*trainingSet.numberOfTrainingExamples; i++)
            listOfHogFeaturesFloat[i] = (float) trainingSet.imageFeatures[i];
        
//        //print the positives
//        for(int i=0; i<trainingSet.numberOfTrainingExamples;i++)
//            if(trainingSet.labels[i]==1)
//            {
//                printf("\n\n POSITIVE EXAMPLE at position: %d \n\n", i);
//                [self printListHogFeatures:&listOfHogFeaturesFloat[i*7*5*31]];
//            }
        
        Mat labelsMat(trainingSet.numberOfTrainingExamples,1,CV_32FC1, trainingSet.labels);
        Mat trainingDataMat(trainingSet.numberOfTrainingExamples, numOfFeatures, CV_32FC1, listOfHogFeaturesFloat); 
        //std::cout << trainingDataMat << std::endl; //output learning matrix
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        //Train the SVM, update weights and store support vectors and labels
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
        CvSVM SVM;
        SVM.train(trainingDataMat, labelsMat, Mat(), Mat(), params);
        
        //update weights and store the support vectors
        self.numSupportVectors = SVM.get_support_vector_count();
        float *supportVectorLabels = (float *) malloc(self.numSupportVectors*sizeof(float));
        
        const CvSVMDecisionFunc *dec = SVM.decision_func;
        self.svmWeights = (double *) calloc((numOfFeatures+1),sizeof(double));
        self.supportVectors = (double *) malloc(numOfFeatures*self.numSupportVectors*sizeof(double));
        
        printf("Num of support vectors: %d\n", self.numSupportVectors);
        for (int i = 0; i < self.numSupportVectors; ++i)
        {
            float alpha = dec[0].alpha[i];
            const float *supportVector = SVM.get_support_vector(i);
            float *sv_aux = (float *) malloc(numOfFeatures*sizeof(float));
            for(int j=0;j<numOfFeatures;j++) //const float* to float*
                sv_aux[j] = supportVector[j];
            
            // Get the current label of the supportvector
            Mat supportVectorMat(numOfFeatures,1,CV_32FC1, sv_aux);
            supportVectorLabels[i] = SVM.predict(supportVectorMat);
            printf("label: %f   alpha: %f \n", supportVectorLabels[i], alpha);
            
            for(int j=0;j<numOfFeatures;j++)
            {
                // add to get the weights
                self.svmWeights[j] -= (double) alpha * supportVector[j];
                
                //store the support vector
                self.supportVectors[i*numOfFeatures +j] = (double) supportVector[j];
            }
        }
        self.svmWeights[numOfFeatures] = - (double) dec[0].rho; // The sign of the bias and rho have opposed signs.
        
        if(debugging)
        {
            NSLog(@"bias: %f", self.svmWeights[numOfFeatures]);
        }
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        //Update bounding boxes
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        //remove all current bounding boxes
        [trainingSet.boundingBoxes removeAllObjects];
        int positives = 0;
        
        for(int imageIndex=0; imageIndex <[trainingSet.images count]; imageIndex++)
        {
            // Get new bounding boxes by running the detector
            NSArray *newBoundingBoxes = [self detect:[trainingSet.images objectAtIndex:imageIndex] minimumThreshold:-1 pyramids:10 usingNms:NO];
            if(debugging) NSLog(@"Number of new bb obtained: %d", [newBoundingBoxes count]);
            
            //the rest that are less than an overlap threshold are considered negatives
            ConvolutionPoint *groundTruthBoundingBox = [trainingSet.groundTruthBoundingBoxes objectAtIndex:0];
            for(int j=0; j<[newBoundingBoxes count]; j++)
            {
                ConvolutionPoint *boundingBox = [newBoundingBoxes objectAtIndex:j];
                boundingBox.imageIndex = imageIndex;
                double overlapArea = [boundingBox fractionOfAreaOverlappingWith:groundTruthBoundingBox];
                
                if (overlapArea < 0.25)
                {
                    boundingBox.label = -1;
                    [trainingSet.boundingBoxes addObject:boundingBox];
                    
                }else if (overlapArea > 0.8){
                    boundingBox.label = 1;
                    positives ++;
                    [trainingSet.boundingBoxes addObject:boundingBox];
                }
                
            }
        }
        printf("added:%d positives\n", positives);
        printf("total of new bounding boxes: %d\n", [trainingSet.boundingBoxes count]);
        
        //generate the hog features for the new bounding boxes
        [trainingSet generateFeaturesForBoundingBoxesWithTemplateSize:templateSize];
        
        //Add the current support vectors to the new hog features generated
        [self addSupportVectorsToTrainingSet:trainingSet newLabels:supportVectorLabels];
        
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
    
    double sc = pow(2, 1.0/numberPyramids);
    
    // Maxsize for going faster
    // TODO: choose a reasonable max size for improve performance
    [candidateBoundingBoxes addObjectsFromArray:[ConvolutionHelper convTempFeat:[image scaleImageTo:300.0/480]
                                                                   withTemplate:templateWeights]];
    //Pyramid calculation
    for (int i = 1; i<numberPyramids; i++)
    {
        
        NSArray *result = [ConvolutionHelper convTempFeat:[image scaleImageTo:(300.0/480)*1/pow(sc, i)]
                                             withTemplate:templateWeights];
        
        [candidateBoundingBoxes addObjectsFromArray:result];
        
    }
    
    NSArray *nmsArray = candidateBoundingBoxes;
    if(useNms) nmsArray = [ConvolutionHelper nms:candidateBoundingBoxes maxOverlapArea:0.25 minScoreThreshold:detectionThreshold]; //19
    
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
    // BE CAREFUL!!! Intrinsic change of UIImage Orientation!! (from right to up)
    UIImage *img = [wholeImage croppedImage:[[trainingSet.boundingBoxes objectAtIndex:0] rectangleForImage:wholeImage]];
    UIImage *resizedImage = [img resizedImage:templateSize interpolationQuality:kCGInterpolationDefault];

    hogFeature = [resizedImage obtainHogFeatures];
    [hogFeature printFeaturesOnScreen];

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
    NSLog(@"w:%f, h:%f",wholeImage.size.width, wholeImage.size.height);
    NSLog(@"w:%f, h:%f",img.size.width, img.size.height);
    
    templateSize.height = img.size.height*0.6;
    templateSize.width = img.size.width*0.6;
    
    // And store dimension of hog features for it
    self.weightsDimensions = [[img resizedImage:templateSize interpolationQuality:kCGInterpolationDefault] obtainDimensionsOfHogFeatures];
    
    
}


- (void) addSupportVectorsToTrainingSet:(TrainingSet *) trainingSet newLabels:(float *)supportVectorLabels
{
    int numFeatures = self.weightsDimensions[0]*self.weightsDimensions[1]*self.weightsDimensions[2];
    int numTrainExamples = (self.numSupportVectors + [trainingSet.boundingBoxes count]); // add support vectors to the new bounding boxes
    
    double *totalFeatures = (double *) malloc(numTrainExamples*numFeatures*sizeof(double));
    float *totalLabels = (float *) malloc(numTrainExamples*sizeof(float));
    
    //copy support vectors features
    for(int i=0; i<self.numSupportVectors*numFeatures;i++)
        totalFeatures[i] = self.supportVectors[i];
    
    //copy bounding boxes features
    for(int i=0; i<[trainingSet.boundingBoxes count]*numFeatures; i++)
        totalFeatures[self.numSupportVectors*numFeatures + i] = trainingSet.imageFeatures[i];
    
    //return vector of features to the TrainingSet object
    trainingSet.imageFeatures = (double *) malloc(numTrainExamples*numFeatures*sizeof(double));
    for(int i=0; i<numTrainExamples*numFeatures; i++)
        trainingSet.imageFeatures[i] = totalFeatures[i];
    
    //coppy support vector labels
    for(int i=0; i<self.numSupportVectors; i++)
        totalLabels[i] = supportVectorLabels[i];
    
    //copy bounding boxes labels
    for(int i=0;i<[trainingSet.boundingBoxes count]; i++)
        totalLabels[self.numSupportVectors + i] = trainingSet.labels[i];
    
    //return vector of labels to the TrainingSet object
    trainingSet.labels = (float *) malloc(numTrainExamples*sizeof(float));
    for(int i=0; i<numTrainExamples; i++)
        trainingSet.labels[i] = totalLabels[i];
    
    
    trainingSet.numberOfTrainingExamples = numTrainExamples;
}


@end
