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
    width = self.frame.size.width;
    heigth = self.frame.size.height;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect box = CGRectMake(width/4, heigth/4, width/2, heigth/2);
    CGContextSetLineWidth(context, 4);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextStrokeRect(context, box);
}


@end
