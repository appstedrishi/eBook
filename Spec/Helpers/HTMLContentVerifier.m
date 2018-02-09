#import "HTMLContentVerifier.h"

@implementation HTMLContentVerifier

@synthesize expectedHTML = expectedHTML_;

- (id)initWithExpectedHTML:(NSString *)expectedHTML {
    if (self = [super init]) {
        self.expectedHTML = expectedHTML;
    }
    return self;
}

- (void)dealloc {
    self.expectedHTML = nil;
    [super dealloc];
}

- (BOOL)documentContainsExpectedHTML:(NSString *)document {
    NSUInteger expectedHTMLLocation = [document rangeOfString:self.expectedHTML].location;
    if (NSNotFound == expectedHTMLLocation) {
        NSLog(@"HTMLContentVerifer:\n\tExpected HTML:'%@'\n\tActual HTML:'%@'", self.expectedHTML, document);
        return NO;
    }
    return YES;
}

@end
