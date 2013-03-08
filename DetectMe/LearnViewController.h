//
//  LearnViewController.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 20/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#import "TrainingImagesTableViewController.h"
#import "Classifier.h"
#import "DetectView.h"


@interface LearnViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, TrainingImagesTableViewControlleDelegate>


@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prevLayer;


@property (nonatomic, strong) Classifier *svmClassifier;
@property (nonatomic, strong) TrainingSet *trainingSet;

@property (weak, nonatomic) IBOutlet DetectView *detectView;




- (IBAction)learnAction:(id)sender;
- (IBAction)addAction:(id)sender;
- (IBAction)numberOfTrainingAction:(id)sender;

@end


