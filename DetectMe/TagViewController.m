//
//  AnnotationToolViewController.m
//  AnnotationTool
//
//  Created by Dolores Blanco Almazán on 31/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>

#import "TagViewController.h"
#import "UIImage+Resize.h"
#import "ConvolutionHelper.h"

#define UPPERBOUND 0
#define LOWERBOUND 504
#define LEFTBOUND 0
#define RIGHTBOUND 320

#define IMAGES 0
#define THUMB 1
#define OBJECTS 2


@implementation TagViewController

@synthesize scrollView = _scrollView;
@synthesize tagView = _tagView;
@synthesize imageView = _imageView;
@synthesize initialImage = _image;
@synthesize initialBoxes = _initialBoxes;
@synthesize initialIndex = _initialIndex;

@synthesize filename = _filename;
@synthesize paths = _paths;
@synthesize svmClassifier = _svmClassifier;
@synthesize delegate = _delegate;



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    srand(time(NULL));
    
    //Navigation buttons
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete Box" style:UIBarButtonItemStylePlain target:self action:@selector(deleteAction:)];
    UIBarButtonItem *detectButton = [[UIBarButtonItem alloc] initWithTitle:@"Detect" style:UIBarButtonItemStylePlain target:self action:@selector(detectAction:)];
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:deleteButton,detectButton, nil];
    
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *doc = [NSString  stringWithFormat:@"%@/labelme/%@",documentsDirectory,@"Ramon"];
    self.paths = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%@/iphoneimages",doc],[NSString stringWithFormat:@"%@/galleryimages",doc],[NSString stringWithFormat:@"%@/objects",doc], nil];
    
    self.filename = [[NSString alloc] init];
    
    //scrollView initialization
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(LEFTBOUND, UPPERBOUND, RIGHTBOUND, LOWERBOUND)];
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
	[self.scrollView setCanCancelContentTouches:NO];
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
	self.scrollView.clipsToBounds = YES; // default is NO, we want to restrict drawing within our scrollview
	self.scrollView.scrollEnabled = YES;    
    
    //tagView initialization
    self.tagView = [[TagView alloc] initWithFrame:CGRectMake(LEFTBOUND, UPPERBOUND, RIGHTBOUND, LOWERBOUND)];
    [self.scrollView setContentSize:CGSizeMake(RIGHTBOUND, LOWERBOUND)];
    self.imageView.frame = self.scrollView.frame;
    
    [self.scrollView addSubview:self.imageView];
    [self.scrollView addSubview:self.detectView];
    [self.scrollView addSubview:self.tagView];
    [self.view addSubview:self.scrollView];

    //Push the modal for selecting the picture from the camera if not image is set
    if(self.initialImage == nil){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:picker animated:YES];
    }else{
        self.imageView.image = self.initialImage;
        self.tagView.boxes = self.initialBoxes;
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    //When returning to the previous window
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        
        //Get ThumbNail image
        [self.tagView setSelectedBox:-1];
        [self.tagView setNeedsDisplay];
        UIGraphicsBeginImageContext(self.scrollView.frame.size);
        [self.scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        UIImage *thumbnailImage = [viewImage thumbnailImage:100 transparentBorder:0 cornerRadius:0 interpolationQuality:0];
        
        //Send the images to store
        [self.delegate storeImage:self.imageView.image thumbNail:thumbnailImage withBoundingoxes:[NSArray arrayWithArray:self.tagView.boxes] inIndex:self.initialIndex];
        
    }
    [super viewWillDisappear:animated];
}

#pragma mark
#pragma mark - UIImage Picker Controller

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    self.imageView.image = image;
    [picker dismissModalViewControllerAnimated:YES];
}


-(void)createFilename
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    int icnt;
 
    NSString *cnt=[NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/labelme/%@/counter_file.txt",documentsDirectory,@"Ramon"] encoding:NSUTF8StringEncoding error:NULL];
    icnt = [cnt intValue] +1;
        
    NSLog(@"Count file: %d",icnt);
        
    cnt= [NSString stringWithString:[NSString stringWithFormat: @"%d",icnt]];
    [cnt writeToFile:[NSString stringWithFormat:@"%@/labelme/%@/counter_file.txt",documentsDirectory,@"Ramon"] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    
    self.filename = [NSString stringWithFormat:@"%@-%@-%d.jpg", [[[NSDate date] description] substringToIndex:19],@"Ramon", icnt];
}



#pragma mark
#pragma mark - Navigation buttons actions

-(IBAction)deleteAction:(id)sender
{
    if((self.tagView.boxes.count>0) && (self.tagView.selectedBox != -1))
    {
        [self.tagView.boxes removeObjectAtIndex:self.tagView.selectedBox];
        self.tagView.selectedBox = -1;
        [self.tagView setNeedsDisplay];
    }
}


-(IBAction)detectAction:(id)sender
{
    //TODO: not hard code the resizing image.
    NSArray *nmsArray = [self.svmClassifier detect:[self.imageView.image scaleImageTo:480.0/2048] minimumThreshold:-1 pyramids:10 usingNms:YES deviceOrientation:UIImageOrientationUp];
    
    for(ConvolutionPoint *cp in nmsArray)
        NSLog(@"xmin:%f, xmax:%f, ymin:%f, ymax:%f", cp.xmin, cp.xmax, cp.ymin, cp.ymax);
    
    NSLog(@"IMAGE SIZE: h:%f, w:%f", self.imageView.image.size.height, self.imageView.image.size.width);
    
    [self.detectView setCorners:nmsArray];
    [self.detectView setNeedsDisplay];

}


@end
