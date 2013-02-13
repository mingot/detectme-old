//
//  ChoicesViewController.h
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "DetectPhotoViewController.h"
#import "OptionsViewController.h"
#import "TemplateTableViewController.h"



@interface FakePhotoViewController:NSObject //Auxiliar class to pass information to the DetectPhotoVC

@property (strong,nonatomic) UIImageView *picture;
@property (strong,nonatomic) UIImage *originalImage;
@property (strong,nonatomic) DetectView *detectView;
@property BOOL photoFromCamera;

@end


@interface ChoicesViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, TemplateTableViewControllerDelegate>

@property (strong,nonatomic) FakePhotoViewController *detectPhotoViewController;
@property (strong,nonatomic) OptionsViewController *optionsViewController;
@property (strong, nonatomic) NSString *templateName;
@property (strong, nonatomic) IBOutlet UILabel *selectedTemplateLabel;

-(IBAction)photoAction:(id)sender;

@end
