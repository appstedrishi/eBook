//
//  NSObject+PWObject.m
//  Halo
//
//  Created by http://forrst.com/posts/Delayed_Blocks_in_Objective_C-0Fn
//  Copyright (c) 2012 SRI International. All rights reserved.
//

#import "NSObject+PWObject.h"

@implementation NSObject (PWObject)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    int64_t delta = (int64_t)(1.0e9 * delay);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), block);
}

@end
