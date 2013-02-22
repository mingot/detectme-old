//
//  ShowTrainingImageViewController.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 21/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "ShowTrainingImageViewController.h"


@implementation ShowTrainingImageViewController

@synthesize imageView = _imageView;
@synthesize image = _image;



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
	self.imageView.image = self.image;
}



- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}

@end
