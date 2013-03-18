//
//  DetectPhotoViewController.m
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "DetectPhotoViewController.h"
#import "ConvolutionHelper.h"
#import "FileStorageHelper.h"
#import "UIImage+HOG.h"
#import "UIImage+Resize.h"


static inline double min(double x, double y) { return (x <= y ? x : y); }
static inline double max(double x, double y) { return (x <= y ? y : x); }
static inline int min_int(int x, int y) { return (x <= y ? x : y); }
static inline int max_int(int x, int y) { return (x <= y ? y : x); }


@implementation DetectPhotoViewController

@synthesize imageView = _picture;
@synthesize detectView = _detectView;
@synthesize originalImage = _originalImage;
@synthesize templateName = _templateName;
@synthesize svmClassifier = _svmClassifier;


- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *hogButton = [[UIBarButtonItem alloc] initWithTitle:@"HOG" style:UIBarButtonItemStylePlain target:self action:@selector(HOGAction:)];
    UIBarButtonItem *detectButton = [[UIBarButtonItem alloc] initWithTitle:@"Detect" style:UIBarButtonItemStylePlain target:self action:@selector(detect:)];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:hogButton,detectButton, nil];
    
    self.imageView.image = self.originalImage;
    isHog = NO;
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.detectView];

    //Load the classifier
    self.svmClassifier = [[Classifier alloc] initWithTemplateWeights:[FileStorageHelper readTemplate:self.templateName]];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [self.detectView reset];
    [self.detectView setNeedsDisplay];
}


- (IBAction)detect:(id)sender
{
    //TODO: not hard code the resizing image.
    NSArray *nmsArray = [self.svmClassifier detect:[self.imageView.image scaleImageTo:480.0/2048] minimumThreshold:-1 pyramids:10 usingNms:YES deviceOrientation:UIImageOrientationUp];
    
    for(ConvolutionPoint *cp in nmsArray)
        NSLog(@"xmin:%f, xmax:%f, ymin:%f, ymax:%f", cp.xmin, cp.xmax, cp.ymin, cp.ymax);
    
    NSLog(@"IMAGE SIZE: h:%f, w:%f", self.imageView.image.size.height, self.imageView.image.size.width);
    
    [self.detectView setCorners:nmsArray];
    [self.detectView setNeedsDisplay];
}


-(IBAction)HOGAction:(id)sender{
    if (isHog) {
        self.imageView.image = self.originalImage;
        isHog = NO;
        
    }else {
//        CGImageRef img = [ImageProcessingHelper resizeImage:self.picture.image.CGImage withRect:230];
        UIImage *image = [self.imageView.image convertToHogImage];
        //self.originalImage = self.picture.image;
        self.imageView.image = image;
        isHog = YES;
    }
}


@end
