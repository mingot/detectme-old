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

@property (strong, nonatomic) IBOutlet TagView *tagView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) id <TagViewControllerDelegate> delegate;

//Buttons
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;


@property (strong, nonatomic) IBOutlet UITextField *label;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;



//color array to select from the bounding boxes
@property (retain, nonatomic) NSArray *colorArray;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSArray *paths;


//-(IBAction)addAction:(id)sender;
//-(IBAction)labelFinish:(id)sender;
//-(IBAction)labelAction:(id)sender;

//Delete selected bounding box
-(IBAction)deleteAction:(id)sender;

-(void)saveImage;
-(void)saveDictionary;
-(void)createFilename;

@end
