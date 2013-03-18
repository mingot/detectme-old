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
#import <CoreLocation/CoreLocation.h>


#import "DetectView.h"
#import "SettingsViewController.h"
#import "Classifier.h"


@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate, SettingsViewControllerDelegate, CLLocationManagerDelegate>
{
    //settings
    BOOL hogOnScreen;
    int numMax;
}


//model properties
@property (nonatomic, strong) NSString *templateName;
@property (nonatomic,strong) Classifier *svmClassifier;
@property int numPyramids;
@property double maxDetectionScore;

//Core Location
@property (nonatomic, strong) CLLocationManager *locMgr;

//AVCapture
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *prevLayer;

//self views
@property (nonatomic, weak) IBOutlet UIImageView *HOGimageView;
@property (nonatomic, weak) IBOutlet DetectView *detectView;

@property (weak, nonatomic) IBOutlet UISlider *detectionThresholdSliderButton;



@end
