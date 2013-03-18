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


@protocol TagViewControllerDelegate <NSObject>

- (void) storeImage:(UIImage *)image thumbNail:(UIImage *)imageTN withBoundingoxes:(NSArray *)boxes inIndex:(int)index;

@end



@interface TagViewController : UIViewController <UIImagePickerControllerDelegate>


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet TagView *tagView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;

//image and boxes send throug Evaluatetvc
@property (strong, nonatomic) UIImage *initialImage;
@property (strong, nonatomic) NSMutableArray *initialBoxes;
@property int initialIndex;

@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSArray *paths;

@property (nonatomic, strong) id <TagViewControllerDelegate> delegate;


//Delete selected bounding box
-(IBAction)deleteAction:(id)sender;

-(void)createFilename;


@end
