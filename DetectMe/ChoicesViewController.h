//
//  ChoicesViewController.h
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TemplateViewController.h"
#import "CameraViewController.h"
#import "DetectPhotoViewController.h"
#import "OptionsViewController.h"



@interface ChoicesViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, TemplateViewControllerDelegate>


@property (strong, nonatomic) TemplateViewController *templateViewController;
@property (strong,nonatomic) CameraViewController *cameraViewController;
@property (strong,nonatomic) DetectPhotoViewController *detectPhotoViewController;
@property (strong,nonatomic) OptionsViewController *optionsViewController;

@property (strong, nonatomic) NSString *templateName;

@property (strong, nonatomic) IBOutlet UILabel *label;

// Button Actions
-(IBAction)photoAction:(id)sender;


@end
