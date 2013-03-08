//
//  SettingsViewController.h
//  DetectIm
//
//  Created by Dolores Blanco Almazán on 19/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


//Delegate that has to be implemented by the camera view controller
@protocol SettingsViewControllerDelegate <NSObject>

- (void) setHOGValue:(BOOL) value;
- (void) setNumMaximums:(BOOL) value;
- (void) setNumPyramidsFromDelegate: (double) value;

@end


@interface SettingsViewController : UIViewController

@property (nonatomic, strong) id <SettingsViewControllerDelegate> delegate;

@property BOOL hog;
@property BOOL numMaximums;
@property int numPyramids;

@property (weak, nonatomic) IBOutlet UISwitch *hogSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *numMaximumsSwitch;
@property (weak, nonatomic) IBOutlet UILabel *pyramidLabel;
@property (weak, nonatomic) IBOutlet UIStepper *pyramidStepper;



- (IBAction)hogChangeAction:(UISwitch *)sender;
- (IBAction)numMaximumsChangeAction:(UISwitch *)sender;
- (IBAction)pyramidStepperAction:(UIStepper *)sender;



@end
