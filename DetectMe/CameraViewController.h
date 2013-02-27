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
    double *templateWeights;
    
}


@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prevLayer;

@property (nonatomic, weak) IBOutlet UIImageView *HOGimageView;
@property (nonatomic, weak) IBOutlet DetectView *detectView;

@property (nonatomic, strong) NSString *templateName;

@property (weak, nonatomic) IBOutlet UISlider *detectionThresholdSliderButton;

@end
