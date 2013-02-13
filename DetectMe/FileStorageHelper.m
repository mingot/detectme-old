//
//  WriteToFileAndUpdateCounter.m
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 03/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//

#import "FileStorageHelper.h"

@implementation FileStorageHelper : NSObject 

+ (NSString *) getPathForCurrentFileAndUpdateCounter:(NSString *)file
{
    // write counter_file.txt if it does not exist and initialize it with 0.
    NSFileManager * filemng = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    BOOL isDir = YES;
    NSString *path = [NSString stringWithFormat:@"%@/%@",documentsDirectory,file];
    if (![filemng fileExistsAtPath:path isDirectory:&isDir]) {
        [filemng createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    if (![filemng fileExistsAtPath:[NSString stringWithFormat:@"%@/counter_file.txt",path]]) {
        NSString *cnt = [[NSString alloc] initWithFormat:@"0"];
        NSData *data = [cnt dataUsingEncoding:NSUTF8StringEncoding];
        [filemng createFileAtPath:[NSString stringWithFormat:@"%@/counter_file.txt",path] contents:data attributes:nil];
    }
    
    // increase by 1 the counter_file.txt
    int icnt;
    NSString *cnt = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/counter_file.txt",path] encoding:NSUTF8StringEncoding error:NULL];
    icnt = [cnt intValue] +1; //update the value of the counter
    cnt = [NSString stringWithString:[NSString stringWithFormat: @"%d",icnt]];
    [cnt writeToFile:[NSString stringWithFormat:@"%@/counter_file.txt",path] atomically:NO encoding:NSUTF8StringEncoding error:NULL];
    
    return path;

}


+ (double *) readTemplate:(NSString *)filename //return pointer to template from filename
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/Templates/%@",documentsDirectory,filename];
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSArray *file = [content componentsSeparatedByString:@"\n"];
    
    double *r = malloc((file.count)*sizeof(double));
    for (int i=0; i<file.count; i++) {
        NSString *str = [file objectAtIndex:i];
        *(r+i) = [str doubleValue];
    }
    
    return r;
}

@end
