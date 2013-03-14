//
//  LearnViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 20/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//


#include <stdlib.h> // For random number generation using arc4random

#import "LearnViewController.h"
#import "FileStorageHelper.h"  
#import "UIImage+Resize.h"
#import "ConvolutionHelper.h"


@interface LearnViewController ()
{
    bool takePhoto; // change state when learnAction button is pressed
}

@property (strong, nonatomic) NSMutableArray *listOfTrainingImages;
@property UIBarButtonItem *numberOfTrainingButton; //defined outside the viewDidLoad to change easily it's title


@end



@implementation LearnViewController

@synthesize captureSession = _captureSession;
@synthesize prevLayer = _prevLayer;
@synthesize detectView = _detectView;
@synthesize trainingSet = _trainingSet;

@synthesize listOfTrainingImages =_listOfTrainingImages;
@synthesize numberOfTrainingButton = _numberOfTrainingButton;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    takePhoto = NO;
    //TODO: current fixed maximum capacity for the number of example images
    self.listOfTrainingImages = [[NSMutableArray alloc] initWithCapacity:10];
    self.trainingSet = [[TrainingSet alloc] init];
    self.svmClassifier = [[Classifier alloc] init];
    
    //TODO: initialize where they should go!!
    self.trainingSet.images = [[NSMutableArray alloc] init];
    self.trainingSet.groundTruthBoundingBoxes = [[NSMutableArray alloc] init];
    self.trainingSet.boundingBoxes = [[NSMutableArray alloc] init];
    
    
    // NavigatinoBar buttons and labels
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    UIBarButtonItem *learnButton = [[UIBarButtonItem alloc] initWithTitle:@"Learn" style:UIBarButtonItemStyleBordered target:self action:@selector(learnAction:)];
    self.numberOfTrainingButton = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%d",[self.listOfTrainingImages count]] style:UIBarButtonItemStyleBordered target:self action:@selector(numberOfTrainingAction:)];
    
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects: learnButton, addButton, self.numberOfTrainingButton, nil];
    
    
    // ********  CAMERA CAPUTRE  ********
    //Capture input specifications
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
    
    //Capture output specifications
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	captureOutput.alwaysDiscardsLateVideoFrames = YES;
	
    // Output queue setting (for receiving captures from AVCaptureSession delegate)
	dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
	dispatch_release(queue);
    
    // Set the video output to store frame in BGRA (It is supposed to be faster)
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
	[captureOutput setVideoSettings:videoSettings];
    
    //Capture session definition
	self.captureSession = [[AVCaptureSession alloc] init];
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];
    [self.captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    
    // Previous layer to show the video image
	self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    self.prevLayer.frame = self.detectView.frame;
	self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	[self.view.layer addSublayer: self.prevLayer];

    // detect view frame
    ConvolutionPoint *detectFrame = [[ConvolutionPoint alloc] initWithRect:CGRectMake(3.0/8, 3.0/8, 1.0/4, 1.0/4) label:0 imageIndex:0];
    [self.detectView setCorners:[[NSArray alloc] initWithObjects:detectFrame, nil]];
    [self.view addSubview:self.detectView];
}


- (void) viewDidAppear:(BOOL)animated
{
    //Start the capture
    [self.captureSession startRunning];
}


- (void) printRectangle: (CGRect) rect
{
    NSLog(@"H:%f W:%f origin.x:%f origin.y:%f", rect.size.height, rect.size.width, rect.origin.x, rect.origin.y);
}

#pragma mark -
#pragma mark AVCaptureSession delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
	   fromConnection:(AVCaptureConnection *)connection
{
    @autoreleasepool {
        
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer,0); //Lock the image buffer
        
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
        
        
        if(takePhoto) //Asynch for when the addButton (addAction) is pressed
        {
            // Make the UIImage and change the orientation
            UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:UIImageOrientationRight];
        
            [self.trainingSet.images addObject:image];
            
            // add ground truth bounding box
            ConvolutionPoint *boundingBox = [[ConvolutionPoint alloc] initWithRect:CGRectMake(3.0/8, 3.0/8, 1.0/4, 1.0/4) label:1 imageIndex:[self.trainingSet.images count]-1];
            [self.trainingSet.groundTruthBoundingBoxes addObject:boundingBox];
            
            // update the number of training images on the button title
            [self.numberOfTrainingButton performSelectorOnMainThread:@selector(setTitle:) withObject:[NSString stringWithFormat:@"%d",[self.trainingSet.images count]] waitUntilDone:YES];

            takePhoto = NO;
        }
        
        //We unlock the  image buffer
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        CGImageRelease(imageRef);
        
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"show Training Set of Images"]) {
        TrainingImagesTableViewController *trainingImagesTVC = (TrainingImagesTableViewController *) segue.destinationViewController;
        trainingImagesTVC.delegate = self;
        [self.trainingSet initialFill];
        NSMutableArray *listOfImages = [[NSMutableArray alloc] initWithCapacity:[self.trainingSet.boundingBoxes count]];
        
        for(int i=0; i<[self.trainingSet.boundingBoxes count]; i++)
        {
            ConvolutionPoint *cp = [self.trainingSet.boundingBoxes objectAtIndex:i];
            UIImage *wholeImage = [self.trainingSet.images objectAtIndex:cp.imageIndex];
            [listOfImages addObject:[wholeImage croppedImage:[cp rectangleForImage:wholeImage]]];
        }
            
        trainingImagesTVC.listOfImages = listOfImages; 
//        trainingImagesTVC.listOfImages = self.trainingSet.images;
    }
}

- (IBAction)learnAction:(id)sender
{
    // Modal for choosing a name
    [self.svmClassifier train:self.trainingSet];
    
    NSLog(@"learn went great");
    
    // write the template to a file
    [self.svmClassifier storeSvmWeightsAsTemplateWithName:@"prova4.txt"];

    //Learn creating a new queue

}

- (IBAction)addAction:(id)sender
{
    takePhoto = YES;
}

- (IBAction)numberOfTrainingAction:(id)sender
{
    //Perform segue to table view of learning images
    [self performSegueWithIdentifier:@"show Training Set of Images" sender:self];
}


#pragma mark -
#pragma mark TrainingImagesTVC delegate

- (void) setPhotos:(NSArray *)photos
{
    
}

- (void)viewDidUnload {
    [self setDetectView:nil];
    [super viewDidUnload];
}
@end
