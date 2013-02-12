//
//  UIViewController+writeFiles.m
//  TwoDetect
//
//  Created by Dolores Blanco Almazán on 25/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIViewController+writeFiles.h"
#import "ConvolutionHelper.h"   

@implementation UIViewController (writeFiles)

-(void)writeImage:(UInt8 *)vect withSize:(int *)size withTitle:(NSString *) filename{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/%@",documentsDirectory,filename];
    
    
    NSMutableString *content = [NSMutableString stringWithCapacity:size[0]*size[1]*3+2];
    [content appendFormat:@"%d\n",size[0]];
    [content appendFormat:@"%d\n",size[1]];
    
    
    for (int i=0; i<size[0]*size[1]; i++) {
        [content appendFormat:@"%d\n",*(vect +4*i)];
        [content appendFormat:@"%d\n",*(vect +4*i+1)];
        [content appendFormat:@"%d\n",*(vect +4*i+2)];
    }
    
    [content writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    
}
-(void)write:(double *)vect withSize:(int *)size withTitle:(NSString *) filename{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/%@",documentsDirectory,filename];
   
    NSMutableString *content = [NSMutableString stringWithCapacity:size[0]*size[1]+2];
    [content appendFormat:@"%d\n",size[0]];
    [content appendFormat:@"%d\n",size[1]];
    for (int x = 0; x<size[1]*size[0]; x++) {
        [content appendFormat:@"%f\n",*(vect +x)];
        
        
    }
    
    [content writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    
    
    
}
-(void)writeFeatures:(double *)vect withSize:(int *)size withTitle:(NSString *) filename{
   /* NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/%@",documentsDirectory,filename];*/
    
   
    NSMutableString *content = [NSMutableString stringWithCapacity:size[0]*size[1]*32+2];
    [content appendFormat:@"%d\n",size[0]];
    [content appendFormat:@"%d\n",size[1]];
    for (int x = 0; x<size[1]*size[0]*32; x++) {
        [content appendFormat:@"%f\n",*(vect +x)];
        
        
    }

    if([content writeToFile:filename atomically:NO encoding:NSUTF8StringEncoding error:NULL]){
        NSLog(@"Ok1");
    }
    
 
    
    
}
-(void)writeImages:(UInt8 *)vect withSize:(int *)size withTitle:(NSString *) filename{
    /* NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
     NSString * path = [NSString stringWithFormat:@"%@/%@",documentsDirectory,filename];*/
    
    NSMutableString *content = [NSMutableString stringWithCapacity:size[0]*size[1]*3+2];
    [content appendFormat:@"%d\n",size[0]];
    [content appendFormat:@"%d\n",size[1]];
     
    
    for (int i=0; i<size[0]*size[1]; i++) {
        [content appendFormat:@"%d\n",*(vect +4*i)];
        [content appendFormat:@"%d\n",*(vect +4*i+1)];
        [content appendFormat:@"%d\n",*(vect +4*i+2)];
    }
    NSError *error;
    if([content writeToFile:filename atomically:NO encoding:NSUTF8StringEncoding error:&error]){
        NSLog(@"Ok2");
    }
    else{
        NSLog(@"No Ok2: %@",error.localizedDescription);
    }
    
    
    
    
}
-(void)writeConv:(double *)vect withSize:(int *)size withTitle:(NSString *) filename{

    NSMutableString *content = [NSMutableString stringWithCapacity:size[0]*size[1]+2];
    [content appendFormat:@"%d\n",size[0]];
    [content appendFormat:@"%d\n",size[1]];
    for (int x = 0; x<size[1]*size[0]; x++) {
        [content appendFormat:@"%f\n",*(vect +x)];
        
        
    }
    [content writeToFile:filename atomically:NO encoding:NSUTF8StringEncoding error:NULL];
}
-(void)writeConvWithArray:(NSArray *)conv withSize:(int *)size withTitle:(NSString *) filename{
    
    NSMutableString *content = [NSMutableString stringWithCapacity:conv.count+2];
    [content appendFormat:@"%d\n",size[0]];
    [content appendFormat:@"%d\n",size[1]];
    for (int x = 0; x<conv.count; x++) {
        ConvolutionPoint * p = [conv objectAtIndex:x];
        [content appendFormat:@"%f\n",p.score.doubleValue];
    }
    [content writeToFile:filename atomically:NO encoding:NSUTF8StringEncoding error:NULL];
}

@end
