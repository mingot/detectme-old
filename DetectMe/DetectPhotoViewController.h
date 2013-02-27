//
//  DetectPhotoViewController.h
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetectView.h"



@interface DetectPhotoViewController : UIViewController
{
    BOOL isHog;
    @public BOOL photoFromCamera;
    double *templateWeights;
}

@property (strong,nonatomic) UIImageView *picture;
@property (strong,nonatomic) UIImage *originalImage;
@property (strong,nonatomic) DetectView *detectView;
@property (strong, nonatomic) NSString *templateName;



-(void)setPhotoFromCamera:(BOOL)value;
-(IBAction)detect:(id)sender;
-(IBAction)HOGAction:(id)sender;
-(IBAction)settings:(id)sender;


@end
