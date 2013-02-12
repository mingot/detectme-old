//
//  ImageProcessingHelper.h
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 07/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageProcessingHelper : NSObject

+ (CGImageRef)resizeImage:(CGImageRef)imageRef
                 withRect:(int )maxsize;

+ (CGImageRef)scaleImage:(CGImageRef )image
                   scale:(double) sc;

+ (UIImage *)turnGreyScaleImage:(CGImageRef)imageRef;

@end
