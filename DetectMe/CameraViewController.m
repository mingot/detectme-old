//
//  CameraViewController.m
//  DetectIm
//
//  Created by Dolores Blanco Almazán on 13/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Math.h>
#include <math.h>

#import "CameraViewController.h"
#import "FileStorageHelper.h"
#import "ImageProcessingHelper.h"
#import "ConvolutionHelper.h"
#import "UIImage+HOG.h"


@implementation CameraViewController

@synthesize captureSession = _captureSession;
@synthesize prevLayer = _prevLayer;

@synthesize HOGimageView = _HOGimageView;
@synthesize detectView = _detectView;

@synthesize templateName = _templateName;
@synthesize detectionThresholdSliderButton = _detectionThresholdSliderButton;

@synthesize svmClassifier = _svmClassifier;


- (void)viewDidLoad
{
    // Initialitzation after the view load and all the outlets are hooked
    [super viewDidLoad];
    
    self.prevLayer = nil;
    
    hogOnScreen = NO;
    pyramid = YES;
    numMax = 1;
    
    cameraRoll = NO;
    printResults = NO;
    fullScreen = NO;
    fileWritten = NO;
    interval = 10;
    
    sizeImage = 10; //??
    
    
    //Select template
    templateWeights = [FileStorageHelper readTemplate:self.templateName];
    self.svmClassifier = [[Classifier alloc] initWithTemplateWeights:templateWeights];
    
    
    // ********  CAMERA CAPUTRE  ********
    //Capture input specifications
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput 
										  deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] 
										  error:nil];
    
    //Capture output specifications
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	captureOutput.alwaysDiscardsLateVideoFrames = YES; 
	
    // Output queue setting (for receiving captures from AVCaptureSession delegate)
	dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
	dispatch_release(queue);
    
    // Set the video output to store frame in BGRA (It is supposed to be faster)
    NSDictionary *videoSettings = [NSDictionary
                                   dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
                                   kCVPixelBufferPixelFormatTypeKey,
                                   nil];
	[captureOutput setVideoSettings:videoSettings]; 
    
    //Capture session definition
	self.captureSession = [[AVCaptureSession alloc] init];
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];

    // Previous layer to show the video image
	self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
	self.prevLayer.frame = self.view.bounds;  
	self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.view.layer addSublayer: self.prevLayer];
    
    // Add subviews in front of  the prevLayer
    [self.view addSubview:self.HOGimageView];
    [self.view addSubview:self.detectView];
}


- (void) viewDidAppear:(BOOL)animated
{
    //Start the capture
    [self.captureSession startRunning];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show CameraVC settings"])
    {
        SettingsViewController *settingsVC = (SettingsViewController *) segue.destinationViewController;
        settingsVC.delegate = self;
        settingsVC.hog = hogOnScreen;
        settingsVC.pyramid = pyramid;
        settingsVC.numMaximums = (numMax==10 ? YES : NO);
    }
}




#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection 
{
    
	//We create an autorelease pool because as we are not in the main_queue our code is not executed in the main thread. So we have to create an autorelease pool for the thread we are in.
    @autoreleasepool
    {
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer,0); //Lock the image buffer ??Why
        
        //Get information about the image
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
        size_t width = CVPixelBufferGetWidth(imageBuffer); 
        size_t height = CVPixelBufferGetHeight(imageBuffer);  

        //Create a CGImageRef from the CVImageBufferRef
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
        CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGImageRef imageRef = CGBitmapContextCreateImage(newContext); 
        
        //We release some components
        CGContextRelease(newContext); 
        CGColorSpaceRelease(colorSpace);
        
        /*
        //CGRect newRect = CGRectIntegral( CGRectMake(0, 0, 230, 160 ));
        
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
         */
        
        //TODO: make this a parameter that can be set via features.
        int numPyramids = 15;
        if (! pyramid)  numPyramids = 1;
                
        NSArray *nmsArray = [self.svmClassifier detect:[UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationRight]
                                      minimumThreshold:-1 + 0.2*self.detectionThresholdSliderButton.value //make the slider sweep in the range [-1,-0.8]
                                              pyramids:numPyramids
                                              usingNms:YES];
        
        
        // set boundaries of the detection and redraw
        [self.detectView setCorners:nmsArray];
        [self.detectView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
            
        // Update the navigation controller title with some information about the detection
        if (nmsArray.count > 0)
        {
            ConvolutionPoint *score = [nmsArray objectAtIndex:0];
            [self performSelectorOnMainThread:@selector(setTitle:) withObject:[NSString stringWithFormat:@"%3f",score.score] waitUntilDone:YES];
        } else{
            [self performSelectorOnMainThread:@selector(setTitle:) withObject:@"No detection." waitUntilDone:YES];
        }
        
        //Put the HOG picture on screen
        if (hogOnScreen) 
        { 
            CGImageRef imgResized = [ImageProcessingHelper resizeImage:imageRef withRect:230];
            UIImage *image = [[UIImage imageWithCGImage:imgResized scale:1.0 orientation:3] convertToHogImage];
            [self.HOGimageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
        }
        
        //We unlock the  image buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        CGImageRelease(imageRef);
    }
} 

#pragma mark -
#pragma mark Settings delegate

-(void) setHOGValue:(BOOL) value{
    hogOnScreen = value;
    if(!value) [self.HOGimageView performSelectorOnMainThread:@selector(setImage:) withObject:nil waitUntilDone:YES];
}

-(void) setPyramidValue:(BOOL) value{
    pyramid = value;
}

-(void) setNumMaximums:(BOOL) value{
    numMax = value ? 10 : 1;
}



#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    [self setDetectionThresholdSliderButton:nil];
    NSLog(@"viewdidunload");

	self.prevLayer = nil;
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.captureSession stopRunning];
    [self.detectView reset];
}


@end
