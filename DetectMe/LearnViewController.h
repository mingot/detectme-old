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

#import "RectFrameLearnView.h"
#import "TrainingImagesTableViewController.h"

@interface LearnViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, TrainingImagesTableViewControlleDelegate>


@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prevLayer;
@property (nonatomic, strong) RectFrameLearnView *detectFrameView;


- (IBAction)learnAction:(id)sender;
- (IBAction)addAction:(id)sender;
- (IBAction)numberOfTrainingAction:(id)sender;

@end


