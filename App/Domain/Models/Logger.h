//
//  Logger.h
//  Halo
//
//  Created by Adam Overholtzer on 8/26/11.
//  Copyright (c) 2011 SRI International. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject

+ (void)initializes;
+ (id)logger;
+ (void)log: (NSString *)msg;
+ (void)log: (NSString *)msg withArguments:(NSString *)arg;

-(void) startLogging;
-(void) stopLogging;
-(void) clearLog;

@end
