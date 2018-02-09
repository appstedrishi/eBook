#import "MockArgumentRecorder.h"

@interface MockArgumentRecorder ()
@property (nonatomic, retain, readwrite) NSArray *arguments;
@end

@implementation MockArgumentRecorder

@synthesize arguments = arguments_;

- (id)init {
    if (self = [super init]) {
        self.arguments = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    self.arguments = nil;
    [super dealloc];
}

- (BOOL)record:(id)argument {
    [arguments_ addObject:argument];
    return YES;
}

@end
