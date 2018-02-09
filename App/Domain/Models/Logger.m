//
//  Logger.m
//  Halo
//
//  Created by Adam Overholtzer on 8/26/11.
//  Copyright (c) 2011 SRI International. All rights reserved.
//

#import "Logger.h"

static Logger *logger__;
NSString *LOG_FILE = @"console.log";


@interface Logger ()
@property (nonatomic, assign) BOOL doLogging;
-(NSString *) filePath;
@end

@implementation Logger

@synthesize doLogging = doLogging_;

+ (void)initializes {
    
    logger__ = [[Logger alloc] init];

    #if TARGET_IPHONE_SIMULATOR == 0
        NSString *logPath = [logger__ filePath];
        freopen([logPath cStringUsingEncoding:NSASCIIStringEncoding],"a+",stderr);
    #endif
}

+ (id)logger {
    return logger__;
}

+ (void)log: (NSString *)msg {
    if ([logger__ doLogging]) {
        NSLog(@"\t%@", msg);
    }
}

+ (void)log: (NSString *)msg withArguments:(NSString *)arg {
    if ([logger__ doLogging]) {
        NSLog(@"\t%@\t%@", msg, arg);
    }
}

-(void) startLogging {
    if (self.doLogging && ![[NSUserDefaults standardUserDefaults] boolForKey:@"log_preference"]) {
        [Logger log:@"App started - logging is disabled!"];
    }
    self.doLogging = [[NSUserDefaults standardUserDefaults] boolForKey:@"log_preference"];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"reset_log_preference"] 
        || [[NSUserDefaults standardUserDefaults] boolForKey:@"reset_preference"]) {
        // erase the log file
        [self clearLog];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"reset_log_preference"];
    }
    [Logger log:@"Logging started."];
}

-(void) stopLogging {
    [Logger log:@"App stopped."];
}

-(NSString *) filePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:LOG_FILE];
}

-(void) clearLog {
    #if TARGET_IPHONE_SIMULATOR == 0
        NSString *logPath = [self filePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:logPath]) {
            // rename old log with the current date/time
            NSDate *today = [NSDate date];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy.MM.dd-HH.mm.ss"];
            NSString *newPath = [logPath stringByAppendingFormat:@"-%@.log", [dateFormat stringFromDate:today]];
            
            [fileManager moveItemAtPath:logPath toPath:newPath error:NULL];
        }
        freopen("" ,"a+",stderr); //Archit  freopen(  ,"a+",stderr)
    #endif
    [Logger log:@"Log erased."];
}

@end
