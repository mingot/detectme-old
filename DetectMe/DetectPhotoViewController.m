//
//  DetectPhotoViewController.m
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "DetectPhotoViewController.h"
#import "ConvolutionHelper.h"
#import "ImageProcessingHelper.h"
#import "FileStorageHelper.h"
#import "UIImage+HOG.h"



static inline double min(double x, double y) { return (x <= y ? x : y); }
static inline double max(double x, double y) { return (x <= y ? y : x); }
static inline int min_int(int x, int y) { return (x <= y ? x : y); }
static inline int max_int(int x, int y) { return (x <= y ? y : x); }


@implementation DetectPhotoViewController

@synthesize picture = _picture;
@synthesize originalImage = _originalImage;
@synthesize templateName = _templateName;
@synthesize detectView = _detectView;
@synthesize svmClassifier = _svmClassifier;


- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.picture.frame = CGRectMake(0, 0, 320, 416);
    

    self.picture.backgroundColor = [UIColor blackColor];
    //UIBarButtonItem *hog = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings:)];
    UIBarButtonItem *gradient = [[UIBarButtonItem alloc] initWithTitle:@"HOG" style:UIBarButtonItemStylePlain target:self action:@selector(HOGAction:)];
    UIBarButtonItem *photo = [[UIBarButtonItem alloc] initWithTitle:@"Detect" style:UIBarButtonItemStylePlain target:self action:@selector(detect:)];
    
    
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:gradient,photo, nil];
    self.detectView = [[DetectView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    isHog = NO;
    
    
    [self.view addSubview:self.picture];
    [self.view addSubview:self.detectView];
    self.detectView.hidden = NO;

    templateWeights = [FileStorageHelper readTemplate:self.templateName];
    self.svmClassifier = [[Classifier alloc] initWithTemplateWeights:templateWeights];
}


-(void)viewDidDisappear:(BOOL)animated{
    [self.detectView reset];
    [self.detectView setNeedsDisplay];
    self.title = @"";
    
}


- (IBAction)detect:(id)sender{
    NSLog(@"detect!");
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath1 = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"hog.txt"]];
    NSString *filePath2 = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"convolution.txt"]];
    NSString *filePath3 = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"totaltime.txt"]];
    if(![filemng fileExistsAtPath:filePath1]){
        [filemng createFileAtPath:filePath1 contents:nil attributes:nil];
        NSLog(@"1 created");
    }
    if(![filemng fileExistsAtPath:filePath2]){
        [filemng createFileAtPath:filePath2 contents:nil attributes:nil];
        NSLog(@"2 created");

    }
    if(![filemng fileExistsAtPath:filePath3]){
        [filemng createFileAtPath:filePath3 contents:nil attributes:nil];
        NSLog(@"3 created");

    }

   NSLog(@"Orientation: %d",self.picture.image.imageOrientation);
    
    NSArray *nmsArray = [self.svmClassifier detect:self.originalImage minimumThreshold:-1 pyramids:10 usingNms:YES];
    
    [self.detectView setCorners:nmsArray];
    self.detectView.frame = self.picture.frame;
    
    [self.detectView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];

}


-(IBAction)HOGAction:(id)sender{
    if (isHog) {
        self.picture.image = self.originalImage;
        isHog = NO;
        
    }else {
        CGImageRef img = [ImageProcessingHelper resizeImage:self.picture.image.CGImage withRect:230];
        UIImage *image = [[UIImage imageWithCGImage:img] convertToHogImage];
        //self.originalImage = self.picture.image;
        self.picture.image = image;
        isHog = YES;
    }
}


//TODO: does not bring to anywhere
-(IBAction)settings:(id)sender{
    
}

-(void)setPhotoFromCamera:(BOOL)value{
    photoFromCamera = value;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


@end
