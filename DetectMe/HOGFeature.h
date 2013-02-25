//
//  HOGFeature.h
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 07/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HOGFeature : NSObject
{
    @public int sbin; //Number of pixels per hog cell
    
    //TODO: Pointer to HOG Values
    
}

- (id) initWithNumberCells:(int) aSbin;

- (double *)HOGOrientationWithDimension:(int *)hogSize
                              forImage:(CGImageRef)imageRef
                  withPhoneOrientation:(int) orientation;

- (UIImage *) HOGImage:(CGImageRef) imageRef;

- (UInt8 *)HOGpicture:(double *)features
                    :(int)bs //number of pixels used for representing each feature
                    :(int)blockw //width size for HOG features
                    :(int)blockh; //height size for HOG features

- (void)blockPicture:(double *)features // compute the block picture for a block of HOG
                   :(UInt8 *)im //Image where to store the results
                   :(int)bs //pixels per block
                   :(int)x //x position of the block
                   :(int)y //y position of the block
                   :(int)blockw // block sizes width and height
                   :(int)blockh;


@end
