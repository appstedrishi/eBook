#import <Foundation/Foundation.h>

#import "PCKXMLParserDelegate.h"

@class Chapter;

@interface Unit : NSObject <NSCoding, PCKXMLParserDelegate> {
    NSMutableArray *chapters_;
}

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *number;
@property (nonatomic, strong, readonly) NSArray *chapters;

@end
