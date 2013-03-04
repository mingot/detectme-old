//
//  UIImage+Brightness.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 04/03/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "UIImage+Brightness.h"

@implementation UIImage (Brightness)


- (UIImage *) saturateImage:(int)amount
{
    UIImage *sourceImage = self;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter= [CIFilter filterWithName:@"CIColorControls"];
    CIImage *inputImage = [[CIImage alloc] initWithImage:sourceImage];
    
    [filter setValue:inputImage forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:amount] forKey:@"inputSaturation"];
    
    return [UIImage imageWithCGImage:[context createCGImage:filter.outputImage fromRect:filter.outputImage.extent]];
}

- (UIImage *) brightImage:(float) amount
{
    UIImage *sourceImage = self;
    CIContext *context = [CIContext contextWithOptions:nil];
    CIFilter *filter= [CIFilter filterWithName:@"CIColorControls"];
    CIImage *inputImage = [[CIImage alloc] initWithImage:sourceImage];
    
    [filter setValue:inputImage forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:amount] forKey:@"inputContrast"];
    
    return [UIImage imageWithCGImage:[context createCGImage:filter.outputImage fromRect:filter.outputImage.extent]];
}

@end



