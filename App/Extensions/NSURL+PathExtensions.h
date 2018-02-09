#import <Foundation/Foundation.h>

@interface NSURL (PathExtensions)

- (NSString *)absoluteStringWithoutFragment;
- (NSURL *)absoluteURLWithoutFragment;
- (NSString *)relativePathWithFragment;

@end
