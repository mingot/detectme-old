//
//  UIViewController+writeFiles.h
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 25/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (writeFiles)
-(void)writeFeatures:(double *)vect withSize:(int *)size withTitle:(NSString *) filename;
-(void)writeImage:(UInt8 *)vect withSize:(int *)size withTitle:(NSString *) filename;
-(void)write:(double *)vect withSize:(int *)size withTitle:(NSString *) filename;
-(void)writeImages:(UInt8 *)vect withSize:(int *)size withTitle:(NSString *) filename;
-(void)writeConv:(double *)vect withSize:(int *)size withTitle:(NSString *) filename;
-(void)writeConvWithArray:(NSArray *)conv withSize:(int *)size withTitle:(NSString *) filename;


@end
