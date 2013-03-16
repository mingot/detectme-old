//
//  TagView.h
//  LabelMe_work
//
//  Created by David Way on 4/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Box.h"

@interface TagView : UIView
{
    CGPoint firstLocation;
    BOOL move;
    BOOL size;
    int corner;

}

@property (nonatomic, retain) NSMutableArray *boxes;
@property (nonatomic, retain) NSArray *colorArray;
@property int selectedBox; //index of the current box selected. -1 if none.


-(void) drawUnselectedBox:(Box *)box onContext:(CGContextRef)context transparency:(CGFloat)alpha;
-(void) drawSelectedBox:(Box *)box onContext:(CGContextRef)context;

// returns the box located at point point. If none found, -1 is returned
-(int) boxIndexForPoint:(CGPoint)point;

-(void) reset;


@end











