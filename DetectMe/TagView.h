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

@property (nonatomic, retain) NSMutableDictionary *dictionaryBox;
@property (nonatomic, retain) UITextField *label;
@property (nonatomic, retain) NSArray *colorArray;
@property (nonatomic, retain) UITableView *table;

@property int numLabels;
@property int selectedBox;


-(void) drawBox:(CGContextRef )context :(Box *)box1 :(CGFloat) alpha;
-(void) drawSelectedBox:(CGContextRef )context :(Box *) box;
-(void) reset;
-(int)whereIs:(CGPoint) point;
-(int)boxInterior:(int)i :(CGPoint)point;


-(void)copyDictionary:(NSDictionary *)dict;



@end











