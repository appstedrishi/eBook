#import "HistoryLocation.h"

@implementation HistoryLocation

@synthesize request = request_, scrollOffset = scrollOffset_;

#pragma mark NSCoding
static NSString *REQUEST_KEY = @"request";
static NSString *SCROLLOFFSET_KEY = @"scrolloffset";

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.request = [decoder decodeObjectForKey:REQUEST_KEY];
        self.scrollOffset = [decoder decodeFloatForKey:SCROLLOFFSET_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.request forKey:REQUEST_KEY];
    [coder encodeFloat:self.scrollOffset forKey:SCROLLOFFSET_KEY];
}

+ (id)locationForRequest:(NSURLRequest *)request andScrollOffset:(CGFloat)scrollOffset {
    HistoryLocation *location = [[[self class] alloc] init];
    location.request = request;
    location.scrollOffset = scrollOffset;
    return location;
}

@end
