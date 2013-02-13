//
//  HOGFeature.m
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 07/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//

#import "HOGFeature.h"
#define PI 3.14159265
#define eps 0.00001

double uu[9] = {1.0000, //non oriented HOG representants, sweeping from (1,0) to (-1,0).
    0.9397,
    0.7660,
    0.500,
    0.1736,
    -0.1736,
    -0.5000,
    -0.7660,
    -0.9397};
double vv[9] = {0.0000,
    0.3420,
    0.6428,
    0.8660,
    0.9848,
    0.9848,
    0.8660,
    0.6428,
    0.3420};

static inline double min(double x, double y) { return (x <= y ? x : y); }
static inline double max(double x, double y) { return (x <= y ? y : x); }

static inline int min_int(int x, int y) { return (x <= y ? x : y); }
static inline int max_int(int x, int y) { return (x <= y ? y : x); }


@implementation HOGFeature

- (id) initWithNumberCells:(int) aSbin
{
    self = [super init];
    if (self){
        sbin = aSbin;
    }
    
    return self;
}


-(double *)HOGOrientationWithDimension:(int *)hogSize
                              forImage:(CGImageRef)imageRef
                  withPhoneOrientation:(int)orientation
{
    
    // Get the image in bits: Create a context and draw the image there to get the image in bits
    NSUInteger width = CGImageGetWidth(imageRef); //#pixels width
    NSUInteger height = CGImageGetHeight(imageRef); //#pixels height
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * width;
    int bitsPerComponent = 8;
    UInt8 *pixels = (UInt8 *)malloc(height * width * 4);
    
    CGContextRef contextImage = CGBitmapContextCreate(pixels, width, height,
                                                      bitsPerComponent, bytesPerRow, colorSpace,
                                                      kCGImageAlphaPremultipliedLast| kCGBitmapByteOrder32Big );
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(contextImage, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(contextImage);
    
    UInt8 *im = pixels;
    int dims[2] = {width, height};
    if(orientation==0 || orientation==1){
        dims[0] = height;
        dims[1] = width;
    }
        
    int blocks[2]; //HOG features size
    blocks[0] = (int)round((double)dims[0]/(double)sbin); //define block size for computing HOG. HOG Cell of (sbin)x(sbin)
    blocks[1] = (int)round((double)dims[1]/(double)sbin);
    
    double *hist = (double *) calloc(blocks[0]*blocks[1]*18,sizeof(double)); //histogram for each block of the HOG with its 18 histograms channel per each.
    double *norm = (double *) calloc(blocks[0]*blocks[1],sizeof(double)); //pointer to end value of histogram
    
    //define hog dimensions
    hogSize[0] = max(blocks[0]-2, 0); //?? why max?, why -2?
    hogSize[1] = max(blocks[1]-2, 0);
    hogSize[2] = 18 + 9 + 4 + 1; // 18 oriented features + 9 unoriented features + 4 texture features + 1 truncation feature
    
    double *mfeat = malloc(hogSize[0]*hogSize[1]*hogSize[2]*sizeof(double)); // pointer to the HOG features (this is the return value!)
    double *feat = mfeat;
    int visible[2]; // Each visible pixel (ie taking into account the round made in defining blocks size and neglecting the edge pixels)
    visible[0] = blocks[0]*sbin;
    visible[1] = blocks[1]*sbin;
    // tiempos date = [NSDate date];
    for (int x = 1; x < visible[1]-1; x++) { //Take care to begin with the first one and end befor the last one: not calculating the gradient at the edge
        for (int y = 1; y < visible[0]-1; y++) {
            
            UInt8 *s = 0; //pointer to the image pixel
            double dx, dy, v, dx2, dy2, v2, dx3, dy3, v3;
            switch (orientation) {
                case 0:
                    s = im + min_int(x, dims[1]-2)*4 + min_int(y, dims[0]-2)*dims[1]*4; //pointer to the image pixel
                    
                    // first color channel
                    dx = (double)*(s+4) - *(s-4);
                    dy = (double)*(s+dims[1]*4) - *(s-dims[1]*4);
                    v = dx*dx + dy*dy;
                    
                    // second color channel
                    s++;
                    dx2 = (double)*(s+4) - *(s-4);
                    dy2 = (double)*(s+dims[1]*4) - *(s-dims[1]*4);
                    v2 = dx2*dx2 + dy2*dy2;
                    
                    // third color channel
                    s++;
                    dx3 = (double)*(s+4) - *(s-4);
                    dy3 = (double)*(s+dims[1]*4) - *(s-dims[1]*4);
                    v3 = dx3*dx3 + dy3*dy3;

                    break;
                    
                case 1:
                    s = im + min_int(visible[1]-1- x, dims[1]-2)*4 + min_int(visible[0]-1- y, dims[0]-2)*dims[1]*4;
                    
                    dx = (double)*(s-4) - *(s+4);
                    dy = (double)*(s-dims[1]*4) - *(s+dims[1]*4);
                    
                    s++;
                    dx2 = (double)*(s-4) - *(s+4);
                    dy2 = (double)*(s-dims[1]*4) - *(s+dims[1]*4);
                    
                    s++;
                    dx3 = (double)*(s-4) - *(s+4);
                    dy3 = (double)*(s-dims[1]*4) - *(s+dims[1]*4);
                    
                    break;
                    
                case 2:
                    s = im + min_int( x, dims[1]-2)*dims[0]*4 + min_int( visible[0]-1-y, dims[0]-2)*4;
                    
                    dy = (double)*(s-4) - *(s+4);
                    dx = (double)*(s+dims[0]*4) - *(s-dims[0]*4);
                    
                    s++;
                    dy2 =  (double)*(s-4) - *(s+4);
                    dx2 = (double)*(s+dims[0]*4) - *(s-dims[0]*4);
                    
                    s++;
                    dy3 =  (double)*(s-4) - *(s+4);
                    dx3 = (double)*(s+dims[0]*4) - *(s-dims[0]*4);
                    
                    break;
                    
                case 3:
                    s = im + min_int(visible[1]-x-1, dims[1]-2)*dims[0]*4 + min_int(y, dims[0]-2)*4;
                    
                    dy = (double)*(s+4) - *(s-4); 
                    dx = (double)*(s-dims[0]*4) - *(s+dims[0]*4);
                    
                    s++;
                    dy2 = (double)*(s+4) - *(s-4);
                    dx2 = (double)*(s-dims[0]*4) - *(s+dims[0]*4);

                    s++;
                    dy3 = (double)*(s+4) - *(s-4);
                    dx3 = (double)*(s-dims[0]*4) - *(s+dims[0]*4);
                    
                    break;
            }
            
            v = dx*dx + dy*dy; //norm
            v2 = dx2*dx2 + dy2*dy2;
            v3 = dx3*dx3 + dy3*dy3;
            
            // pick channel with strongest gradient
            if (v2 > v) {
                v = v2;
                dx = dx2;
                dy = dy2;
            }
            if (v3 > v) {
                v = v3;
                dx = dx3;
                dy = dy3;
            }
            
            // snap to one of 18 oriented HOG channels
            double best_dot = 0; //best dot product achieved
            int best_o = 0; //result will belong to [0,17] and its the mappig to the HOG representant
            for (int o = 0; o < 9; o++) {
                double dot = uu[o]*dx + vv[o]*dy; //dot product between the candidate (dx,dy) and one of the 18 orientation profiles (uu[o],vv[o])
                if (dot > best_dot) {
                    best_dot = dot;
                    best_o = o;
                } else if (-dot > best_dot) { //look fot the opposite orientation
                    best_dot = -dot;
                    best_o = o+9;
                }
            }
            
            
            // Now the histogram value is computed, it is added to the for hog features around the pixel and proportionally weighted.
            double xp = ((double)x+0.5)/(double)sbin - 0.5; 
            double yp = ((double)y+0.5)/(double)sbin - 0.5;
            int ixp = (int)floor(xp); //index of the HOG feature in *hist
            int iyp = (int)floor(yp);
            double vx0 = xp-ixp; // decimal part of xp. Use to ponderate the strength of the vote to the gradient
            double vy0 = yp-iyp;
            double vx1 = 1.0-vx0;
            double vy1 = 1.0-vy0;
            v = sqrt(v); //strongest gradient (the selected) modulus
            
            //?? They are not exactly the 4 surrounding blocks, but the four uphead.
            //The surroundings blocks are 5:(0,0);(1,0);(0,1);(-1,0);(0,-1)
            if (ixp >= 0 && iyp >= 0) {
                *(hist + ixp*blocks[0] + iyp + best_o*blocks[0]*blocks[1]) +=
                vx1*vy1*v; //weighted depending
            }
            
            if (ixp+1 < blocks[1] && iyp >= 0) {
                *(hist + (ixp+1)*blocks[0] + iyp + best_o*blocks[0]*blocks[1]) +=
                vx0*vy1*v;
            }
            
            if (ixp >= 0 && iyp+1 < blocks[0]) {
                *(hist + ixp*blocks[0] + (iyp+1) + best_o*blocks[0]*blocks[1]) +=
                vx1*vy0*v;
            }
            
            if (ixp+1 < blocks[1] && iyp+1 < blocks[0]) {
                *(hist + (ixp+1)*blocks[0] + (iyp+1) + best_o*blocks[0]*blocks[1]) +=
                vx0*vy0*v;
            }
        }
    }
    
    // norm calculation: compute energy in each block by summing over orientations
    for (int o = 0; o < 9; o++) { //iteration over orientations
        double *src1 = hist + o*blocks[0]*blocks[1];
        double *src2 = hist + (o+9)*blocks[0]*blocks[1]; //same orientation, opposite direction
        double *dst = norm; //norm is a pointer to a blocks[0]*blocks[1] memmory mapping. dst will iterate through it.
        double *end = norm + blocks[1]*blocks[0];
        while (dst < end) { //iteration over pixels for the selected HOG channel (non oriented)
            *(dst++) += (*src1 + *src2) * (*src1 + *src2);
            src1++;
            src2++;
        }
    }
    
    // Normalization of each block of cells
    for (int x = 0; x < hogSize[1]; x++) {
        for (int y = 0; y < hogSize[0]; y++) {
            double *dst = feat + x*hogSize[0] + y;
            double *src, *p, n1, n2, n3, n4;
            
            p = norm + (x+1)*blocks[0] + y+1; //norm pointer
            n1 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps); //normalization value
            p = norm + (x+1)*blocks[0] + y;
            n2 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
            p = norm + x*blocks[0] + y+1;
            n3 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
            p = norm + x*blocks[0] + y;
            n4 = 1.0 / sqrt(*p + *(p+1) + *(p+blocks[0]) + *(p+blocks[0]+1) + eps);
            
            double t1 = 0;
            double t2 = 0;
            double t3 = 0;
            double t4 = 0;
            
            // contrast-sensitive features
            src = hist + (x+1)*blocks[0] + (y+1);
            for (int o = 0; o < 18; o++) { //looping over the different channels of
                double h1 = min(*src * n1, 0.2); //?? why impose a max of 0.2
                double h2 = min(*src * n2, 0.2);
                double h3 = min(*src * n3, 0.2);
                double h4 = min(*src * n4, 0.2);
                *dst = 0.5 * (h1 + h2 + h3 + h4);
                t1 += h1;
                t2 += h2;
                t3 += h3;
                t4 += h4;
                dst += hogSize[0]*hogSize[1];
                src += blocks[0]*blocks[1];
            }
            
            // contrast-insensitive features
            src = hist + (x+1)*blocks[0] + (y+1);
            for (int o = 0; o < 9; o++) {
                double sum = *src + *(src + 9*blocks[0]*blocks[1]); //take also the opposite direction in consideration
                double h1 = min(sum * n1, 0.2);
                double h2 = min(sum * n2, 0.2);
                double h3 = min(sum * n3, 0.2);
                double h4 = min(sum * n4, 0.2);
                *dst = 0.5 * (h1 + h2 + h3 + h4);
                dst += hogSize[0]*hogSize[1];
                src += blocks[0]*blocks[1];
            }
            
            // texture features //?? what do they do?
            *dst = 0.2357 * t1;
            dst += hogSize[0]*hogSize[1];
            *dst = 0.2357 * t2;
            dst += hogSize[0]*hogSize[1];
            *dst = 0.2357 * t3;
            dst += hogSize[0]*hogSize[1];
            *dst = 0.2357 * t4;
            
            // truncation feature //?? what do they do?
            dst += hogSize[0]*hogSize[1];
            *dst = 0;
        }
    }
    
    
    free(hist);
    free(norm);
    free(pixels);
    
    return mfeat;
}


-(UInt8 *)HOGpicture:(double *)features
                    :(int)bs //number of pixels used for representing each feature
                    :(int)blockw //width size for HOG features
                    :(int)blockh //height size for HOG features
{
    UInt8 *image = calloc(bs*bs*blockw*blockh*4,sizeof(UInt8)); //4 referring to the number of channels present in a RGB image
    double *f = malloc(9*sizeof(double));
    
    for (int x=0; x<blockw; x++) {
        for (int y=0; y<blockh; y++) {
            for (int i=0; i<9; i++) { //?? just take unoriented features
                *(f + i) = *(features + y + x*blockh + blockw*blockh*i); // for each block, we store in *f the features sequentially
            }
            [self blockPicture:f :image :bs :x :y :blockw :blockh];
        }
    }
    free(f);
    return image;
}


-(void)blockPicture:(double *)features // compute the block picture for a block of HOG
                   :(UInt8 *)im //Image where to store the results
                   :(int)bs //pixels per block
                   :(int)x //x position of the block
                   :(int)y //y position of the block
                   :(int)blockw // block sizes width and height
                   :(int)blockh
{
    for (int i=0; i<bs; i++) {
        for (int j=0; j<bs; j++) {
            
            if (i==(round((double)bs/2))) { // if we are in the y dimension center of the HOG image block
                if(*features < 0.0){ //?? pointer to the first feature, negative values allowed?
                    // NSLog(@"%f",*features);
                    continue;
                }
                *(im + x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw) += round(255*(*(features)));
                *(im + x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw + 1) += round(255*(*(features)));
                *(im + x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw + 2) +=  round(255*(*(features)));
            }
            
            for (int o=1; o<9; o++) {
                if(*(features+o) < 0.0){
                    continue; //skip the feature if its negative
                }
                if (j==round((-tan(-o*PI*20/180+PI/2)*(i-round((double)bs/2))+round((double)bs/2)))) { //if it matches the angle of the corresponding feature, draw there with its intensity
                    *(im + x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw) += round(255*(*(features + o)));
                    *(im + x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw + 1) += round(255*(*(features + o)));
                    *(im + x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw + 2) += round(255*(*(features + o)));
                }
            }
            *(im + x*bs*4 + y*blockw*bs*bs*4 + i*4 + j*4*bs*blockw + 3) = 255;
        }
    }
}



@end