//
//  DetectPhotoViewController.h
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetectView.h"
#import "HOGFeature.h"

@interface DetectPhotoViewController : UIViewController

{
    UIImageView *   _picture;
    DetectView  *   _detectView;
    UIImage     *   _originalImage;
    BOOL             isHog;
    BOOL             photoFromCamera;
    NSString * _templateName;
    double *templateWeights;
}
@property (strong,nonatomic) UIImageView    *picture;
@property (strong,nonatomic) DetectView     *detectView;
@property (strong,nonatomic) UIImage        *originalImage;
@property (strong, nonatomic) NSString *templateName;

@property (nonatomic, strong) HOGFeature *hogFeature;


-(void)setPhotoFromCamera:(BOOL)value;
-(IBAction)detect:(id)sender;
-(IBAction)HOGAction:(id)sender;
-(IBAction)settings:(id)sender;


@end
