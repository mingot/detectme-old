//
//  RectFrameLearnView.m
//  DetectMe
//
//  Created by Josep Marc Mingot Hidalgo on 20/02/13.
//  Copyright (c) 2013 Josep Marc Mingot Hidalgo. All rights reserved.
//

#import "RectFrameLearnView.h"

@implementation RectFrameLearnView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]]; // make the view transparent
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    CGFloat width, heigth;
    width = self.superview.frame.size.width;
    heigth = self.superview.frame.size.height;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect box = CGRectMake(width*3/8, heigth*3/8, width/4, heigth/4);
    CGContextSetLineWidth(context, 4);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextStrokeRect(context, box);
}


@end
