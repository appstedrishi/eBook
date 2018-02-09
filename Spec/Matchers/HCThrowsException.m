#import "HCThrowsException.h"
#import <objc/runtime.h>

#if TARGET_OS_IPHONE
#import "HCDescription.h"
#else
#import <OCHamcrest/HCDescription.h>
#endif

@interface HCThrowsException ()
@property (nonatomic, assign) Class exceptionClass;
@end

@implementation HCThrowsException

@synthesize exceptionClass = exceptionClass_;

+ (id)throwsExceptionWithExceptionClass:(Class)exceptionClass {
    return [[[HCThrowsException alloc] initWithExceptionClass:exceptionClass] autorelease];
}

- (id)initWithExceptionClass:(Class)exceptionClass {
    if (self = [super init]) {
        self.exceptionClass = exceptionClass;
    }
    return self;
}

- (BOOL)matches:(id)block {
    @try {
        ((void (^)())block)();
    }
    @catch (id e) {
        return [e isKindOfClass:self.exceptionClass];
    }
    return NO;
}

- (void)describeTo:(id<HCDescription>)description {
    [description appendText:[NSString stringWithFormat:@"exception of type: %s", class_getName(self.exceptionClass)]];
}

@end


extern id<HCMatcher> HC_throwsException(Class exceptionClass) {
    return [HCThrowsException throwsExceptionWithExceptionClass:exceptionClass];
}
