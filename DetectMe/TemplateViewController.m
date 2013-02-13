//
//  TemplateViewController.m
//  TestDetector
//
//  Created by Dolores on 01/08/12.
//  Copyright (c) 2012 Dolores. All rights reserved.
//

#import "TemplateViewController.h"


@implementation TemplateViewController


@synthesize items = _items;
@synthesize scrollView = _scrollView;


- (void)viewDidLoad
{
    [super viewDidLoad];

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
	}
    
    [self.scrollView setContentSize:CGSizeMake(320, 50*ceil((float)self.items.count/2) + 20)];
}


-(IBAction)buttonAction:(id)sender{
    UIButton *button = (UIButton *) sender;
    [self.delegate setTemplate:[self.items objectAtIndex:button.tag]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
