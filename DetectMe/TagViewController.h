//
//  TagViewController.h
//  LabelMe_work
//
//  Created by David Way on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagView.h"
#import "Box.h"
#import "Classifier.h"


@protocol TagViewControllerDelegate <NSObject>

- (void) setImage:(UIImage *)image withBoundingBoxes:(NSArray *) Boxes;

@end



@interface TagViewController : UIViewController <UIImagePickerControllerDelegate>


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet TagView *tagView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;


@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSArray *paths;

@property (nonatomic, strong) id <TagViewControllerDelegate> delegate;


//Delete selected bounding box
-(IBAction)deleteAction:(id)sender;

-(void)saveImage;
-(void)saveDictionary;
-(void)createFilename;

@end
