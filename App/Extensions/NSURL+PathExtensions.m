#import "NSURL+PathExtensions.h"
#import "NSString+PivotalCore.h"

@implementation NSURL (PathExtensions)

- (NSString *)absoluteStringWithoutFragment {
    return [NSString stringWithFormat:@"%@://%@", [self scheme], [self path]];
}

- (NSURL *)absoluteURLWithoutFragment {
    return [NSURL URLWithString: [[self absoluteStringWithoutFragment] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
   
}

- (NSString *)relativePathWithFragment {
    NSString *fragment = [self fragment];
    if (fragment) {
        return [NSString stringWithFormat:@"%@#%@", [self relativePath], fragment];
    } else {
        return [NSString stringWithFormat:@"%@", [self relativePath]];
    }
}

@end
