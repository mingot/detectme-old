//
//  ConvolutionHelper.m
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 07/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//

#include <Accelerate/Accelerate.h>

#import "ConvolutionHelper.h"
#import "ImageProcessingHelper.h"
#import "UIImage+HOG.h"


static inline double min(double x, double y) { return (x <= y ? x : y); }
static inline double max(double x, double y) { return (x <= y ? y : x); }
static inline int min_int(int x, int y) { return (x <= y ? x : y); }
static inline int max_int(int x, int y) { return (x <= y ? y : x); }


@implementation ConvolutionPoint

@synthesize score = _score;
@synthesize ymin = _ymin;
@synthesize ymax = _ymax;
@synthesize xmin = _xmin;
@synthesize xmax = _xmax;

@synthesize label = _label;
@synthesize imageIndex = _imageIndex;
@synthesize rectangle = _rectangle;

-(id) initWithRect:(CGRect)initialRect label:(int)label imageIndex:(int)imageIndex;
{
    if(self = [self init])
    {
        self.label = label;
        self.imageIndex = imageIndex;
        self.xmin = initialRect.origin.x;
        self.xmax = initialRect.origin.x + initialRect.size.width;
        self.ymin = initialRect.origin.y;
        self.ymax = initialRect.origin.y + initialRect.size.height;
    }
    return self;
}


- (CGRect) rectangle
{
    return CGRectMake(self.xmin, self.ymin, self.xmax - self.xmin, self.ymax - self.ymin);
}

- (CGRect) rectangleForImage:(UIImage *)image
{
    return CGRectMake(self.xmin*image.size.width, self.ymin*image.size.height, (self.xmax - self.xmin)*image.size.width, (self.ymax - self.ymin)*image.size.height);
}


- (void) setRectangle:(CGRect)rectangle
{
    _rectangle = rectangle;
}

- (double) fractionOfAreaOverlappingWith:(ConvolutionPoint *) cp
{
    double area1, area2, unionArea, intersectionArea;
    
    area1 = (self.xmax - self.xmin)*(self.ymax - self.ymin);
    area2 = (cp.xmax - cp.xmin)*(cp.ymax - cp.ymin);
    
    intersectionArea = (min(self.xmax, cp.xmax) - max(self.xmin, cp.xmin))*(min(self.ymax, cp.ymax) - max(self.ymin, cp.ymin));
    unionArea = area1 + area2 - intersectionArea;
    
    return intersectionArea/unionArea>0 ? intersectionArea/unionArea : 0;
}


@end



@implementation ConvolutionHelper


+ (void) convolution:(double *)result matrixA:(double *)matrixA :(int *)sizeA matrixB:(double *)matrixB :(int *)sizeB
{
    int convolutionSize[2];
    convolutionSize[0] = sizeA[0] - sizeB[0] + 1; 
    convolutionSize[1] = sizeA[1] - sizeB[1] + 1;
    
    for (int x = 0; x < convolutionSize[1]; x++) {
        for (int y = 0; y < convolutionSize[0]; y++)
        {
            double val = 0;
            
            for(int xp=0;xp<sizeB[1];xp++){ //Assuming column-major representation
                double *A_off = matrixA + (x+xp)*sizeA[0] + y;
                double *B_off = matrixB + xp*sizeB[0];
                switch(sizeB[0]) { //depending on the template size sizeB[0]. Use this hack to avoid an additional loop in common cases.
                    case 20: val += A_off[19] * B_off[19];
                    case 19: val += A_off[18] * B_off[18];
                    case 18: val += A_off[17] * B_off[17];
                    case 17: val += A_off[16] * B_off[16];
                    case 16: val += A_off[15] * B_off[15];
                    case 15: val += A_off[14] * B_off[14];
                    case 14: val += A_off[13] * B_off[13];
                    case 13: val += A_off[12] * B_off[12];
                    case 12: val += A_off[11] * B_off[11];
                    case 11: val += A_off[10] * B_off[10];
                    case 10: val += A_off[9]  * B_off[9];
                    case 9:  val += A_off[8]  * B_off[8];
                    case 8:  val += A_off[7]  * B_off[7];
                    case 7:  val += A_off[6]  * B_off[6];
                    case 6:  val += A_off[5]  * B_off[5];
                    case 5:  val += A_off[4]  * B_off[4];
                    case 4:  val += A_off[3]  * B_off[3];
                    case 3:  val += A_off[2]  * B_off[2];
                    case 2:  val += A_off[1]  * B_off[1];
                    case 1:  val += A_off[0]  * B_off[0];
                        break;
                    default:
                        for (int yp = 0; yp < sizeB[0]; yp++) {
                            val += *(A_off++) * *(B_off++);
                        }
                }
            }
            *(result++) += val;
            
        }
    }
}

+ (void) convolutionWithVDSP:(double *)result matrixA:(double *)matrixA :(int *)sizeA matrixB:(double *)matrixB :(int *)sizeB
{
    // Convolution making use of the vDSP library
    // Conversion from row-major to column-major matrix
    double *matrixAModif = calloc(sizeA[0]*sizeA[1], sizeof(double));
    double *matrixBModif = calloc(sizeB[0]*sizeB[1], sizeof(double));
    
    int r=0;
    for(int j=0; j<sizeA[1]; j++)
        for(int i=0;i<sizeA[0];i++){
            *(matrixAModif + j + i*sizeA[1]) = *(matrixA + r);
            r++;
        }
    
    r=0;
    for(int j=0; j<sizeB[1]; j++)
        for(int i=0;i<sizeB[0];i++){
            *(matrixBModif + j + i*sizeB[1]) = *(matrixB + r);
            r++;
        }

    
    //Convolution of the size of the imageA
    double *result_aux = calloc(sizeA[0]*sizeA[1], sizeof(double));
    vDSP_imgfirD(matrixAModif, (vDSP_Length)sizeA[0], (vDSP_Length)sizeA[1], matrixBModif, result_aux, (vDSP_Length)sizeB[0], (vDSP_Length)sizeB[1]);
    
    
    //Copy just the non null values to the result (of size convolutionSize).
    for(int i=0; i<sizeA[0]*sizeA[1];i++)
        if(*(result_aux+i)!=0){
            *result += *(result_aux+i);
            result++;
        }
}

+ (void) convolutionWithVImage:(double *)result matrixA:(double *)matrixA :(int *)sizeA matrixB:(double *)matrixB :(int *)sizeB
{
    // Convolution using the implemented features of vImage
    vImage_Buffer src;
    src.data = matrixA;
    src.height = sizeA[0];
    src.width = sizeA[1];
    src.rowBytes = sizeA[1]*sizeof(float);
    
    vImage_Buffer dst;
    dst.data = result;
    dst.height = sizeA[0];
    dst.width = sizeA[1];
    dst.rowBytes = sizeA[1]*sizeof(float);
    
    //TODO: Fix the fact that can not deal with doubles
//    vImageConvolve_PlanarF(&src, &dst, NULL, 0, 0, matrixB, sizeB[0], sizeB[1],(Pixel_F)0, kvImageCopyInPlace);
    
//    result = dst.data;
//    for(int i=0;i<sizeA[0]*sizeA[1];i++)
//        NSLog(@"result: %f", *(result + i));
}

+ (void) convolutionWithFFT:(double *)result matrixA:(double *)matrixA :(int *)sizeA matrixB:(double *)matrixB :(int *)sizeB
{
    
    //TODO: finish the implementation of the convolution with the FFT
    //FFT of the two signals
    DSPSplitComplex signalImageIn;
    signalImageIn.realp = calloc(sizeA[0]*sizeA[1],sizeof(float));
    
    for(int i=0;i<sizeA[0];i++)
        for(int j=0;j<sizeA[1];j++)
            *(signalImageIn.realp + i*sizeA[1] + j) = (float) *(matrixA + i*sizeA[1] + j);
    
    signalImageIn.imagp = calloc(sizeA[0]*sizeA[1],sizeof(float)); // initialize to 0
    
    
    DSPSplitComplex signalFourierOut;
    signalFourierOut.realp = calloc(sizeA[0]*sizeA[1],sizeof(float) );
    signalFourierOut.imagp = calloc(sizeA[0]*sizeA[1],sizeof(float) );
    
    vDSP_fft2d_zrop(vDSP_create_fftsetup(8, kFFTRadix2), &signalImageIn, 1, 1, &signalFourierOut, 1, 1, 8, 8, kFFTDirection_Forward);
    
    
    DSPSplitComplex templateImageIn;
    templateImageIn.realp = (float *) matrixB;
    templateImageIn.imagp = calloc(sizeB[0]*sizeB[1], sizeof(float));
    
    DSPSplitComplex templateFourierOut;
    templateFourierOut.realp = calloc(sizeB[0]*sizeB[1],sizeof(float) );
    templateFourierOut.imagp = calloc(sizeB[0]*sizeB[1],sizeof(float) );
    
    
//    vDSP_fft2d_zrop(vDSP_create_fftsetup(8, kFFTRadix2), &templateImageIn, 1, 1, &templateFourierOut, 1, 1, 8, 8, kFFTDirection_Forward);
    
    NSLog(@"Real");
    float *c = signalFourierOut.realp;
    for(int i = 0;i<sizeA[0];i++)
        for(int j = 0; j < sizeA[1]; j++)
            NSLog(@"%f", *(c+i*sizeA[1]+j));
    
    
    //Multiplication of the signals (what kind of multiplication? point to point)
    
    //FFT-1 of the signals
    
}


+ (NSArray *)convTempFeat:(CGImageRef)image
             withTemplate:(double *)templateValues
              orientation:(int)orientation

{
    int templateSize[3]; //template sizes
    templateSize[0] = (int)(*templateValues);
    templateSize[1] = (int)(*(templateValues+1));
    templateSize[2] = (int)(*(templateValues+2));
    
    double *w = templateValues + 3; //template weights
    double b = templateValues[3 + templateSize[0]*templateSize[1]*templateSize[2]]; //template bias parameter
    
    HogFeature *hogFeature = [[UIImage imageWithCGImage:image scale:1.0 orientation:orientation] obtainHogFeaturesReturningHog];
    int blocks[2] = {hogFeature.numBlocksX, hogFeature.numBlocksY};
    
    int convolutionSize[2];
    convolutionSize[0] = blocks[0] - templateSize[0] + 1; //convolution size
    convolutionSize[1] = blocks[1] - templateSize[1] + 1;
    if ((convolutionSize[0]<=0) || (convolutionSize[1]<=0))
        return NULL;
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:convolutionSize[0]*convolutionSize[1]];
    double *c = calloc(convolutionSize[0]*convolutionSize[1],sizeof(double)); //initialize the convolution result
    
    NSLog(@"blocsk: %d, %d", blocks[0], blocks[1]);
    
    
    // Make the convolution for each feature.
    for (int f = 0; f < templateSize[2]; f++)
    {
        double *dst = c;
        double *A_src = hogFeature.features + f*blocks[0]*blocks[1]; //Select the block of features to do the convolution with
        double *B_src = w + f*templateSize[0]*templateSize[1];
        
        // convolute and add the results to dst
        [ConvolutionHelper convolution:dst matrixA:A_src :blocks matrixB:B_src :templateSize];
        
//        [ConvolutionHelper convolutionWithVDSP:dst matrixA:A_src :blocks matrixB:B_src :templateSize];
//        [ConvolutionHelper convolutionWithFFT:dst matrixA:A_src :blocks matrixB:B_src :templateSize];

    }
    
    //Once done the convolution, detect if something is the object!
    for (int x = 0; x < convolutionSize[1]; x++) {
        for (int y = 0; y < convolutionSize[0]; y++) {
            
            ConvolutionPoint *p = [[ConvolutionPoint alloc] init];
            p.score = (*(c + x*convolutionSize[0] + y) - b);
            if( p.score > -1 )
            {
                p.xmin = (double)(x + 1)/((double)blocks[1] + 2);
                p.xmax = (double)(x + 1)/((double)blocks[1] + 2) + ((double)templateSize[1]/((double)blocks[1] + 2));
                p.ymin = (double)(y + 2)/((double)blocks[0] + 2);
                p.ymax = (double)(y + 2)/((double)blocks[0] + 2) + ((double)templateSize[0]/((double)blocks[0] + 2));

                [result addObject:p];
            }
        }
    }
    
    free(c);
    
    return result;
}


+ (NSArray *) convPyraFeat:(UIImage *)image //Convolution using pyramid
              withTemplate:(double *)templateValues
                  pyramids:(int ) numberPyramids
            scoreThreshold:(double)scoreThreshold
{
    NSMutableArray *result = [[NSMutableArray alloc] init];

    // TODO: choose max size for the image
    // int maxsize = (int) (max(image.size.width,image.size.height));
    // Pongo de tamaño maximo 300 por poner algo --> poderlo escoger.
    int maxsize = 300;
    
    CGImageRef resizedImage = [ImageProcessingHelper resizeImage:image.CGImage withRect:maxsize];
    double sc = pow(2, 1.0/numberPyramids);
    
    //int *max = malloc(2*nm*interval*sizeof(int));
    //double *scores = malloc(sizeof(double)*nm*interval);
    
//    clock_t start = clock(); //Trace execution time
    
    [result addObjectsFromArray:[self convTempFeat:resizedImage withTemplate:templateValues orientation:image.imageOrientation]];
    
    for (int i = 1; i<numberPyramids; i++) { //Pyramid calculation
        
        CGImageRef scaledImage = [ImageProcessingHelper scaleImage:resizedImage scale:1/pow(sc, i)];
        [result addObjectsFromArray:
            [self convTempFeat:scaledImage                              
                  withTemplate:templateValues
                   orientation:image.imageOrientation]];

        CGImageRelease(scaledImage);
    }
    
    NSArray *nmsArray = [self nms:result maxOverlapArea:0.25 minScoreThreshold:scoreThreshold];
    
    return nmsArray;
}


+ (NSArray *) nms:(NSArray *)convolutionPointsCandidates
   maxOverlapArea:(double)overlap
minScoreThreshold:(double)scoreThreshold
{
    
    // Sort the convolution points by its score descending
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [convolutionPointsCandidates sortedArrayUsingDescriptors:sortDescriptors];
    if (sortedArray.count <= 0)
        return nil;

    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    // select only those bounding boxes with score above the threshold and non overlapping areas
    for (int i = 0; i<sortedArray.count; i++)
    {
        BOOL selected = YES;
        ConvolutionPoint *point = [sortedArray objectAtIndex:i];
    
        if (point.score < scoreThreshold)
            break;
        
        for (int j = 0; j<result.count; j++)
            if ([[result objectAtIndex:j] fractionOfAreaOverlappingWith:point] > overlap)
            {
                selected = NO;
                break;
            }
        
        if (selected) [result addObject:point];
    }
    
    return result;
}


@end
