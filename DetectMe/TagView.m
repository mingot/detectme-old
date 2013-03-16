//
//  TagView.m
//  LabelMe_work
//
//  Created by David Way on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//
//  AnnotationView.m
//  AnnotationTool
//
//  Created by Dolores Blanco Almazán on 27/03/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "TagView.h"

#define LINEWIDTH 6
#define DET 2


@implementation TagView

@synthesize boxes = _boxes;
@synthesize colorArray = _colorArray;
@synthesize selectedBox = _selectedBox;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.boxes = [[NSMutableArray alloc] init];
        move = NO;
        size = NO;
        corner = -1;
        self.selectedBox = -1;
        self.colorArray = [[NSArray alloc] initWithObjects:[UIColor blueColor],[UIColor cyanColor],[UIColor greenColor],[UIColor magentaColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor purpleColor],[UIColor brownColor], nil];
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect
{
    
    if (self.boxes.count < 1) return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, LINEWIDTH);


    if (self.selectedBox == -1) //none box selected
    {
        for (int i=0; i<self.boxes.count; i++)
            [self drawUnselectedBox:[self.boxes objectAtIndex:i] onContext:context transparency:1];
        
    }else{
        for (int i=0; i<self.boxes.count; i++)
        {
            if (i != self.selectedBox)
                [self drawUnselectedBox:[self.boxes objectAtIndex:i] onContext:context transparency:0.3];
        }
        [self drawSelectedBox:[self.boxes objectAtIndex:self.selectedBox] onContext:context];
    }
}



-(void) drawSelectedBox:(Box *)box onContext:(CGContextRef )context
{
    CGPoint upperRight = CGPointMake([box lowerRight].x, [box upperLeft].y);
    CGPoint lowerLeft = CGPointMake([box upperLeft].x, [box lowerRight].y);
    
    // DRAW RECT
    CGRect rect = CGRectMake([box upperLeft].x, [box upperLeft].y, [box lowerRight].x-[box upperLeft].x, [box lowerRight].y-[box upperLeft].y);
    CGContextSetStrokeColorWithColor(context, box.color.CGColor);
    CGContextStrokeRect(context, rect );
    
    // DRAW CORNERS
    CGContextStrokeEllipseInRect(context, CGRectMake([box upperLeft].x-LINEWIDTH, [box upperLeft].y-LINEWIDTH, 2*LINEWIDTH, 2*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake([box lowerRight].x-LINEWIDTH, [box lowerRight].y-LINEWIDTH, 2*LINEWIDTH, 2*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake(upperRight.x-LINEWIDTH, upperRight.y-LINEWIDTH, 2*LINEWIDTH, 2*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake(lowerLeft.x-LINEWIDTH, lowerLeft.y-LINEWIDTH, 2*LINEWIDTH, 2*LINEWIDTH));
    CGContextSetRGBStrokeColor(context, 255, 255, 255, 1);
    CGContextSetLineWidth(context, 1);
    CGContextStrokeEllipseInRect(context, CGRectMake([box upperLeft].x-1.5*LINEWIDTH, [box upperLeft].y-1.5*LINEWIDTH, 3*LINEWIDTH, 3*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake([box lowerRight].x-1.5*LINEWIDTH, [box lowerRight].y-1.5*LINEWIDTH, 3*LINEWIDTH, 3*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake(upperRight.x-1.5*LINEWIDTH, upperRight.y-1.5*LINEWIDTH, 3*LINEWIDTH, 3*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake(lowerLeft.x-1.5*LINEWIDTH, lowerLeft.y-1.5*LINEWIDTH, 3*LINEWIDTH, 3*LINEWIDTH));
}

-(void) drawUnselectedBox:(Box *)box onContext:(CGContextRef)context transparency:(CGFloat)alpha;
{

    const CGFloat *components = CGColorGetComponents(box.color.CGColor);
    CGContextBeginPath(context);
    CGContextSetRGBStrokeColor(context, components[0] ,components[1],components[2], alpha);
    CGContextAddRect(context, CGRectMake([box upperLeft].x, [box upperLeft].y, [box lowerRight].x-[box upperLeft].x, [box lowerRight].y-[box upperLeft].y) );
    CGContextClosePath(context);
    CGContextStrokePath(context);
   
}


-(int)boxIndexForPoint:(CGPoint) point
{
    for (int i=0; i<self.boxes.count; i++) {
        Box *newBox = [self.boxes objectAtIndex:i];
        
        //Check if the box is inside a point
        if (CGRectContainsPoint( CGRectMake([newBox upperLeft].x-LINEWIDTH, [newBox upperLeft].y-LINEWIDTH, [newBox lowerRight].x-[newBox upperLeft].x+2*LINEWIDTH, [newBox lowerRight].y-[newBox upperLeft].y+2*LINEWIDTH),point)) {
            return [self boxInterior:i :point];
        }
    }    
    return -1;  
}


-(int)boxInterior:(int)i :(CGPoint)point
{
    for (int j=i+1; j<self.boxes.count; j++) {
        Box *newBox = [self.boxes objectAtIndex:j];
        
        if (CGRectContainsPoint( CGRectMake([newBox upperLeft].x-LINEWIDTH, [newBox upperLeft].y-LINEWIDTH, [newBox lowerRight].x-[newBox upperLeft].x+2*LINEWIDTH, [newBox lowerRight].y-[newBox upperLeft].y+2*LINEWIDTH),point)) {
            Box *currentBox = [self.boxes objectAtIndex:i];
            if (CGRectContainsRect( CGRectMake([newBox upperLeft].x-LINEWIDTH, [newBox upperLeft].y-LINEWIDTH, [newBox lowerRight].x-[newBox upperLeft].x+2*LINEWIDTH, [newBox lowerRight].y-[newBox upperLeft].y+2*LINEWIDTH),CGRectMake([currentBox upperLeft].x-LINEWIDTH, [currentBox upperLeft].y-LINEWIDTH, [currentBox lowerRight].x-[currentBox upperLeft].x+2*LINEWIDTH, [currentBox lowerRight].y-[currentBox upperLeft].y+2*LINEWIDTH))){
                
                if ([self boxInterior:j :point]==j) {
                    return i;
                }
            }
            return [self boxInterior:j:point];
        }
    }
    return i;
}


-(void) reset
{
    self.selectedBox = -1;
    [self.boxes removeAllObjects];
    move = NO;
    size = NO;
}


#pragma mark
#pragma mark - Touch event controller

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    
    if (self.selectedBox!=-1) //if a box is selected
    {
        Box *currentBox = [self.boxes objectAtIndex:self.selectedBox];
        
        if ((CGRectContainsPoint(CGRectMake([currentBox upperLeft].x-DET*LINEWIDTH, [currentBox upperLeft].y-DET*LINEWIDTH,2*DET*LINEWIDTH,2*DET*LINEWIDTH) , location)))
        {
            size=YES;
            corner = 1;
        }else if ((CGRectContainsPoint(CGRectMake([currentBox lowerRight].x-DET*LINEWIDTH, [currentBox lowerRight].y-DET*LINEWIDTH,2*DET*LINEWIDTH,2*DET*LINEWIDTH) , location)))
        {
            size=YES;
            corner=4;
        }else if ((CGRectContainsPoint(CGRectMake([currentBox lowerRight].x-DET*LINEWIDTH, [currentBox upperLeft].y-DET*LINEWIDTH,2*DET*LINEWIDTH,2*DET*LINEWIDTH) , location)))
        {
            size=YES;
            corner=2;
        }else if ((CGRectContainsPoint(CGRectMake([currentBox upperLeft].x-DET*LINEWIDTH, [currentBox lowerRight].y-DET*LINEWIDTH,2*DET*LINEWIDTH,2*DET*LINEWIDTH) , location)))
        {
            size=YES;
            corner=3;
        }else if ((CGRectContainsPoint(CGRectMake([currentBox upperLeft].x-LINEWIDTH/2, [currentBox upperLeft].y-LINEWIDTH/2, [currentBox lowerRight].x-[currentBox upperLeft].x+LINEWIDTH, [currentBox lowerRight].y-[currentBox upperLeft].y+LINEWIDTH) , location)))
        {
            move=YES;
            firstLocation=location;
        }else
        {
            self.selectedBox=-1;
        }
    }else{
        self.selectedBox = [self boxIndexForPoint:location];
        if (self.selectedBox!=-1){
            move=NO;
            size=NO;
        
        }else{ //New box!
            corner=0;
            size=YES;
        }
    }
}



-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    
    Box *currentBox;
    if (move)
    {
        currentBox = [self.boxes objectAtIndex:self.selectedBox];
        [currentBox updatePoints:firstLocation :location];
//        [self.dictionaryBox setObject:currentBox forKey:[NSString stringWithFormat:@"%d",self.selectedBox]];
        
    }else if (size){
        switch (corner)
        {
            case 0: //New box
                currentBox = [[Box alloc] initWithPoints:location:location ];
                currentBox.color=[self.colorArray objectAtIndex:(self.boxes.count%8)];
                corner=1;
                [self.boxes addObject:currentBox];
                self.selectedBox = self.boxes.count-1;
                
                break;
            case 1:
                currentBox = [self.boxes objectAtIndex:self.selectedBox];
                corner+=[currentBox setUpperLeft:location];
                break;
            case 2:
                currentBox = [self.boxes objectAtIndex:self.selectedBox];
                corner+=[currentBox setUpperLeft:CGPointMake([currentBox upperLeft].x, location.y)]-[currentBox setLowerRight:CGPointMake(location.x, [currentBox lowerRight].y)];
                break;
            case 3:
                currentBox = [self.boxes objectAtIndex: self.selectedBox];
                corner+=[currentBox setUpperLeft:CGPointMake(location.x, [currentBox upperLeft].y)]-[currentBox setLowerRight:CGPointMake([currentBox lowerRight].x, location.y)];
                break;
            case 4:
                currentBox = [self.boxes objectAtIndex: self.selectedBox];
                corner-=[currentBox setLowerRight:location];
                break;
                
            default:
                break;
        }
        
    }
    firstLocation = location;
    [self setNeedsDisplay];
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    move = NO;
    size = NO;
    corner = -1;
    
    [self setNeedsDisplay];
}



@end