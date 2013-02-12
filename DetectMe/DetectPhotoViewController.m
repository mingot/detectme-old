//
//  DetectPhotoViewController.m
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "DetectPhotoViewController.h"
#import "UIViewController+writeFiles.h"
#import "ConvolutionHelper.h"
#import "ImageProcessingHelper.h"


static inline double min(double x, double y) { return (x <= y ? x : y); }
static inline double max(double x, double y) { return (x <= y ? y : x); }
static inline int min_int(int x, int y) { return (x <= y ? x : y); }
static inline int max_int(int x, int y) { return (x <= y ? y : x); }


@implementation DetectPhotoViewController

@synthesize picture = _picture;
@synthesize originalImage = _originalImage;
@synthesize templateName = _templateName;
@synthesize detectView = _detectView;
@synthesize hogFeature = _hogFeature;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.picture = [[UIImageView alloc]init];
        self.originalImage = [[UIImage alloc] init];
        self.templateName = [[NSString alloc] init];
        self.hogFeature = [[HOGFeature alloc] initWithNumberCells:8 ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.picture.frame = CGRectMake(0, 0, 320, 416);

    self.picture.backgroundColor = [UIColor blackColor];
    //UIBarButtonItem *hog = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settings:)];
    UIBarButtonItem *gradient = [[UIBarButtonItem alloc] initWithTitle:@"HOG" style:UIBarButtonItemStylePlain target:self action:@selector(HOGAction:)];
    UIBarButtonItem *photo = [[UIBarButtonItem alloc] initWithTitle:@"Detect" style:UIBarButtonItemStylePlain target:self action:@selector(detect:)];
    
    
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:gradient,photo, nil];
    self.detectView = [[DetectView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)];
    isHog = NO;
    
    
    [self.view addSubview:self.picture];
    [self.view addSubview:self.detectView];
    self.detectView.hidden = NO;

    templateWeights = [self readTemplate:self.templateName];
    
}
-(void)viewDidAppear:(BOOL)animated{
    // NSLog(@"hay viewcontrolles = %d",self.navigationController.viewControllers.count);
    
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [self.detectView reset];
    [self.detectView setNeedsDisplay];
    self.title = @"";
    
    
}


- (IBAction)detect:(id)sender{
    NSLog(@"detect!");
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath1 = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"hog.txt"]];
    NSString *filePath2 = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"convolution.txt"]];
    NSString *filePath3 = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:@"totaltime.txt"]];
    if(![filemng fileExistsAtPath:filePath1]){
        [filemng createFileAtPath:filePath1 contents:nil attributes:nil];
        NSLog(@"1 created");
    }
    if(![filemng fileExistsAtPath:filePath2]){
        [filemng createFileAtPath:filePath2 contents:nil attributes:nil];
        NSLog(@"2 created");

    }
    if(![filemng fileExistsAtPath:filePath3]){
        [filemng createFileAtPath:filePath3 contents:nil attributes:nil];
        NSLog(@"3 created");

    }

   NSLog(@"Orientation: %d",self.picture.image.imageOrientation);

    
    [ConvolutionHelper convPyraFeat:self.originalImage
                       withTemplate:templateWeights
                       inDetectView:self.detectView
                     withHogFeature:self.hogFeature
                           pyramids:10];
    
    self.detectView.frame = self.picture.frame;
    
    [self.detectView performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];

}


-(IBAction)HOGAction:(id)sender{
    if (isHog) {
        self.picture.image = self.originalImage;
        isHog = NO;
        
    }else {
        int blocks[3];
        double *feat = NULL;
        
        feat = [self.hogFeature HOGOrientationWithDimension:blocks forImage:[ImageProcessingHelper resizeImage:self.picture.image.CGImage withRect:230] withPhoneOrientation:self.originalImage.imageOrientation];
        
        int pix = 12;
        UInt8 *pic = [self.hogFeature HOGpicture:feat :pix :blocks[1] :blocks[0]];
        
        CGContextRef context;
        context = CGBitmapContextCreate(pic,
                                        blocks[1]*pix,
                                        blocks[0]*pix,
                                        8,
                                        blocks[1]*pix*4,
                                        CGColorSpaceCreateDeviceRGB(),
                                        kCGImageAlphaPremultipliedLast );
        
        CGImageRef ima = CGBitmapContextCreateImage (context);
        //UIImage* rawImage = [UIImage imageWithCGImage:ima ];  
        CGContextRelease(context); 
        UIImage *image= [UIImage imageWithCGImage:ima scale:1.0 orientation:UIImageOrientationUp];
        //self.originalImage = self.picture.image;
        self.picture.image = image;
        isHog = YES;
    }
}

-(double *)readTemplate:(NSString *)filename //return pointer to template from filename
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/Templates/%@",documentsDirectory,filename];
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *file = [content componentsSeparatedByString:@"\n"];
    
    double *r = malloc((file.count)*sizeof(double));
    for (int i=0; i<file.count; i++) {
        NSString *str = [file objectAtIndex:i];
        *(r+i) = [str doubleValue];
    }
    
    return r;
}


-(IBAction)settings:(id)sender{
    
}

-(void)setPhotoFromCamera:(BOOL)value{
    photoFromCamera = value;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
