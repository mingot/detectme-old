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


@interface TestImage : NSObject

@property (nonatomic, strong) UIImage *imageHQ;
@property (nonatomic, strong) UIImage *imageTN;
@property (nonatomic, strong) NSArray *boxes;
@property (nonatomic, strong) NSString *imageTitle;


-(void) saveAtPath:(NSString *)path;

-(void) deleteAtPath:(NSString *)path;

+ (TestImage *) getImage:(NSString *)imageTitle formPath:(NSString *)path;

@end



@interface EvaluateTVC : UITableViewController <TagViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray *testImages;
@property (nonatomic, strong) NSString *path;

@end
