//
//  TemplateViewController.m
//  TestDetector
//
//  Created by Dolores on 01/08/12.
//  Copyright (c) 2012 Dolores. All rights reserved.
//

#import "TemplateViewController.h"

@interface TemplateViewController ()

@end

@implementation TemplateViewController
@synthesize items = _items;
@synthesize scrollView = _scrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.items = [[NSArray alloc] init];
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [self.scrollView setBackgroundColor:[UIColor blackColor]];
	[self.scrollView setCanCancelContentTouches:NO];
	self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
	self.scrollView.clipsToBounds = YES;
	self.scrollView.scrollEnabled = YES;
    [self.view addSubview:self.scrollView];
    [self reloadButtons];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(void) reloadButtons{
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/Templates",documentsDirectory];
    self.items = [filemng contentsOfDirectoryAtPath:path error:NULL];
    for (UIView *subview in [self.scrollView subviews]){
        [subview removeFromSuperview];
    }
    
    //NSLog(@"items count %d",self.items.count);
    for(int i = 0; i < self.items.count; i++) {
       // NSLog(@"%@",[self.items objectAtIndex:i]);
		/*double *res = [self readTemplate:[self.items objectAtIndex:i]];
        double *w = res+3;
        int pix = 12;
        int r[3];
        r[0] = *res;
        r[1] = *(res+1);
        r[2] = *(res+2);
        UInt8 *pic = [self HOGpicture:w :pix :r[1] :r[0]];
        CGContextRef context;
        
        context = CGBitmapContextCreate(pic,
                                        r[1]*pix,
                                        r[0]*pix,
                                        8,
                                        r[1]*pix*4,
                                        CGColorSpaceCreateDeviceRGB(),
                                        kCGImageAlphaPremultipliedLast );
        CGImageRef ima = CGBitmapContextCreateImage (context);
        //UIImage* rawImage = [UIImage imageWithCGImage:ima ];
        CGContextRelease(context);
        UIImage *image= [UIImage imageWithCGImage:ima scale:1.0 orientation:UIImageOrientationUp];*/
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString *str = [self.items objectAtIndex:i];
        str = [str substringToIndex:str.length-4];
        [button setTitle:str forState:UIControlStateNormal] ;
        [button setBackgroundColor:[UIColor blackColor]];
         button.tag = i;
        //[button setImage:image forState:UIControlStateNormal];
            
            
    
		button.frame = CGRectMake(10+160*(i%2), 10+50*(floor((i/2))), 150, 40);
		[button addTarget:self
				   action:@selector(buttonAction:)
		 forControlEvents:UIControlEventTouchUpInside];
		[self.scrollView addSubview:button];
		/*free(res);
        free(pic);
        CGImageRelease(ima);*/
        
	}
    [self.scrollView setContentSize:CGSizeMake(320, 50*ceil((float)self.items.count/2) + 20)];


}
-(IBAction)buttonAction:(id)sender{
    UIButton *button = (UIButton *) sender;
    [self.delegate setTemplate:[self.items objectAtIndex:button.tag]];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
