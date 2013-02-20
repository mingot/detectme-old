//
//  DetectView.m
//  ImageG
//
//  Created by Dolores Blanco Almazán on 12/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetectView.h"
#import "ConvolutionHelper.h"
#import "math.h"


@implementation DetectView

@synthesize corners = _corners;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor ]];
        self.corners = [[NSArray alloc] init];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (self.corners.count!=0)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        ConvolutionPoint *p;
        CGFloat x,y,w,h;
    
        for (int i=0; i<self.corners.count; i++) 
        {
            p = [self.corners objectAtIndex:i];

            x = (p.xmin.doubleValue )*self.frame.size.width;
            y = (p.ymin.doubleValue )*self.frame.size.height;
            w = (p.xmax.doubleValue - p.xmin.doubleValue)*self.frame.size.width;
            h = (p.ymax.doubleValue - p.ymin.doubleValue)*self.frame.size.height;
            
            CGRect box = CGRectMake(x, y, w, h);
            if(i==0)
            {
                CGContextSetLineWidth(context, 4);
                CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
                CGContextStrokeRect(context, box);
                
                // for the rest of boxes
                CGContextSetLineWidth(context, 1);
                CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
                
            }else CGContextStrokeRect(context, box );
        }
    }
}

/*
-(void)setCorner:(NSArray *)c {
    numRect = c.count;
    for (int i=0; i<n.count; i++) {
        *(corner +4*i) = *(c+5*i+1);
        *(corner +4*i+1) = *(c+5*i+2);
        *(corner +4*i+2) = *(c+5*i+3);
        *(corner +4*i+3) = *(c+5*i+4);
        //NSLog(@"%d.\tCorner, %d x %d",i, *(corner +2*i), *(corner +2*i+1));

    }
     // NSLog(@"Corner, %d x %d",corner[0],corner[1]);
}
*/



-(void)reset{
    self.corners = nil;
}

@end
