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



@implementation CameraViewController

@synthesize captureSession = _captureSession;
@synthesize HOGimageView = _HOGimageView;
@synthesize resultsImageView = _resultsImageView;
@synthesize customLayer = _customLayer;
@synthesize prevLayer = _prevLayer;
@synthesize detectView = _detectView;
@synthesize templateName = _templateName;

@synthesize hogFeature = _hogFeature;



- (void)viewDidLoad
{
    // Initialitzation after the view load and all the outlets are hooked
    [super viewDidLoad];
    
    //From init with name
    self.HOGimageView = nil;
    self.resultsImageView = nil;
    self.prevLayer = nil;
    self.customLayer = nil;
    
    hogOnScreen = NO;
    pyramid = YES;
    numMax = 1;
    
    cameraRoll = NO;
    printResults = NO;
    fullScreen = NO;
    fileWritten = NO;
    saving = NO;
    interval = 10;
    
    self.hogFeature = [[HOGFeature alloc] initWithNumberCells:8];
    

    sizeImage = 10; //??
    
    
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
    
    //data compression specifications for camera capture
	/*
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]; 
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key]; 
    */
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
	[captureOutput setVideoSettings:videoSettings]; 
    
    //Capture session definition
	self.captureSession = [[AVCaptureSession alloc] init];
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    
//    //Setting button in navigation bar
//    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsAction:)];
//    self.navigationItem.rightBarButtonItem = settingsButton;
    
//	self.customLayer = [CALayer layer];
//	self.customLayer.frame = self.view.bounds;
//	self.customLayer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI/2.0f, 0, 0, 1);
//	self.customLayer.contentsGravity = kCAGravityResizeAspectFill;
//	[self.view.layer addSublayer:self.customLayer];

    // Image views layers initialization for the different views
	//self.HOGimageView.frame = CGRectMake(0, 0, 160, 208);
    //self.resultsImageView.frame = CGRectMake(0, 208, 160, 208);
    self.HOGimageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 208)];
    self.resultsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 208, 160, 208)];

    
	self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
	self.prevLayer.frame = self.view.frame;  //CGRectMake(100, 0, 100, 100);
	self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.view.layer addSublayer: self.prevLayer];
	
    // We start the capture
    self.detectView = [[DetectView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
	//[self.captureSession startRunning]; Done in viewdidappear
    [self.view addSubview:self.HOGimageView];
    [self.view addSubview:self.resultsImageView];
    [self.view addSubview:self.detectView];
    
    
    //Select template
    templateWeights = [FileStorageHelper readTemplate:self.templateName];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show CameraVC settings"]) {
        SettingsViewController *settingsVC = (SettingsViewController *) segue.destinationViewController;
        settingsVC.delegate = self;
        settingsVC.hog = hogOnScreen;
        settingsVC.pyramid = pyramid;
        settingsVC.numMaximums = (numMax==10 ? YES: NO);
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection 
{
	//We create an autorelease pool because as we are not in the main_queue our code is not executed in the main thread. So we have to create an autorelease pool for the thread we are in.
    
    if (!saving) {
        @autoreleasepool { //?? Autorelease pool translated automatically from ARC conversion
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer,0); //Lock the image buffer ??Why
        
        //Get information about the image
        uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer); 
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
        size_t width = CVPixelBufferGetWidth(imageBuffer); 
        size_t height = CVPixelBufferGetHeight(imageBuffer);  
//        NSLog(@"Pixels: %zu x %zu",width ,height );

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
        int numPyramids=10;
        if (! pyramid)  numPyramids=1;
        
        clock_t start = clock(); //Trace execution time
                
            NSArray *nmsArray = [ConvolutionHelper convPyraFeat:[UIImage imageWithCGImage:imageRef scale:1.0 orientation:3]
                                                   withTemplate:templateWeights
                                                 withHogFeature:self.hogFeature
                                                       pyramids:numPyramids];
        
        NSLog(@"TOTAL TIME: %f", (double)(clock()-start) / CLOCKS_PER_SEC);
        
        [self.detectView setCorners:nmsArray];
        [self.detectView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
            
        // Update the navigation controller title with some information about the detection
        if (nmsArray.count > 0) {
            ConvolutionPoint *score = [nmsArray objectAtIndex:0];
            [self performSelectorOnMainThread:@selector(setTitle:) withObject:[NSString stringWithFormat:@"%3f",score.score.doubleValue] waitUntilDone:YES];
        } else{
            [self performSelectorOnMainThread:@selector(setTitle:) withObject:@"No detection." waitUntilDone:YES];
        }
            
        if (hogOnScreen) { //Put the HOG picture on screen
            int blocks[2];
            double *feat = [self.hogFeature HOGOrientationWithDimension:blocks forImage:[ImageProcessingHelper resizeImage:imageRef withRect:230] withPhoneOrientation:3];
            int pix = 12;
            UInt8 *pic = [self.hogFeature HOGpicture:feat :pix :blocks[1] :blocks[0]];
            CGContextRef context = CGBitmapContextCreate(pic, //data
                                            blocks[1]*pix, //width
                                            blocks[0]*pix, //height
                                            8, //bits per component
                                            blocks[1]*pix*4, //bytes per row
                                            CGColorSpaceCreateDeviceRGB(),
                                            kCGImageAlphaPremultipliedLast ); //bitmap info
            CGImageRef ima = CGBitmapContextCreateImage(context);
//            UIImage* rawImage = [UIImage imageWithCGImage:ima];
            CGContextRelease(context);
            UIImage *image = [UIImage imageWithCGImage:ima scale:1.0 orientation:UIImageOrientationUp]; 
            
            [self.HOGimageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES]; //ask the main thread to put the HOG image
            free(feat); //?? Need to be freed?
            free(pic);
        }
        else {
            [self.HOGimageView performSelectorOnMainThread:@selector(setImage:) withObject:nil waitUntilDone:YES];
        }
        
            
        //We unlock the  image buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        CGImageRelease(imageRef);

        }
    }
} 

#pragma mark -
#pragma mark Settings delegate

-(void) setHOGValue:(BOOL) value{
    hogOnScreen = value;
  
}

-(void) setPyramidValue:(BOOL) value{
    pyramid = value;
    if (!pyramid) {
        [self.resultsImageView performSelectorOnMainThread:@selector(setImage:) withObject:nil waitUntilDone:NO];
    }
}

-(void) setNumMaximums:(BOOL) value{
    
    numMax = value ? 10 : 1;
}



#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
    NSLog(@"viewdidunload");

	self.HOGimageView = nil;
    self.resultsImageView = nil;
	self.customLayer = nil;
	self.prevLayer = nil;
    self.detectView = nil;
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.captureSession stopRunning];
    [self.detectView reset];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.captureSession startRunning];
}


@end
