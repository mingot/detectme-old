//
//  DetectPhotoViewController.h
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetectView.h"
#import "Classifier.h"



@interface DetectPhotoViewController : UIViewController
{
    BOOL isHog;
}

@property (strong,nonatomic) IBOutlet UIImageView *imageView;
@property (strong,nonatomic) IBOutlet DetectView *detectView;
@property (strong,nonatomic) UIImage *originalImage;

@property (strong, nonatomic) Classifier *svmClassifier;


-(IBAction)detect:(id)sender;
-(IBAction)HOGAction:(id)sender;


@end
