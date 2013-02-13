//
//  CameraViewController.h
//  DetectIm
//
//  Created by Dolores Blanco Almazán on 13/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h>

#import "DetectView.h"
#import "SettingsViewController.h"
#import "HOGFeature.h"


@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, SettingsViewControllerDelegate>
{

    int sizeImage;
    double interval;
    
    //settings
    BOOL hogOnScreen;
    BOOL pyramid;
    int numMax;
    
    BOOL cameraRoll;
    BOOL printResults;
    BOOL fullScreen;
    BOOL fileWritten;
    BOOL saving;
    double *templateWeights;
    
}


@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) UIImageView *HOGimageView;
@property (nonatomic, strong) UIImageView *resultsImageView;

@property (nonatomic, strong) CALayer *customLayer;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prevLayer;
@property (nonatomic, strong) DetectView *detectView;

@property (nonatomic, strong) NSString *templateName;
@property (nonatomic, strong) HOGFeature *hogFeature;


//-(void)findMax:(double *)c size:(int *)size numMax:  (int)nmax scores: (double *)scores results:(int *)results;


@end
