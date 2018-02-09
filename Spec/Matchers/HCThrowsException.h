#if TARGET_OS_IPHONE
#import "HCBaseMatcher.h"
#else
#import <OCHamcrest/HCBaseMatcher.h>
#endif

@interface HCThrowsException : HCBaseMatcher

+ (id)throwsExceptionWithExceptionClass:(Class)exceptionClass;
- (id)initWithExceptionClass:(Class)exceptionClass;

@end

extern id<HCMatcher> HC_throwsException(Class exceptionClass);

#ifdef HC_SHORTHAND
#define throwsException HC_throwsException
#endif
