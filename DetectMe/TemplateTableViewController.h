//
//  TemplateTableViewController.h
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 12/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol TemplateTableViewControllerDelegate <NSObject>
//add methods to pass info back
-(void) setTemplate:(NSString *) name;

@end


@interface TemplateTableViewController : UITableViewController

@property (nonatomic, strong) id <TemplateTableViewControllerDelegate> delegate;

@end






