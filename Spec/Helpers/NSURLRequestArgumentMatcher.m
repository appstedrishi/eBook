#import "NSURLRequestArgumentMatcher.h"

@interface NSURLRequestArgumentMatcher ()

@property (nonatomic, retain) NSURLRequest *expectedRequest;

@end


@implementation NSURLRequestArgumentMatcher

@synthesize expectedRequest = expectedRequest_;

- (id)initWithExpectedRequest:(NSURLRequest *)expectedRequest {
    if (self = [super init]) {
        self.expectedRequest = expectedRequest;
    }
    return self;
}

- (void)dealloc {
    self.expectedRequest = nil;
    [super dealloc];
}

- (BOOL)matches:(NSURLRequest *)request {
    NSString *expectedPath = [[self.expectedRequest URL] absoluteString];
    NSString *actualPath = [[request URL] absoluteString];

    if (![expectedPath isEqualToString:actualPath]) {
        NSLog(@"Request URL paths do not match:\n\tExpected path:'%@'\n\tActual path:'%@'", expectedPath, actualPath);
        return NO;
    }
    return YES;
}

@end
