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
@synthesize pyramidSwitch = _pyramidSwitch;
@synthesize numMaximumsSwitch = _numMaximumsSwitch;

@synthesize hog=_hog;
@synthesize pyramid=_pyramid;
@synthesize numMaximums=_numMaximums;


- (void)viewDidLoad
{
    self.hogSwitch.on = self.hog;
    self.pyramidSwitch.on = self.pyramid;
    self.numMaximumsSwitch.on = self.numMaximums;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Switches

- (IBAction)hogChangeAction:(UISwitch *)sender {
    [self.delegate setHOGValue:sender.on];
}

- (IBAction)pyramidChangeAction:(UISwitch *)sender {
    [self.delegate setPyramidValue:sender.on];
}

- (IBAction)numMaximumsChangeAction:(UISwitch *)sender {
    [self.delegate setNumMaximums:sender.on];

}


//- (void)viewDidUnload {
//    [self setHogSwitch:nil];
//    [self setPyramidSwitch:nil];
//    [self setNumMaximumsSwitch:nil];
//    [super viewDidUnload];
//}

@end
