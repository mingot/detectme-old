//
//  trainingImagesTableViewController.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 21/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TrainingImagesTableViewControlleDelegate <NSObject>

- (void) setPhotos:(NSArray *) photos;

@end


@interface TrainingImagesTableViewController : UITableViewController

@property (strong, nonatomic) NSArray *listOfImages;
@property (strong, nonatomic) id <TrainingImagesTableViewControlleDelegate> delegate;

@end
