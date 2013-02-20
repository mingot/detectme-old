//
//  FourierHelper.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 19/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "FourierTransform.h"

@implementation FourierTransform


- (id) initWithSize:(int)size windowSize:(int)window_size //default 4096
{
    if(self = [super init])
    {
        fftSize = size;                 // sample size
        fftSizeOver2 = fftSize/2;
        log2n = log2f(fftSize);         // bins
        log2nOver2 = log2n/2;
        
        in_real = (float *) malloc(fftSize * sizeof(float));
        out_real = (float *) malloc(fftSize * sizeof(float));
        split_data.realp = (float *) malloc(fftSizeOver2 * sizeof(float));
        split_data.imagp = (float *) malloc(fftSizeOver2 * sizeof(float));
        
        windowSize = window_size;
        window = (float *) malloc(sizeof(float) * windowSize);
        memset(window, 0, sizeof(float) * windowSize);
        vDSP_hann_window(window, window_size, vDSP_HANN_DENORM);
        
        scale = 1.0f/(float)(4.0f*fftSize);
        
        // allocate the fft object once
        fftSetup = vDSP_create_fftsetup(log2n, FFT_RADIX2);
        if (fftSetup == NULL) {
            NSLog(@"\nFFT_Setup failed to allocate enough memory.\n");
        }
    }
    
    return self;
}


- (void) dealloc
{
    free(in_real);
    free(out_real);
    free(split_data.realp);
    free(split_data.imagp);
    
    vDSP_destroy_fftsetup(fftSetup);

}



- (void) forward:(int)start :(float *)buffer :(float *)magnitude :(float *)phase;
{
    //multiply by window
    vDSP_vmul(buffer, 1, window, 1, in_real, 1, fftSize);
    
    //convert to split complex format with evens in real and odds in imag
    vDSP_ctoz((COMPLEX *) in_real, 2, &split_data, 1, fftSizeOver2);
    
    //calc fft
    vDSP_fft_zrip(fftSetup, &split_data, 1, log2n, FFT_FORWARD);
    
    split_data.imagp[0] = 0.0;
    
    for (i = 0; i < fftSizeOver2; i++)
    {
        //compute power
        float power = split_data.realp[i]*split_data.realp[i] +
        split_data.imagp[i]*split_data.imagp[i];
        
        //compute magnitude and phase
        magnitude[i] = sqrtf(power);
        phase[i] = atan2f(split_data.imagp[i], split_data.realp[i]);
    }
}



- (void) inverse:(int)start :(float *)buffer :(float *)magnitude :(float *)phase :(bool)dowindow
{
    float *real_p = split_data.realp, *imag_p = split_data.imagp;
    for (i = 0; i < fftSizeOver2; i++) {
        *real_p++ = magnitude[i] * cosf(phase[i]);
        *imag_p++ = magnitude[i] * sinf(phase[i]);
    }
    
    vDSP_fft_zrip(fftSetup, &split_data, 1, log2n, FFT_INVERSE);
    vDSP_ztoc(&split_data, 1, (COMPLEX*) out_real, 2, fftSizeOver2);
    
    vDSP_vsmul(out_real, 1, &scale, out_real, 1, fftSize);
    
    // multiply by window w/ overlap-add
    if (dowindow) {
        float *p = buffer + start;
        for (i = 0; i < fftSize; i++) {
            *p++ += out_real[i] * window[i];
        }
    }
}

- (void) forwardWithImage: (CGImageRef *) imageRef
{
    
    // TODO: Finish the implementation of Fourier Class to directly deal with imges
    // Get the image in bits from CGImageRef: Create a context and draw the image there to get the image in bits
    NSUInteger width = CGImageGetWidth(*imageRef); //#pixels width
    NSUInteger height = CGImageGetHeight(*imageRef); //#pixels height
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * width;
    int bitsPerComponent = 8;
    UInt8 *pixels = (UInt8 *)malloc(height * width * 4);
    
    CGContextRef contextImage = CGBitmapContextCreate(pixels, width, height,
                                                      bitsPerComponent, bytesPerRow, colorSpace,
                                                      kCGImageAlphaPremultipliedLast| kCGBitmapByteOrder32Big );
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(contextImage, CGRectMake(0, 0, width, height), *imageRef);
    CGContextRelease(contextImage);
    
    UInt8 *im = pixels;
    
    UInt8 *oneChannelImage = malloc(width*height*sizeof(UInt8));
    
    for(int x=0; x<width; x++)
        for(int y=0;y<height;y++)
            *(oneChannelImage + x + y*width) = *(im + x*4 + y*width*4);
            
    
//    if(orientation==0 || orientation==1){
//        dims[0] = height;
//        dims[1] = width;
//    }

    
}

@end
