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
- (void) setPyramidValue:(BOOL) value;
- (void) setNumMaximums:(BOOL) value;

@end


@interface SettingsViewController : UIViewController

@property (nonatomic, strong) id <SettingsViewControllerDelegate> delegate;

@property BOOL hog;
@property BOOL pyramid;
@property BOOL numMaximums;


@property (weak, nonatomic) IBOutlet UISwitch *hogSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *pyramidSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *numMaximumsSwitch;



- (IBAction)hogChangeAction:(UISwitch *)sender;
- (IBAction)pyramidChangeAction:(UISwitch *)sender;
- (IBAction)numMaximumsChangeAction:(UISwitch *)sender;



@end
