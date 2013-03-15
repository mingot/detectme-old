//
//  Box.m
//  LabelMe_work
//
//  Created by David Way on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Box.h"

#define LINEWIDTH 6
#define UPPERBOUND 0
#define LOWERBOUND 504
#define LEFTBOUND 0
#define RIGHTBOUND 320



@implementation Box

@synthesize label = _label;
@synthesize color = _color;


- (id)initWithPoints:(CGPoint)upper :(CGPoint)lower
{
    self = [super init];
    if (self) {
        upperLeft = upper;
        lowerRigth = lower;
        self.label= [NSString stringWithFormat:@""];
        self.color = [[UIColor alloc] init];
    }
    
    return self;
}


-(int) setUpperLeft:(CGPoint ) point
{
    int corner=0;
    
    if (point.y < UPPERBOUND + LINEWIDTH/2) {
        point.y = UPPERBOUND + LINEWIDTH/2;
    }
    if (point.x < LEFTBOUND + LINEWIDTH/2) {
        point.x = LEFTBOUND + LINEWIDTH/2;
    }
    upperLeft = point;
    if ((upperLeft.x > lowerRigth.x)) {
        float copy;
        copy = upperLeft.x;
        upperLeft.x = lowerRigth.x;
        lowerRigth.x = copy;
        corner++;
    }
    if ((upperLeft.y > lowerRigth.y)) {
        float copy;
        copy=upperLeft.y;
        upperLeft.y = lowerRigth.y;
        lowerRigth.y = copy;
        corner += 2;
    }
    
    return corner;
}


-(int) setLowerRight:(CGPoint ) point
{
    int corner=0;
    if (point.y > LOWERBOUND - LINEWIDTH/2) {
        point.y = LOWERBOUND - LINEWIDTH/2;
    }
    if (point.x > RIGHTBOUND - LINEWIDTH/2) {
        point.x = RIGHTBOUND - LINEWIDTH/2;
    }
    lowerRigth = point;
    
    if ((upperLeft.x > lowerRigth.x)) {
        float copy;
        copy = upperLeft.x;
        upperLeft.x = lowerRigth.x;
        lowerRigth.x = copy;
        corner++;
    }
    if ((upperLeft.y > lowerRigth.y)) {
        float copy;
        copy = upperLeft.y;
        upperLeft.y = lowerRigth.y;
        lowerRigth.y = copy;
        corner += 2;
    }
    
    
    return corner;
}


-(CGPoint) upperLeft
{
    return upperLeft;
}

-(CGPoint) lowerRight
{
    return lowerRigth;
}

-(void) updatePoints:(CGPoint)start :(CGPoint)end
{
    if (upperLeft.y + end.y - start.y < UPPERBOUND + LINEWIDTH/2) {
        end.y = UPPERBOUND + LINEWIDTH/2 - upperLeft.y + start.y;
        
    }
    if (lowerRigth.y + end.y - start.y > LOWERBOUND-LINEWIDTH/2) {
        end.y = LOWERBOUND - LINEWIDTH/2 - lowerRigth.y + start.y;
        
        
    }
    if (upperLeft.x + end.x - start.x < LEFTBOUND + LINEWIDTH/2) {
        end.x = LEFTBOUND + LINEWIDTH/2 - upperLeft.x + start.x;
        
    }
    if (lowerRigth.x + end.x - start.x > RIGHTBOUND - LINEWIDTH/2) {
        end.x = RIGHTBOUND - LINEWIDTH/2 - lowerRigth.x + start.x;
    }
    
    upperLeft.x = upperLeft.x + end.x - start.x;
    upperLeft.y = upperLeft.y + end.y - start.y;
    lowerRigth.x = lowerRigth.x + end.x - start.x;
    lowerRigth.y = lowerRigth.y + end.y - start.y;

}


-(void) updateUpperLeft:(CGPoint)start :(CGPoint)end
{
    upperLeft.x=upperLeft.x+end.x-start.x;
    upperLeft.y=upperLeft.y+end.y-start.y;
    if (upperLeft.y < UPPERBOUND + LINEWIDTH/2) {
        upperLeft.y = UPPERBOUND + LINEWIDTH/2;
    }
    if (upperLeft.x < LEFTBOUND + LINEWIDTH/2) {
        upperLeft.x = LEFTBOUND + LINEWIDTH/2;
    }
    if ((upperLeft.x > lowerRigth.x)) {
        float copy;
        copy = upperLeft.x;
        upperLeft.x = lowerRigth.x;
        lowerRigth.x = copy;
    }
    if ((upperLeft.y > lowerRigth.y)) {
        float copy;
        copy=upperLeft.y;
        upperLeft.y=lowerRigth.y;
        lowerRigth.y=copy;
    }
    
}

-(void) updateLowerRight:(CGPoint)start :(CGPoint)end
{
    lowerRigth.x=lowerRigth.x+end.x-start.x;
    lowerRigth.y=lowerRigth.y+end.y-start.y;
    if (lowerRigth.y>LOWERBOUND-LINEWIDTH/2) {
        lowerRigth.y=LOWERBOUND-LINEWIDTH/2;
    }
    if (lowerRigth.x>RIGHTBOUND-LINEWIDTH/2) {
        lowerRigth.x=RIGHTBOUND-LINEWIDTH/2;
    }
    if ((upperLeft.x>lowerRigth.x)) {
        float copy;
        copy=upperLeft.x;
        upperLeft.x=lowerRigth.x;
        lowerRigth.x=copy;
    }
    if ((upperLeft.y>lowerRigth.y)) {
        float copy;
        copy=upperLeft.y;
        upperLeft.y=lowerRigth.y;
        lowerRigth.y=copy;
    }
    
}


-(id) initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.label = [aDecoder decodeObjectForKey:@"label"];
        self.color = [aDecoder decodeObjectForKey:@"color"];
        upperLeft.x = [aDecoder decodeFloatForKey:@"upperLeftx"];
        upperLeft.y = [aDecoder decodeFloatForKey:@"upperLefty"];
        lowerRigth.x = [aDecoder decodeFloatForKey:@"lowerRightx"];
        lowerRigth.y = [aDecoder decodeFloatForKey:@"lowerRighty"];

    }
    return self;
}


- (void) encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject: self.label forKey:@"label"];
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeFloat:upperLeft.x forKey:@"upperLeftx"];
    [aCoder encodeFloat:upperLeft.y forKey:@"upperLefty"];
    [aCoder encodeFloat:lowerRigth.x forKey:@"lowerRightx"];
    [aCoder encodeFloat:lowerRigth.y forKey:@"lowerRighty"];

}

@end