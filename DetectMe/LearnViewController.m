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
#import "ImageProcessingHelper.h"
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
@synthesize detectFrameView = _detectFrameView;

@synthesize listOfTrainingImages =_listOfTrainingImages;
@synthesize numberOfTrainingButton = _numberOfTrainingButton;
@synthesize trainingClassifier = _trainingClassifier;

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
    
    // Subviews initialization
    self.detectFrameView = [[RectFrameLearnView alloc] initWithFrame:self.view.bounds]; //TO change to self.prevLayer.frame
   
    // Previous layer to show the video image
	self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
	self.prevLayer.frame = self.view.bounds;
	self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//
	[self.view.layer addSublayer: self.prevLayer];

    [self.view addSubview:self.detectFrameView];

}


- (void) viewDidAppear:(BOOL)animated
{
    //Start the capture
    [self.captureSession startRunning];
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
            UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:3];
            
            // Dimensions
            CGRect screenBound = [[UIScreen mainScreen] bounds];
//            NSLog(@"Dimension of the total screen (w x h): %f x %f", screenBound.size.width, screenBound.size.height);
//            NSLog(@"Dimension of image captured: %f x %f", image.size.width, image.size.height);
//            NSLog(@"Dimension of the prevLayer frame: %f x %f", self.view.frame.size.width, self.view.frame.size.height);

            
            //Crop it to the desired size (taking into account the orientation)
            // TODO: relate the actual image with the image displayed on the prevLayer (and make concide the crop area). Why does it resize the image to 360x480??
            // Image obtained by the camera is 360x480. This image is also displayed in prevLayer resized mantaining aspect ratio to fit in 320x504.
            float scale = image.size.height / self.view.frame.size.height;
            UIImage *croppedImageToFitScreen = [image croppedImage:CGRectMake((image.size.width - self.view.frame.size.width*scale)/2, 0, self.view.frame.size.width*scale, image.size.height)];
        
            [self.trainingSet.images addObject:croppedImageToFitScreen];
            
            // add ground truth bounding box
            ConvolutionPoint *boundingBox = [[ConvolutionPoint alloc] initWithRect:CGRectMake(1.0/4, 1.0/4, 1.0/2, 1.0/2) label:1 imageIndex:[self.trainingSet.images count]-1];
            
            [self.trainingSet.groundTruthBoundingBoxes addObject:boundingBox];
            
            // update the number of training images
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
    }
}

//TODO: hog view of the detect frame

- (IBAction)learnAction:(id)sender
{
    // Modal for choosing a name
    [self.svmClassifier train:self.trainingSet];
    
    NSLog(@"learn went great");
    // write the template to a file
    [FileStorageHelper writeTemplate:self.svmClassifier.svmWeights withSize:self.svmClassifier.weightsDimensions withTitle:@"prova2.txt"];

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

@end
