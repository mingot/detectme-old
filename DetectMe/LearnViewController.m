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
    self.detectFrameView = [[RectFrameLearnView alloc] initWithFrame:self.view.frame]; //TO change to self.prevLayer.frame
   
    // Previous layer to show the video image
	self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
	self.prevLayer.frame = self.view.frame;
	self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
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
            
            //Crop it to the desired size (taking into account the orientation)
            // TODO: relate the actual image with the image displayed on the prevLayer (and make concide the crop area).
            UIImage *croppedImage = [image croppedImage:CGRectMake(image.size.width/4, image.size.height/4, image.size.width/2, image.size.height/2)];
            
            [self.listOfTrainingImages addObject:croppedImage]; 
//            [FileStorageHelper writeImageToDisk:[rotatedImage CGImage]  withTitle:@"petita_prova2"];
            
            //For each positive training image, take 5 random crops of the same image
            int maxX = (int)(image.size.height - image.size.width/2);
            int maxY = (int)(image.size.width - image.size.height/2);
            for(int i=0;i<4;i++)
            {
                int randomX = arc4random() % maxX;
                int randomY = arc4random() % maxY;
                
                if(i%4==0) randomX=0; //selecting the negative examples around the selected surface
                else if(i%4==1) randomX=maxX;
                else if(i%4==2) randomY=0;
                else if(i%4==3) randomY = maxY;
                
                UIImage *croppedImageNegative = [image croppedImage:CGRectMake(randomX, randomY, image.size.width/2, image.size.height/2)];
                [self.listOfTrainingImages addObject:croppedImageNegative];
               
            }
            
            // update the number of training images
            [self.numberOfTrainingButton performSelectorOnMainThread:@selector(setTitle:) withObject:[NSString stringWithFormat:@"%d",[self.listOfTrainingImages count]] waitUntilDone:YES];

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
        trainingImagesTVC.listOfImages = self.listOfTrainingImages; 
    }
}

//TODO: hog view of the detect frame


- (IBAction)learnAction:(id)sender
{
    // Modal for choosing a name
    self.trainingClassifier = [[TrainingClassifier alloc] init];
    self.trainingClassifier.listOfTrainingImages = self.listOfTrainingImages;
    [self.trainingClassifier trainTheClassifier];
    
    //Learn creating a new queue
    
    //Store the template in the main directory
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
