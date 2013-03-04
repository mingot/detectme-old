//
//  ShowTrainingImageViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 21/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "ShowTrainingImageViewController.h"
#import "UIImage+Brightness.h"
#import "UIImage+HOG.h"
#import "ImageProcessingHelper.h"




@interface ShowTrainingImageViewController()



@end


@implementation ShowTrainingImageViewController

@synthesize imageView = _imageView;
@synthesize image = _image;



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [self.image brightImage:1];
    
    
    UIBarButtonItem *hogButton = [[UIBarButtonItem alloc] initWithTitle:@"HOG" style:UIBarButtonItemStyleBordered target:self action:@selector(hogAction:)];
    
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects: hogButton, nil];
}



- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}


- (IBAction)hogAction:(id)sender
{
    [self.imageView setImage:[self.image convertToHogImage]];
}


@end
