//
//  Box.h
//  LabelMe_work
//
//  Created by David Way on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Box : NSObject <NSCoding>
{
    CGPoint upperLeft;
    CGPoint lowerRigth;
}

@property (retain, nonatomic) NSString *label;
@property (retain, nonatomic) UIColor *color;

- (id)initWithPoints:(CGPoint)upper :(CGPoint)lower;

//Returns the kind of point that is being set: 0,1,2,3
-(int) setUpperLeft:(CGPoint)point;
-(int) setLowerRight:(CGPoint)point;

//getters
-(CGPoint) upperLeft;
-(CGPoint) lowerRight;


-(void) updatePoints:(CGPoint)start :(CGPoint)end;
-(void) updateUpperLeft:(CGPoint)start :(CGPoint)end;
-(void) updateLowerRight:(CGPoint)start :(CGPoint)end;

@end
