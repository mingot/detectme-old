//
//  EvaluateTVC.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 14/03/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagViewController.h"
#import "Classifier.h"


@interface EvaluateTVC : UITableViewController <TagViewControllerDelegate>


@property (nonatomic, strong) TrainingSet *trainingSet;

@end
