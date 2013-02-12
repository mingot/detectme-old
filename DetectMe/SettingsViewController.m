//
//  SettingsViewController.m
//  DetectIm
//
//  Created by Dolores Blanco Almazán on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize delegate;
@synthesize hog = _hog;
@synthesize pyramid = _pyramid;
@synthesize numMaximums = _numMaximums;


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    self.navigationItem.rightBarButtonItem = doneButton;

    self.navigationItem.hidesBackButton = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Switches

-(IBAction)hogAction:(UISwitch *)sender{

    [self.delegate setHOGValue:self.hog.on];
}

-(IBAction)pyramidAction:(id)sender{

    [self.delegate setPyramidValue:self.pyramid.on];
}
-(IBAction)numMaximumsAction:(id)sender{

    [self.delegate setNumMaximums:self.numMaximums.on];

}




@end
