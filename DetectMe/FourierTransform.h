//
//  FourierHelper.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 19/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//


/*
 *  pkmFFT.h
 *
 *  Real FFT wraper for Apple's Accelerate Framework
 *
 *  Created by Parag K. Mital - http://pkmital.com
 *  Contact: parag@pkmital.com
 *
 *  Additional resources:
 *      http://developer.apple.com/library/ios/#documentation/Accelerate/Reference/vDSPRef/Reference/reference.html
 *      http://developer.apple.com/library/ios/#documentation/Performance/Conceptual/vDSP_Programming_Guide/SampleCode/SampleCode.html
 *      http://stackoverflow.com/questions/3398753/using-the-apple-fft-and-accelerate-framework
 *      http://stackoverflow.com/questions/1964955/audio-file-fft-in-an-os-x-environment
 *
 *
 *  This code is a very simple interface for Accelerate's fft/ifft code.
 *  It was built out of hacking Maximilian (Mick Grierson and Chris Kiefer) and
 *  the above mentioned resources for performing a windowed FFT which could
 *  be used underneath of an STFT implementation
 *
 *  Usage:
 *
 *  // be sure to either use malloc or __attribute__ ((aligned (16))
 *  float *sample_data = (float *) malloc (sizeof(float) * 4096);
 *  float *allocated_magnitude_buffer =  (float *) malloc (sizeof(float) * 2048);
 *  float *allocated_phase_buffer =  (float *) malloc (sizeof(float) * 2048);
 *
 *  pkmFFT *fft;
 *  fft = new pkmFFT(4096);
 *  fft.forward(0, sample_data, allocated_magnitude_buffer, allocated_phase_buffer);
 *  fft.inverse(0, sample_data, allocated_magnitude_buffer, allocated_phase_buffer);
 *  delete fft;
 *
 */

#import <Foundation/Foundation.h>
#include <Accelerate/Accelerate.h>

@interface FourierTransform : NSObject
{
    size_t fftSize, fftSizeOver2, log2n, log2nOver2, windowSize, i;
    float *in_real, *out_real, *window;
    float scale;
    
    FFTSetup fftSetup;
    COMPLEX_SPLIT split_data;
}

- (void) forward:(int)start :(float *)buffer :(float *)magnitude :(float *)phase;
- (void) inverse:(int)start :(float *)buffer :(float *)magnitude :(float *)phase :(bool)dowindow;

- (void) forwardWithImage: (CGImageRef *)image;

@end
