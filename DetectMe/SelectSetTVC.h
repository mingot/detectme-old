//
//  SelectSetTVC.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 19/03/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Classifier.h"

@interface SelectSetTVC : UITableViewController

@property (strong, nonatomic) NSMutableArray *setsList;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) Classifier *svmClassifier;


@end
