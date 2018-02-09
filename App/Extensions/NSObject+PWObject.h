//
//  NSObject+PWObject.h
//  Halo
//
//  Created by http://forrst.com/posts/Delayed_Blocks_in_Objective_C-0Fn
//  Copyright (c) 2012 SRI International. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PWObject)

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end
