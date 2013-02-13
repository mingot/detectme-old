//
//  WriteToFileAndUpdateCounter.h
//  TestDetector
//
//  Created by Josep Marc Mingot Hidalgo on 03/02/13.
//  Copyright (c) 2013 Dolores. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileStorageHelper : NSObject

+ (NSString *) getPathForCurrentFileAndUpdateCounter:(NSString *)file;

+ (double *) readTemplate:(NSString *)filename;

@end
