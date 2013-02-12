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

@property (nonatomic, strong) IBOutlet UISwitch *hog;
@property (nonatomic, strong) IBOutlet UISwitch *pyramid;
@property (nonatomic, strong) IBOutlet UISwitch *numMaximums;



-(IBAction)hogAction:(id)sender;
-(IBAction)pyramidAction:(id)sender;
-(IBAction)numMaximumsAction:(id)sender;


//TODO: fix the done button

@end
