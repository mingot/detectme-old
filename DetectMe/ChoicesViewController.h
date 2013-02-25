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



@interface ChoicesViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, TemplateTableViewControllerDelegate>


@property (strong,nonatomic) OptionsViewController *optionsViewController;
@property (strong, nonatomic) NSString *templateName;
//@property (strong, nonatomic) double *templateWeights;
@property (strong, nonatomic) IBOutlet UILabel *selectedTemplateLabel;

-(IBAction)photoAction:(id)sender;

@end
