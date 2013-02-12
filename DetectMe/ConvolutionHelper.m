//
//  ConvolutionHelper.m
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 07/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//

#import "ConvolutionHelper.h"
#import "ImageProcessingHelper.h"


@implementation ConvolutionPoint

@synthesize score = _score;
@synthesize ymin = _ymin;
@synthesize ymax = _ymax;
@synthesize xmin = _xmin;
@synthesize xmax = _xmax;

@end




@implementation ConvolutionHelper

static inline double min(double x, double y) { return (x <= y ? x : y); }
static inline double max(double x, double y) { return (x <= y ? y : x); }
static inline int min_int(int x, int y) { return (x <= y ? x : y); }
static inline int max_int(int x, int y) { return (x <= y ? y : x); }

+ (NSArray *)convTempFeat:(CGImageRef)image 
             withTemplate:(double *)templateValues
              orientation:(int)orientation 
           withHogFeature:(HOGFeature *)hogFeature

{
    int templateSize[3]; //template sizes
    templateSize[0] = (int)(*templateValues);
    templateSize[1] = (int)(*(templateValues+1));
    templateSize[2] = (int)(*(templateValues+2));
    
    double *w = templateValues + 3; //template weights
    double b = *(templateValues + 3 + templateSize[0]*templateSize[1]*templateSize[2]); //template b parameter
    
    int blocks[3]; //number of cells of the hog descriptor of the image (image hog size)
    double *feat = NULL; //initialization of the pointer to the features
    feat = [hogFeature HOGOrientationWithDimension:blocks forImage:image withPhoneOrientation:orientation];
    
    int convolutionSize[2];
    convolutionSize[0] = blocks[0] - templateSize[0] + 1; //convolution size
    convolutionSize[1] = blocks[1] - templateSize[1] + 1;
    if ((convolutionSize[0]<=0) || (convolutionSize[1]<=0)) { //discard if convolution size not positive
        return NULL;
    }
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:convolutionSize[0]*convolutionSize[1]];
    
    double *c = calloc(convolutionSize[0]*convolutionSize[1],sizeof(double)); //initialize the convolution result
    
    
    for (int f = 0; f < templateSize[2]; f++)
    {
        double *dst = c;
        double *A_src = feat + f*blocks[0]*blocks[1]; //Select the block of features to do the convolution with
        double *B_src = w + f*templateSize[0]*templateSize[1];
        
        for (int x = 0; x < convolutionSize[1]; x++) {          //iterating throught the convolution result
            for (int y = 0; y < convolutionSize[0]; y++)
            {
                double val = 0;
                for (int xp = 0; xp < templateSize[1]; xp++) {
                    double *A_off = A_src + (x+xp)*blocks[0] + y;
                    double *B_off = B_src + xp*templateSize[0];
                    switch(templateSize[0]) { //depending on the template size r[0]. Use this hack to avoid an additional loop in common cases
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
                            for (int yp = 0; yp < templateSize[0]; yp++) {
                                val += *(A_off++) * *(B_off++);
                                NSLog(@"%d: A: %f; B: %f; val: %f",yp,*(A_off), *B_off, val);
                            }
                    }
                }
                *(dst++) += val;
                
            }//it through conv size
        }
    }
    
    //Once done the convolution, detect if something is the object!
    for (int x = 0; x < convolutionSize[1]; x++) {
        for (int y = 0; y < convolutionSize[0]; y++) {
            
            ConvolutionPoint *p = [[ConvolutionPoint alloc]init];
            p.score = [NSNumber numberWithDouble:(*(c + x*convolutionSize[0] + y) - b)];
//            NSLog(@"%f", p.score.doubleValue);
            if( ((p.score.doubleValue) < -1)) {
                continue;
            }
            p.xmin = [NSNumber numberWithDouble:(double)(x+2)/((double)blocks[1]+2)];
            p.xmax = [NSNumber numberWithDouble:(double)(x+2)/((double)blocks[1]+2) + ((double)templateSize[1]/((double)blocks[1]+2))];
            p.ymin = [NSNumber numberWithDouble:(double)(y+2)/((double)blocks[0]+2)];
            p.ymax = [NSNumber numberWithDouble:(double)(y+2)/((double)blocks[0]+2) + ((double)templateSize[0]/((double)blocks[0]+2))];

            [result addObject:p];
        }
    }
    
//    NSLog(@"convolution result size: %d", [result count]);
    
    free(feat);
    free(c);
    return result;
}


+ (NSArray *) convPyraFeat:(UIImage *)image //Convolution using pyramid
              withTemplate:(double *)templateValues
              inDetectView:(DetectView *)detectView
            withHogFeature:(HOGFeature *)hogFeature
                  pyramids:(int ) numberPyramids


{
    NSMutableArray *result = [[NSMutableArray alloc] init];

//    double numberPyramids = 10; //Number of layers for the pyramid detection
    

    // TODO: choose max size for the image
    // int maxsize = (int) (max(image.size.width,image.size.height));
    // Pongo de tamaño maximo 300 por poner algo --> poderlo escoger.
    int maxsize = 300;
    
    CGImageRef resizedImage = [ImageProcessingHelper resizeImage:image.CGImage withRect:maxsize];
    double sc = pow(2, 1.0/numberPyramids);
    
    
    NSLog(@"%d, %d, %d", (int)(*templateValues), (int)(*(templateValues+1)), (int)(*(templateValues+2)));
    
    //int *max = malloc(2*nm*interval*sizeof(int));
    //double *scores = malloc(sizeof(double)*nm*interval);
    
    [result addObjectsFromArray:[self convTempFeat:resizedImage withTemplate:templateValues orientation:image.imageOrientation withHogFeature:hogFeature]];
    
    for (int i = 1; i<numberPyramids; i++) { //Pyramid calculation
        
        CGImageRef scaledImage = [ImageProcessingHelper scaleImage:resizedImage scale:1/pow(sc, i)];
        [result addObjectsFromArray:
            [self convTempFeat:scaledImage                              
                  withTemplate:templateValues
                   orientation:image.imageOrientation
                withHogFeature:hogFeature]];

        CGImageRelease(scaledImage);
    }
    
    NSLog(@"number of convolution ponints: %d", [result count]);
    
    NSArray *nmsArray = [self nms:result :0.25];
    
    NSLog(@"number of convolution points after nms: %d",nmsArray.count);
    
    [detectView setCorners:nmsArray];
    
    // View in the same window
    if (nmsArray.count > 0) {
        ConvolutionPoint *score = [nmsArray objectAtIndex:0];
//        [self performSelectorOnMainThread:@selector(setTitle:) withObject:[NSString stringWithFormat:@"%3f",score.score.doubleValue] waitUntilDone:YES];
        NSLog(@"Detected with socre: %3f",score.score.doubleValue);
    }
    else{
//        [self performSelectorOnMainThread:@selector(setTitle:) withObject:@"No detection." waitUntilDone:YES];
        NSLog(@"No detection");
    }
    
    return nmsArray;
}


+ (NSArray *) convPyraFeatFromFile:(UIImage *)image
                     withTemplate:(double *)templateValues
                      withMaxSize:(int)maxSize
                withHogFeature:(HOGFeature *)hogFeature
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    double interval = 10;

    int r[3];
    r[0]=(int)(*templateValues);
    r[1]=(int)(*(templateValues+1));
    r[2]=(int)(*(templateValues+2));

    CGImageRef resizedImage = [ImageProcessingHelper resizeImage:image.CGImage withRect:230];
    double sc = pow(2, 1/interval);
    // NSLog(@"resizedImage %zd x %zd",CGImageGetWidth(resizedImage),CGImageGetHeight(resizedImage));

    
    [result addObjectsFromArray:[self convTempFeat:resizedImage withTemplate:templateValues orientation:image.imageOrientation withHogFeature:hogFeature]];
    
    
    for (int i = 1; i<interval; i++) {
        CGImageRef scaledImage = [ImageProcessingHelper scaleImage:resizedImage scale:1/pow(sc, i)];
        
        [result addObjectsFromArray:[self convTempFeat:scaledImage withTemplate:templateValues orientation:image.imageOrientation withHogFeature:hogFeature]];
        
        CGImageRelease(scaledImage);
        
    }
    NSLog(@"result count: %d",result.count);
    NSArray *nmsArray = [self nms:result :0.25];
    
    /* if (nmsArray.count > 0) {
     ConvolutionPoint *score = [nmsArray objectAtIndex:0];
     [self performSelectorOnMainThread:@selector(setTitle:) withObject:[NSString stringWithFormat:@"%3f",score.score.doubleValue] waitUntilDone:YES];
     
     }
     else{
     [self performSelectorOnMainThread:@selector(setTitle:) withObject:@"No detection." waitUntilDone:YES];
     
     }*/
    
    free(templateValues);
    return nmsArray;
}


+ (NSArray *)nms:(NSArray *)c
               :(double) overlap
{


    double area1;
    double area2;
    double unionArea;
    double intersectionArea;
    double ov;
    //double *sorted = [self sortHightoLow:c :size :&numbral];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [c sortedArrayUsingDescriptors:sortDescriptors];
    if (sortedArray.count <= 0) {
        return nil;
    }
    NSMutableArray *result = [[NSMutableArray alloc] initWithObjects:[sortedArray objectAtIndex:0], nil ];
    
    for (int i = 1; i<sortedArray.count; i++) {
        BOOL ok = YES;
        ConvolutionPoint *point2 = [sortedArray objectAtIndex:i];
        
        for (int j = 0; j<result.count; j++) {
            ConvolutionPoint *point1 = [result objectAtIndex:j];
            area1 = ([point1.xmax doubleValue] - [point1.xmin doubleValue]) * ([point1.ymax doubleValue] - [point1.ymin doubleValue]);
            area2 = ([point2.xmax doubleValue] - [point2.xmin doubleValue]) * ([point2.ymax doubleValue] - [point2.ymin doubleValue]);
            intersectionArea = ( min([point1.xmax doubleValue], [point2.xmax doubleValue]) - max([point1.xmin doubleValue], [point2.xmin doubleValue])) * (min([point1.ymax doubleValue], [point2.ymax doubleValue]) - max([point1.ymin doubleValue], [point2.ymin doubleValue]));
            unionArea = area1 + area2 - intersectionArea;
            ov =  intersectionArea/ unionArea;
            if (ov > overlap) {
                ok = NO;
                break;
            }
        }
        if (ok) {
            [result addObject:point2];
        }
        
    }
    return result;
}



-(double *)sortHightoLow:(double *)c
                        :(int) size
                        :(int *) num
{
    
    //TODO: (Dolores) todos los valores que he visto dan negativos, el mayor que he visto ha sido -0.09
    double max = 1000000;
    double maxant;
    int index;
    //*num = 0;
    int total = 0;
    double *result = malloc(size*5*sizeof(double));
    for (int i=0; i<size; i++){  // quizas utilizar un while en lugar de un for + if -> break (te ahorras el incremento cada vez pq el acceso a memoria lo haces igual)
        maxant = max;
        max=-1000000;
        for (int j=0;j<size; j++) {
            if (*(c+j*5)<=maxant) {
                if (*(c+j*5)>max) {
                    max = *(c+j*5); // quizas guardando el indice ya basta
                    index =j;
                }
            }
            
            
        }
        if (max < 0) { // el umbral
            break;
        }
        *(result + total*5   ) = *(c + index*5   );
        *(result + total*5 +1) = *(c + index*5 +1);
        *(result + total*5 +2) = *(c + index*5 +2);
        *(result + total*5 +3) = *(c + index*5 +3);
        *(result + total*5 +4) = *(c + index*5 +4);
        *(c + index*5)       = -10000;  // para que no vuelva a pasar y pueda coger otro valor que pueda ser igual
        total++;
        
        
    }
    *num = total;
    return result;
}

@end
