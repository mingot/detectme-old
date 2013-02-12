//
//  OptionsViewController.h
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetectPhotoViewController.h"

@interface OptionsViewController : UIViewController <UIActionSheetDelegate>{
    
    IBOutlet UIScrollView * _scrollView;
    IBOutlet UITextField * _maxSize;
    IBOutlet UITextField * _interval;
    IBOutlet UITextField * _numImages;
    IBOutlet UISwitch * _saveFile;
    BOOL keyboardVisible;
    int size;
    double interval;
    int numIm;
    float h;
    
    DetectPhotoViewController * _detectPhoto;
    
    NSString *_templateName;
}
@property (strong, nonatomic)     IBOutlet UIScrollView * scrollView;
@property (strong, nonatomic) IBOutlet UITextField *maxSize;
@property (strong, nonatomic) IBOutlet UITextField *interval;
@property (strong, nonatomic) IBOutlet UITextField *numImages;
@property (strong, nonatomic) IBOutlet UISwitch * saveFile;
@property (strong, nonatomic) DetectPhotoViewController * detectPhoto;
@property (strong, nonatomic) NSString *templateName;
           

-(IBAction)maxSizeAction:(id)sender;
-(IBAction)intervalAction:(id)sender;
-(IBAction)numImagesAction:(id)sender;
-(IBAction)scrollTo:(id)sender;
-(IBAction)doneAction:(id)sender;

@end
