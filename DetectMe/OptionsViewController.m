//
//  OptionsViewController.m
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 24/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OptionsViewController.h"
#import "UIViewController+writeFiles.h"

@interface OptionsViewController ()

@end

@implementation OptionsViewController
@synthesize maxSize = _maxSize;
@synthesize interval = _interval;
@synthesize numImages = _numImages;
@synthesize scrollView = _scrollView;
@synthesize saveFile = _saveFile;
@synthesize detectPhoto = _detectPhoto;
@synthesize templateName = _templateName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.templateName = [[NSString alloc] init];

        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Finish" style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    
    self.detectPhoto = [[DetectPhotoViewController alloc] initWithNibName:@"DetectPhotoViewController" bundle:NULL];
    
    self.navigationItem.rightBarButtonItems=[NSArray arrayWithObjects:done, nil];
    self.title = @"Choose:";
    [self.scrollView setBackgroundColor:[UIColor clearColor]];
	[self.scrollView setCanCancelContentTouches:NO];
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
	self.scrollView.clipsToBounds = YES;		
	self.scrollView.scrollEnabled = YES;
	self.scrollView.pagingEnabled = NO;
    self.scrollView.frame = self.view.frame;
    [self.scrollView setContentSize:CGSizeMake(320, 416)];
    [self.view addSubview:self.scrollView];
    keyboardVisible = NO;
    size = [self.maxSize.text intValue];
    interval = (double) [self.interval.text intValue];
    numIm = [self.numImages.text intValue];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    
    //NSLog(@"%@", @"Registering for keyboard events...");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
	keyboardVisible = NO;
    
    
}

- (void) viewWillDisappear:(BOOL)animated {
    
	[super viewWillAppear:animated];
       //[self.spinner startAnimating];
    //self.spinner.hidden = NO;
    
    
    //[self.spinner stopAnimating];
    //self.spinner.hidden = YES;
    
    
	//NSLog(@"%@", @"Unregistering for keyboard events...");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void) keyboardDidShow:(NSNotification *)notif
{
    
	//NSLog(@"%@", @"Received UIKeyboardDidShowNotification");
	if (keyboardVisible) {
		//NSLog(@"%@", @"Keyboard is already visible.  Ignoring notifications.");
		return;
	}
	// The keyboard wasn't visible before
    NSLog(@"Resizing smaller for keyboard");
	
	// Get the origin of the keyboard when it finishes animating
	NSDictionary *info = [notif userInfo];
	NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
	
	// Get the top of the keyboard in view's coordinate system. 
	// We need to set the bottom of the scrollview to line up with it
    NSLog(@"1.  origeny= %f; height=%f",self.scrollView.bounds.origin.y,self.scrollView.frame.size.height);
    
	CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
	CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect viewFrame = self.scrollView.frame;
	viewFrame.size.height = keyboardTop+20;

	self.scrollView.frame = viewFrame;
    NSLog(@"2.  origeny= %f; height=%f",self.scrollView.bounds.origin.y,self.scrollView.frame.size.height);
    [self.scrollView scrollRectToVisible:CGRectMake(0, h-30, 320, keyboardTop) animated:YES];

	keyboardVisible = YES;
}


- (void) keyboardDidHide:(NSNotification *)notif {
	//NSLog(@"%@", @"Received UIKeyboardDidHideNotification");
	
	if (!keyboardVisible) {
		NSLog(@"%@", @"Keyboard already hidden.  Ignoring notification.");
		return;
	}
    self.scrollView.frame = self.view.frame;

	
	// The keyboard was visible
	//NSLog(@"%@", @"Resizing bigger with no keyboard");
    
	// Resize the scroll view back to the full size of our view
        //[self.scrollView scrollRectToVisible:CGRectMake(0, 0, 320, 372) animated:YES];
	keyboardVisible = NO;
    
}

-(IBAction)scrollTo:(id)sender{
    
    UITextField *text  = (UITextField *) sender;
    h = text.frame.origin.y;
}

-(IBAction)maxSizeAction:(id)sender{
    
    size = [self.maxSize.text intValue];
    if (size == 0 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Wrong size" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]; 
        [alert show];
    }
    
}

-(IBAction)intervalAction:(id)sender{
    int n = [self.interval.text intValue];
    interval = (double) n;
    if (n == 0 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Wrong interval" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]; 
        [alert show];
    }
}

-(IBAction)numImagesAction:(id)sender{
    int n = [self.numImages.text intValue];
    if (n == 0 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Wrong number of images" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]; 
        [alert show];
    }
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    BOOL isDir = YES;
    NSString * path = [NSString stringWithFormat:@"%@/TestImages",documentsDirectory];
    if ([filemng fileExistsAtPath:path isDirectory:&isDir]) {
        NSArray *items = [filemng contentsOfDirectoryAtPath:path error:NULL ];
        if (items.count < n) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:[NSString stringWithFormat:@"%d file/s in the test folder, please select a smaller number.",items.count] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]; 
            [alert show];
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"No files" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]; 
        [alert show];
    }
    numIm = (double)n;
}


-(IBAction)doneAction:(id)sender{
//    
//    if ((size<10) || (interval<1)) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"Wrong parameters" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]; 
//        [alert show];
//    }
//    else {
//        NSFileManager * filemng = [NSFileManager defaultManager];
//        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString * path = [NSString stringWithFormat:@"%@/TestImages",documentsDirectory];
//        NSString * path2 = [NSString stringWithFormat:@"%@/TestResults",documentsDirectory];
//
//        NSArray *items = [filemng contentsOfDirectoryAtPath:path error:NULL ];
//        NSMutableString *content = [NSMutableString stringWithCapacity:numIm+1];
//        BOOL isDir = YES;
//        if (![filemng fileExistsAtPath:path isDirectory:&isDir]) {
//            [filemng createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
//        }
//        if (![filemng fileExistsAtPath:path2 isDirectory:&isDir]) {
//            [filemng createDirectoryAtPath:path2 withIntermediateDirectories:YES attributes:nil error:NULL];
//        }
//        [content appendFormat:@"\%%Info;\tTemplate: %@\tNumImages: %d\tMaxSize: %d\tInterval: %d\n",self.templateName, numIm,size,(int)interval];
//
//        for (int i = 0; i<numIm; i++) {
//            NSString *str = [items objectAtIndex:i];
//
//            NSLog(@"%@",str);
//            UIImage *im = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:[items objectAtIndex:i]]];
//            NSArray *maxs = [self convPyraFeatFromFile:im templateName:self.templateName withMaxSize:size ];
//            for (int i = 0; i<maxs.count; i++) {
//                ConvolutionPoint *p = [maxs objectAtIndex:i];
//                [content appendFormat:@"%@\t%d\t%f\t%f\t%f\t%f\t%f\n",[str substringToIndex:str.length-4],i+1,p.score.doubleValue,p.xmin.doubleValue,p.ymin.doubleValue,p.xmax.doubleValue,p.ymax.doubleValue];
//
//            }
//
//        }
//        
//        if (self.saveFile.on) {
//            NSLog(@"features");
//            for (int i = 0; i<numIm; i++) {
//            int blocks[3];
//                UIImage *im = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:[items objectAtIndex:i]]];
//                double *feat = [self HOGOrientationWithDimension:blocks forImage:im.CGImage withPhoneOrientation:0];
//                [self writeFeatures:feat withSize:blocks withTitle:[documentsDirectory stringByAppendingFormat:@"/TestResults/%@-Features%@.txt",[[[NSDate date] description] substringToIndex:19],[items objectAtIndex:i]]];
//                NSUInteger width = CGImageGetWidth(im.CGImage); //#pixels ancho
//                NSUInteger height = CGImageGetHeight(im.CGImage); //#pixels alto
//                
//                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//                int bytesPerPixel = 4;
//                int bytesPerRow = bytesPerPixel * width;
//                int bitsPerComponent = 8;
//                UInt8 *pixels = (UInt8 *)malloc(height * width * 4);
//                
//                CGContextRef contextImage = CGBitmapContextCreate(pixels, width, height,
//                                                                  bitsPerComponent, bytesPerRow, colorSpace,
//                                                                  kCGImageAlphaPremultipliedLast| kCGBitmapByteOrder32Big );
//                CGColorSpaceRelease(colorSpace);
//                
//                CGContextDrawImage(contextImage, CGRectMake(0, 0, width, height), im.CGImage);
//                CGContextRelease(contextImage);
//                int sizeim[2] = {height,width};
//                [self writeImages:pixels withSize:sizeim withTitle:[documentsDirectory stringByAppendingFormat:@"/TestResults/%@-Image%@.txt",[[[NSDate date] description] substringToIndex:19],[items objectAtIndex:i]]];
//                
//                double *res = [self readTemplate:self.templateName];
//                double *w = res+3;
//                int r[3];
//                r[0]=(int)(*res);
//                r[1]=(int)(*(res+1));
//                r[2]=(int)(*(res+2));
//                double b = *(res+3+r[0]*r[1]*r[2]);
//                int sizeconv[2];
//                NSArray *conv = [self convTempFeat:w :r :b :im.CGImage :blocks :sizeconv orientation:0 saved:YES];
//                [self writeConvWithArray:conv withSize:sizeconv withTitle:[documentsDirectory stringByAppendingFormat:@"/TestResults/%@-Conv%@.txt",[[[NSDate date] description] substringToIndex:19],[items objectAtIndex:i]]];
//                free(feat);
//                free(pixels);
//                //free(c);
//
//            }
//        }
//        NSString *filename = [NSString stringWithFormat:@"%@-Results.txt",[[[NSDate date] description] substringToIndex:19]];
//        [content writeToFile:[path2 stringByAppendingPathComponent:filename] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
//        self.detectPhoto.picture.image = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:[items objectAtIndex:9]]];
//        self.detectPhoto.originalImage = [UIImage imageWithContentsOfFile:[path stringByAppendingPathComponent:[items objectAtIndex:9]]];
//        self.detectPhoto.title = [items objectAtIndex:0];
//        double f =self.detectPhoto.originalImage.size.height/self.detectPhoto.originalImage.size.width;
//        if (416 - 320*f < 0) {
//            [self.detectPhoto.picture setFrame:CGRectMake((320-416/f)/2, 0, 416/f, 416)];
//            [self.detectPhoto.detectView setFrame:CGRectMake((320-416/f)/2, 0, 416/f, 416)];
//            
//            
//        }
//        else {
//            [self.detectPhoto.picture setFrame:CGRectMake(0, (416-320*f)/2,320 , 320*f)];
//            [self.detectPhoto.detectView setFrame:CGRectMake(0, (416-320*f)/2,320 , 320*f)];
//            
//            
//        }
//        self.detectPhoto.templateName = self.templateName;
//        [self.navigationController pushViewController:self.detectPhoto animated:YES];
//        
//    }
//    NSLog(@"FINISH");
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
