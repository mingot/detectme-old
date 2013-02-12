//
//  TemplateViewController.h
//  TestDetector
//
//  Created by Dolores on 01/08/12.
//  Copyright (c) 2012 Dolores. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TemplateViewControllerDelegate <NSObject>
//add methods to pass info back
-(void) setTemplate:(NSString *) name;


@end

@interface TemplateViewController : UIViewController{
    NSArray *_items;
    UIScrollView *_scrollView;
}
@property (nonatomic, strong) id <TemplateViewControllerDelegate> delegate;

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UIScrollView *scrollView;


-(void) reloadButtons;
-(IBAction)buttonAction:(id)sender;
@end
