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
#define UPPERBOUND 0
#define LOWERBOUND 372
#define LEFTBOUND 0
#define RIGHTBOUND 320
#define DET 2


@implementation TagView

@synthesize dictionaryBox = _dictionaryBox;
@synthesize label = _label;
@synthesize colorArray = _colorArray;
@synthesize table = _table;
@synthesize numLabels = _numLabels;
@synthesize selectedBox = _selectedBox;

- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor ]];
        self.dictionaryBox = [[NSMutableDictionary alloc]init];
        move = NO;
        size = NO;
        corner = -1;

        self.colorArray = [[NSArray alloc] initWithObjects:[UIColor blueColor],[UIColor cyanColor],[UIColor greenColor],[UIColor magentaColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor purpleColor],[UIColor brownColor], nil];
        
        self.numLabels=0;
        self.selectedBox=-1;
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    if (self.dictionaryBox.count < 1) {
        return;
    }
   
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, LINEWIDTH);

    if (self.selectedBox == -1) {
        for (int i=0; i<self.dictionaryBox.count; i++) {
            [self drawBox:context :[self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",i]] :1];
        }

    }else{
        for (int i=0; i<self.dictionaryBox.count; i++) {
            if (i == self.selectedBox) {
                continue;
            }
            
            [self drawBox:context:[self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",i]]:0.3];
        }
         [self drawSelectedBox:context:[self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",self.selectedBox]]];
    }
}



-(void) drawSelectedBox:(CGContextRef )context :(Box *)box1
{
    CGPoint upperRight = CGPointMake([box1 lowerRight].x, [box1 upperLeft].y);
    CGPoint lowerLeft = CGPointMake([box1 upperLeft].x, [box1 lowerRight].y);
    
    // DRAW RECT
    CGRect rect = CGRectMake([box1 upperLeft].x, [box1 upperLeft].y, [box1 lowerRight].x-[box1 upperLeft].x, [box1 lowerRight].y-[box1 upperLeft].y);
    CGContextSetStrokeColorWithColor(context, box1.color.CGColor);
    CGContextStrokeRect(context, rect );
    
    // DRAW CORNERS
    CGContextStrokeEllipseInRect(context, CGRectMake([box1 upperLeft].x-LINEWIDTH, [box1 upperLeft].y-LINEWIDTH, 2*LINEWIDTH, 2*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake([box1 lowerRight].x-LINEWIDTH, [box1 lowerRight].y-LINEWIDTH, 2*LINEWIDTH, 2*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake(upperRight.x-LINEWIDTH, upperRight.y-LINEWIDTH, 2*LINEWIDTH, 2*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake(lowerLeft.x-LINEWIDTH, lowerLeft.y-LINEWIDTH, 2*LINEWIDTH, 2*LINEWIDTH));
    CGContextSetRGBStrokeColor(context, 255, 255, 255, 1);
    CGContextSetLineWidth(context, 1);
    CGContextStrokeEllipseInRect(context, CGRectMake([box1 upperLeft].x-1.5*LINEWIDTH, [box1 upperLeft].y-1.5*LINEWIDTH, 3*LINEWIDTH, 3*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake([box1 lowerRight].x-1.5*LINEWIDTH, [box1 lowerRight].y-1.5*LINEWIDTH, 3*LINEWIDTH, 3*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake(upperRight.x-1.5*LINEWIDTH, upperRight.y-1.5*LINEWIDTH, 3*LINEWIDTH, 3*LINEWIDTH));
    CGContextStrokeEllipseInRect(context, CGRectMake(lowerLeft.x-1.5*LINEWIDTH, lowerLeft.y-1.5*LINEWIDTH, 3*LINEWIDTH, 3*LINEWIDTH));
    
}

-(void) drawBox:(CGContextRef )context :(Box *)box1 :(CGFloat)alpha
{

    const CGFloat *components = CGColorGetComponents(box1.color.CGColor);
    CGContextBeginPath(context);
    CGContextSetRGBStrokeColor(context, components[0] ,components[1],components[2], alpha);
    CGContextAddRect(context, CGRectMake([box1 upperLeft].x, [box1 upperLeft].y, [box1 lowerRight].x-[box1 upperLeft].x, [box1 lowerRight].y-[box1 upperLeft].y) );
    CGContextClosePath(context);
    CGContextStrokePath(context);
   
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    
    if (self.selectedBox!=-1)
    {
        Box *currentBox = [self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",self.selectedBox]];
        
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
            self.label.hidden=YES;
        }
    }else
    {
        self.selectedBox=[self whereIs:location];
        if (self.selectedBox!=-1)
        {
            self.label.hidden=NO;
            Box *currentBox=[self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",self.selectedBox]];
            self.label.text=currentBox.label;
            move=NO;
            size=NO;
        }else
        {
            corner=0;
            size=YES;
        }
    }  
}



-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];

    Box *currentBox;
    if (move)
    {
        currentBox = [self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",self.selectedBox]];
        [currentBox updatePoints:firstLocation :location];
        [self.dictionaryBox setObject:currentBox forKey:[NSString stringWithFormat:@"%d",self.selectedBox]];
        
    }else if (size)
    {
        switch (corner)
        {
            case 0:
                currentBox = [[Box alloc] initWithPoints:location:location ];
                currentBox.color=[self.colorArray objectAtIndex:(self.numLabels%8)];
                corner=1;
                [self.dictionaryBox setObject:currentBox forKey:[NSString stringWithFormat:@"%d",self.numLabels]];
                self.selectedBox = self.numLabels;
                self.numLabels += 1;
                self.label.text=@"";
                self.label.hidden=NO;
                
                break;
            case 1:
                currentBox = [self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",self.selectedBox]];
                corner+=[currentBox setUpperLeft:location];
                break;
            case 2:
                currentBox = [self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",self.selectedBox]];
                corner+=[currentBox setUpperLeft:CGPointMake([currentBox upperLeft].x, location.y)]-[currentBox setLowerRight:CGPointMake(location.x, [currentBox lowerRight].y)];
                break;
            case 3:
                currentBox = [self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",self.selectedBox]];
                corner+=[currentBox setUpperLeft:CGPointMake(location.x, [currentBox upperLeft].y)]-[currentBox setLowerRight:CGPointMake([currentBox lowerRight].x, location.y)];
                break;
            case 4:
                currentBox = [self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",self.selectedBox]];
                corner-=[currentBox setLowerRight:location];
                break;
                
            default:
                break;
        }
        
    }
    firstLocation = location;
    [self setNeedsDisplay];
    [self.table reloadData];
}


-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    move = NO;
    size = NO;
    corner = -1;

    [self setNeedsDisplay];
    [self.table reloadData];
}


-(int)boxInterior:(int)i :(CGPoint)point
{

    int num = [self.dictionaryBox count];
    for (int j=i+1; j<num; j++) {
        Box *newBox = [self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",j]];
        
        if (CGRectContainsPoint( CGRectMake([newBox upperLeft].x-LINEWIDTH, [newBox upperLeft].y-LINEWIDTH, [newBox lowerRight].x-[newBox upperLeft].x+2*LINEWIDTH, [newBox lowerRight].y-[newBox upperLeft].y+2*LINEWIDTH),point)) {
            Box *currentBox = [self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",i]];
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


-(int)whereIs:(CGPoint) point
{
    int num = [self.dictionaryBox count];
    
    for (int j=0; j<num; j++) {
        Box *newBox = [self.dictionaryBox objectForKey:[NSString stringWithFormat:@"%d",j]];
        
        if (CGRectContainsPoint( CGRectMake([newBox upperLeft].x-LINEWIDTH, [newBox upperLeft].y-LINEWIDTH, [newBox lowerRight].x-[newBox upperLeft].x+2*LINEWIDTH, [newBox lowerRight].y-[newBox upperLeft].y+2*LINEWIDTH),point)) {
            return [self boxInterior:j :point];
        }
        
    }    
    return -1;  
}


-(void) reset
{
    self.label.hidden=YES;
    self.selectedBox=-1;
    self.numLabels=0;
    [self.dictionaryBox removeAllObjects];
    move=NO;
    size=NO;
}


-(void)copyDictionary:(NSDictionary *)dict
{
    for (int i=0; i<dict.count; i++) {
        [self.dictionaryBox setObject:[dict objectForKey:[NSString stringWithFormat:@"%d",i]] forKey:[NSString stringWithFormat:@"%d",i]] ;
         //setObject:[ forKey:[NSString stringWithFormat:@"%d",i]];
    }
}




@end