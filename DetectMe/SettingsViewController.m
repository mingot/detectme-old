//
//  SettingsViewController.m
//  DetectIm
//
//  Created by Dolores Blanco Almazán on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController


@synthesize delegate = _delegate;
@synthesize hogSwitch = _hogSwitch;
@synthesize numMaximumsSwitch = _numMaximumsSwitch;
@synthesize pyramidLabel = _pyramidLabel;
@synthesize pyramidStepper = _pyramidStepper;


// TODO: Can it be done in an easier way?
@synthesize hog = _hog;
@synthesize numMaximums = _numMaximums;
@synthesize numPyramids = _numPyramids;

- (void)viewDidLoad
{
    self.hogSwitch.on = self.hog;
    self.numMaximumsSwitch.on = self.numMaximums;
    self.pyramidStepper.maximumValue = 15;
    self.pyramidStepper.minimumValue = 1;
    self.pyramidStepper.value = self.numPyramids;
    self.pyramidLabel.text = [NSString stringWithFormat:@"%d", (int) self.pyramidStepper.value];
}

#pragma mark -
#pragma mark Switches

- (IBAction)hogChangeAction:(UISwitch *)sender {
    [self.delegate setHOGValue:sender.on];
}


- (IBAction)numMaximumsChangeAction:(UISwitch *)sender {
    [self.delegate setNumMaximums:sender.on];
}


- (IBAction)pyramidStepperAction:(UIStepper *)sender {
    [self.delegate setNumPyramidsFromDelegate:self.pyramidStepper.value];
    self.pyramidLabel.text = [NSString stringWithFormat:@"%d", (int) self.pyramidStepper.value];
}



- (void)viewDidUnload {
    [self setPyramidLabel:nil];
    [self setPyramidStepper:nil];
    [super viewDidUnload];
}
@end
