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
#define MAX_BUFFER_SIZE 300000000 //300MB as the maximum buffersize


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


- (void) generateFeaturesForBoundingBoxesWithTemplateSize:(CGSize)templateSize withNumSV:(int)numSV
{
    // transform each bounding box into hog feature space
    int i;
    for(i=0; i<[self.boundingBoxes count]; i++)
    {
        @autoreleasepool
        {
            ConvolutionPoint *boundingBox = [self.boundingBoxes objectAtIndex:i];
            
            //get the image contained in the bounding box and resized it with the template size
            UIImage *wholeImage = [self.images objectAtIndex:boundingBox.imageIndex];
            UIImage *resizedImage = [[wholeImage croppedImage:[boundingBox rectangleForImage:wholeImage]] resizedImage:templateSize interpolationQuality:kCGInterpolationDefault]; //
            
            //calculate the hogfeatures of the image
            HogFeature *hogFeature = [resizedImage obtainHogFeatures];
            
            //check if it has enough space to allocate it
            if((i+1+numSV)*hogFeature.totalNumberOfFeatures > MAX_BUFFER_SIZE)
            {
                NSLog(@"BUFFER FULL!!");
                break;
            }
            
            //add the label
            self.labels[numSV + i] = (float) boundingBox.label;
            
            //add the hog features
            for(int j=0; j<hogFeature.totalNumberOfFeatures; j++)
                self.imageFeatures[(numSV + i)*hogFeature.totalNumberOfFeatures + j] = (float) hogFeature.features[j];
        }

    }
    self.numberOfTrainingExamples = numSV + i;
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

//Sets the size of the template and obtain the dimension of the features from it.
- (void) obtainTemplateSize:(TrainingSet *) trainingSet;


- (void) showOrientationHistogram;

@end



@implementation Classifier


@synthesize svmWeights = _svmWeights;
@synthesize weightsDimensions = _weightsDimensions;



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

- (void) showOrientationHistogram
{
    double *histogram = (double *) calloc(18,sizeof(double));
    for(int x = 0; x<self.weightsDimensions[1]; x++)
        for(int y=0; y<self.weightsDimensions[0]; y++)
            for(int f=18; f<27; f++)
                histogram[f-18] += self.svmWeights[y + x*self.weightsDimensions[0] + f*self.weightsDimensions[0]*self.weightsDimensions[1]];
    
    printf("Orientation Histogram\n");
    for(int i=0; i<9; i++)
        printf("%f ", histogram[i]);
    printf("\n");
    
    free(histogram);
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
    trainingSet.imageFeatures = (float *) malloc(MAX_BUFFER_SIZE);
    trainingSet.labels = (float *) malloc(3000*sizeof(float));
    [trainingSet generateFeaturesForBoundingBoxesWithTemplateSize: templateSize withNumSV:0];
    
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
            NSLog(@"\n\n ************************ Iteration %d ********************************", i);
            NSLog(@"Number of Training Examples: %d", trainingSet.numberOfTrainingExamples);
            
        }
        
        
//        //print the positives
//        for(int i=0; i<trainingSet.numberOfTrainingExamples;i++)
//            if(trainingSet.labels[i]==1)
//            {
//                printf("\n\n POSITIVE EXAMPLE at position: %d \n\n", i);
//                [self printListHogFeatures:&listOfHogFeaturesFloat[i*7*5*31]];
//            }
        
        Mat labelsMat(trainingSet.numberOfTrainingExamples,1,CV_32FC1, trainingSet.labels);
        Mat trainingDataMat(trainingSet.numberOfTrainingExamples, numOfFeatures, CV_32FC1, trainingSet.imageFeatures);
        //std::cout << trainingDataMat << std::endl; //output learning matrix
        
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
        //Train the SVM, update weights and store support vectors and labels
        //////////////////////////////////////////////////////////////////////////////////////////////////////////
    
        CvSVM SVM;
        SVM.train(trainingDataMat, labelsMat, Mat(), Mat(), params);
        
        //update weights and store the support vectors
        int numSupportVectors = SVM.get_support_vector_count();
        
        const CvSVMDecisionFunc *dec = SVM.decision_func;
        self.svmWeights = (double *) calloc((numOfFeatures+1),sizeof(double)); //TODO: not to be allocated in every iteration
        
        printf("Num of support vectors: %d\n", numSupportVectors);
        for (int i = 0; i < numSupportVectors; ++i)
        {
            float alpha = dec[0].alpha[i];
            const float *supportVector = SVM.get_support_vector(i);
            float *sv_aux = (float *) malloc(numOfFeatures*sizeof(float));
            for(int j=0;j<numOfFeatures;j++) //const float* to float*
                sv_aux[j] = supportVector[j];
            
            // Get the current label of the supportvector
            Mat supportVectorMat(numOfFeatures,1,CV_32FC1, sv_aux);
            trainingSet.labels[i] = SVM.predict(supportVectorMat);
            printf("label: %f   alpha: %f \n", trainingSet.labels[i], alpha);
            
            for(int j=0;j<numOfFeatures;j++)
            {
                // add to get the weights
                self.svmWeights[j] -= (double) alpha * supportVector[j];
                
                //store the support vector as the first features
                trainingSet.imageFeatures[i*numOfFeatures +j] = supportVector[j];
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
            NSArray *newBoundingBoxes = [self detect:[trainingSet.images objectAtIndex:imageIndex] minimumThreshold:-1 pyramids:10 usingNms:NO deviceOrientation:UIImageOrientationUp];
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
        [trainingSet generateFeaturesForBoundingBoxesWithTemplateSize:templateSize withNumSV:numSupportVectors];
        
        [self showOrientationHistogram];
        
    }
}


- (NSArray *) detect:(UIImage *)image
    minimumThreshold:(double) detectionThreshold
            pyramids:(int)numberPyramids
            usingNms:(BOOL)useNms
   deviceOrientation:(int)orientation
{
    int totalFeatures = self.weightsDimensions[0]*self.weightsDimensions[1]*self.weightsDimensions[2];
    double *templateWeights = (double *) calloc((3 + totalFeatures + 1),sizeof(double));
    templateWeights[0] = self.weightsDimensions[0];
    templateWeights[1] = self.weightsDimensions[1];
    templateWeights[2] = self.weightsDimensions[2];
    
    for(int i=0; i<totalFeatures + 1; i++) //+1 for the bias term
        templateWeights[3+i] = self.svmWeights[i];
    
    NSMutableArray *candidateBoundingBoxes = [[NSMutableArray alloc] init];
    
    double scale = pow(2, 1.0/numberPyramids);
    
    //rotate image depending on the orientation
    if(UIDeviceOrientationIsLandscape(orientation)){
        image = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation: UIImageOrientationUp];
    }
    
    // Maxsize for going faster
    // TODO: choose a reasonable max size for improve performance
    [candidateBoundingBoxes addObjectsFromArray:[ConvolutionHelper convTempFeat:[image scaleImageTo:300.0/480]
                                                                   withTemplate:templateWeights]];
    //Pyramid calculation
    for (int i = 1; i<numberPyramids; i++)
    {
        
        NSArray *result = [ConvolutionHelper convTempFeat:[image scaleImageTo:(300.0/480)*1/pow(scale, i)]
                                             withTemplate:templateWeights];
        
        [candidateBoundingBoxes addObjectsFromArray:result];
        
    }
    
    NSArray *nmsArray = candidateBoundingBoxes;
    if(useNms) nmsArray = [ConvolutionHelper nms:candidateBoundingBoxes maxOverlapArea:0.25 minScoreThreshold:detectionThreshold]; //19
    
    // Change the resulting orientation of the bounding boxes if the phone orientation requires it
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        for(int i=0; i<nmsArray.count; i++)
        {
            ConvolutionPoint *boundingBox = [nmsArray objectAtIndex:i];
            double auxXmin, auxXmax;
            auxXmin = boundingBox.xmin;
            auxXmax = boundingBox.xmax;
            boundingBox.xmin = (1 - boundingBox.ymin);//*504.0/320;
            boundingBox.xmax = (1 - boundingBox.ymax);//*504.0/320;
            boundingBox.ymin = auxXmin;//*320.0/504;
            boundingBox.ymax = auxXmax;//*320.0/504;
        }
    }
    
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
    
    templateSize.height = img.size.height*0.6; //0.6
    templateSize.width = img.size.width*0.6;
    
    // And store dimension of hog features for it
    self.weightsDimensions = [[img resizedImage:templateSize interpolationQuality:kCGInterpolationDefault] obtainDimensionsOfHogFeatures];
    
    
}



@end
