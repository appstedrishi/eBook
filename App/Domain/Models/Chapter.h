#import <Foundation/Foundation.h>

#import "PCKXMLParserDelegate.h"

@class Concept;

@interface Chapter : NSObject <NSCoding, PCKXMLParserDelegate> {
    NSMutableArray *concepts_;
}

@property (nonatomic, strong, readonly) NSString *number;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSArray *concepts;

@end

