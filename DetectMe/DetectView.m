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
#define sbin  8


@implementation DetectView

@synthesize corners = _corners;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor ]];
        /*
        corner[0] = 0;
        corner[1] = 0;
         */
        self.corners = [[NSArray alloc] init];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (self.corners.count!=0){
        NSLog(@"Enter to draw rect");
            CGContextRef context = UIGraphicsGetCurrentContext();
            /*CGFloat y = (*corner+1)*(self.frame.size.height)/(size_image[0]+2);
            CGFloat x = (*(corner +1)+1)*self.frame.size.width/(size_image[1]+2); 
            CGFloat h = (size_temp[0])*self.frame.size.height/(size_image[0]+2); 
            CGFloat w = (size_temp[1])*self.frame.size.width/(size_image[1]+2); */
            //NSLog(@"width: %f, height: %f",self.frame.size.width,self.frame.size.height);
            //NSLog(@"x: %f, y: %f, w: %f, h: %f",x,y,w,h);
            ConvolutionPoint *p = [self.corners objectAtIndex:0]; //TODO: need to cast?
        NSLog(@"entra y score: %f",p.score.doubleValue);
            CGFloat x = (p.xmin.doubleValue )*self.frame.size.width;
            CGFloat y = (p.ymin.doubleValue )*self.frame.size.height;
            CGFloat w = (p.xmax.doubleValue - p.xmin.doubleValue)*self.frame.size.width;
            CGFloat h = (p.ymax.doubleValue - p.ymin.doubleValue)*self.frame.size.height;
        
       NSLog(@"x: %f, y: %f, w: %f, h: %f",x,y,w,h);


            CGRect box = CGRectMake(x, y, w, h);
            CGContextSetLineWidth(context, 4);
            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
            CGContextStrokeRect(context, box );
            CGContextSetLineWidth(context, 1);
        
            for (int i=1; i<self.corners.count; i++) {
                p = [self.corners objectAtIndex:i];
                NSLog(@"entra y score: %f",p.score.doubleValue);

                x = (p.xmin.doubleValue )*self.frame.size.width;
                y = (p.ymin.doubleValue )*self.frame.size.height;
                w = (p.xmax.doubleValue - p.xmin.doubleValue)*self.frame.size.width;
                h = (p.ymax.doubleValue - p.ymin.doubleValue)*self.frame.size.height;
                
                CGRect box = CGRectMake(x, y, w, h);

                CGContextSetStrokeColorWithColor(context, [UIColor purpleColor].CGColor);
                CGContextStrokeRect(context, box );

        }
        //CGContextRelease(context);

    }
    }

/*-(void)setCorner:(NSArray *)c {
    numRect = c.count;
    for (int i=0; i<n.count; i++) {
        *(corner +4*i) = *(c+5*i+1);
        *(corner +4*i+1) = *(c+5*i+2);
        *(corner +4*i+2) = *(c+5*i+3);
        *(corner +4*i+3) = *(c+5*i+4);
        //NSLog(@"%d.\tCorner, %d x %d",i, *(corner +2*i), *(corner +2*i+1));

    }
     // NSLog(@"Corner, %d x %d",corner[0],corner[1]);
}*/



-(void)reset{
    
    self.corners = nil;
}

@end
