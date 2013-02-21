//
//  LearnViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 20/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "LearnViewController.h"
#import "FileStorageHelper.h"  


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
    @autoreleasepool {
        
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
        
        
        if(takePhoto) //Asynch for when the addButton (addAction) is pressed
        {
            CGFloat ImWidth, ImHeigth;
            ImWidth = self.detectFrameView.frame.size.width;
            ImHeigth = self.detectFrameView.frame.size.height;
//            NSLog(@"prevLayer hegith:%f width:%f", self.prevLayer.frame.size.height, self.prevLayer.frame.size.width);
//            NSLog(@"detectLayer hegith:%f width:%f", self.detectFrameView.frame.size.height, self.detectFrameView.frame.size.width);
//            NSLog(@"photo height:%f, width;:%f", height, width);
            
            //TODO: fix the non correlation between prevLayer and imageRef to make concide the detection frame rectangle with the actual image stored
            UIImage *rotatedImage = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:3]; //Rotate the image to get it in the correct orientation
//            CGImageRef newIm = CGImageCreateWithImageInRect([rotatedImage CGImage], CGRectMake(ImHeigth/4, ImWidth/4, ImHeigth/2,ImWidth/2));
            
            
            [self.listOfTrainingImages addObject:(__bridge id)([rotatedImage CGImage])];
            [FileStorageHelper writeImageToDisk:[rotatedImage CGImage]  withTitle:@"petita_prova2"];
//            []
            
            
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
        trainingImagesTVC.listOfImages = self.listOfTrainingImages; //TODO: passing a mutable array. Needs to be a fixed array?
    }
//        
//    } else if ([segue.identifier isEqualToString:@"show CameraVC"]) {
//        CameraViewController *cameraVC = (CameraViewController *) segue.destinationViewController;
//        cameraVC.templateName = self.templateName;
//        
//    }else if ([segue.identifier isEqualToString:@"show DetectPhotoVC"]) {
//        DetectPhotoViewController *detectPhotoVC = (DetectPhotoViewController *) segue.destinationViewController;
//        detectPhotoVC.picture = self.detectPhotoViewController.picture;
//        detectPhotoVC.originalImage = self.detectPhotoViewController.originalImage;
//        detectPhotoVC.detectView = self.detectPhotoViewController.detectView;
//        detectPhotoVC.templateName = self.templateName;
//        
//    }
    
}

//TODO: hog view of the detect frame


- (IBAction)learnAction:(id)sender
{
    
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
