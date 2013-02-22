//
//  ImageProcessingHelper.m
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 07/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//

#import "ImageProcessingHelper.h"

@implementation ImageProcessingHelper

+ (CGImageRef)resizeImage:(CGImageRef)imageRef
                withRect:(int )maxsize
{
    CGRect newRect;
    double ratio = (double)CGImageGetWidth(imageRef)/(double)CGImageGetHeight(imageRef);
    
    //make a rectangle to mantain aspect ratio
    if(ratio > 1){ //landscape, wider than higher
        newRect = CGRectIntegral(CGRectMake(0, 0, maxsize, maxsize/ratio));
        
    }else{ //portrait
        newRect = CGRectIntegral(CGRectMake(0, 0, maxsize*ratio, maxsize));
    }
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    // CGContextConcatCTM(bitmap, );
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationDefault);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    CGContextRelease(bitmap);
    
    return newImageRef;
}


+ (CGImageRef)scaleImage:(CGImageRef )image
                  scale:(double )sc
{
    
    CGRect newRect = CGRectIntegral( CGRectMake(0, 0, CGImageGetWidth(image)*sc, CGImageGetHeight(image)*sc) );

    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(image),
                                                0,
                                                CGImageGetColorSpace(image),
                                                CGImageGetBitmapInfo(image));

    // Rotate and/or flip the image if required by its orientation
    // CGContextConcatCTM(bitmap, );

    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationDefault);

    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, newRect, image);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImage = CGBitmapContextCreateImage(bitmap);
    
    //UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    //NSLog(@"Pixels: %zu x %zu", CGImageGetWidth(newImageRef),CGImageGetHeight(newImageRef) );
    
    // Clean up
    CGContextRelease(bitmap);

    return newImage;

}


+ (UIImage *)turnGreyScaleImage:(CGImageRef)imageRef
{
    
     /*
     NSUInteger width = CGImageGetWidth(imageRef); //#pixels ancho
     NSUInteger height = CGImageGetHeight(imageRef); //#pixels alto
     CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
     UInt8 *pixels = malloc(height * width * 4); // donde irán los pixels, 3b para RGB + 1b para alpha
     //NSLog(@"w=%d, h=%d",width,height);
     
     //NSUInteger bytesPerPixel = 4;
     //NSUInteger bytesPerRow = bytesPerPixel * width;
     //NSUInteger bitsPerComponent = 8;
     CGContextRef contextImage = CGBitmapContextCreate(pixels, width, height,
     8, 4*width, colorSpace,
     kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
     CGColorSpaceRelease(colorSpace);
     
     CGContextDrawImage(contextImage, CGRectMake(0, 0, width, height), imageRef);
     //NSLog(@"%lu",sizeof(&pixels));
     CGContextRelease(contextImage);
      */
    
    NSUInteger width = CGImageGetWidth(imageRef); //#pixels ancho
    NSUInteger height = CGImageGetHeight(imageRef); //#pixels alto
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
    
    int ini=0;
    UInt8 y;
    for (int i=0; i<height*width; i++) {
        y=0.11*pixels[ini]+0.59*pixels[ini+1]+0.3*pixels[ini+2];
        pixels[ini]=y;
        pixels[ini+1]=y;
        pixels[ini+2]=y;
        ini+=4;
    }
    CGContextRef context;
    
    context = CGBitmapContextCreate(pixels,
                                    width,
                                    height,
                                    bitsPerComponent,
                                    bytesPerRow,
                                    CGImageGetColorSpace( imageRef ),
                                    kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGImageRef im = CGBitmapContextCreateImage (context);
    UIImage *rawImage = [UIImage imageWithCGImage:im scale:1.0 orientation:UIImageOrientationRight];
    return rawImage;
    
    //This was before used inside CameraViewController. So the following line needs to be included inside the controller with the output of this function
//    [self.greyScale performSelectorOnMainThread:@selector(setImage:) withObject:rawImage waitUntilDone:NO];
    CGContextRelease(context);
    free(pixels);
    
}



@end
