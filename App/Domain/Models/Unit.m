#import "Unit.h"
#import "Chapter.h"
#import "PCKXMLParserDelegate.h"

@interface Unit ()

@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *number;
@property (nonatomic, strong, readwrite) NSArray *chapters;
@property (nonatomic, strong) PCKXMLParserDelegate *parserDelegate;

- (PCKXMLParserDelegate *)createParserDelegate;

@end


@implementation Unit

@synthesize title = title_, number = number_, chapters = chapters_, parserDelegate = parserDelegate_;

#pragma mark NSCoding

static NSString *NUMBER_KEY = @"number";
static NSString *TITLE_KEY = @"title";
static NSString *CHAPTERS_KEY = @"chapters";

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.number = [decoder decodeObjectForKey:NUMBER_KEY];
        self.title = [decoder decodeObjectForKey:TITLE_KEY];
        self.chapters = [decoder decodeObjectForKey:CHAPTERS_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.number forKey:NUMBER_KEY];
    [coder encodeObject:self.title forKey:TITLE_KEY];
    [coder encodeObject:self.chapters forKey:CHAPTERS_KEY];
}

#pragma mark init
- (id)init {
    if (self = [super init]) {
        self.chapters = [NSMutableArray array];
        self.parserDelegate = [self createParserDelegate];
    }
    return self;
}


#pragma mark PCKXMLParserDelegate
- (void)parser:(PCKXMLParser *)parser didStartElement:(const char *)elementName attributeCount:(int)numAttributes attributeData:(const char**)attributes {
    self.parserDelegate.didStartElement(elementName);
}

- (void)parser:(PCKXMLParser *)parser didEndElement:(const char *)elementName {
    self.parserDelegate.didEndElement(elementName);
}

- (void)parser:(PCKXMLParser *)parser didFindCharacters:(const char *)characters {
    self.parserDelegate.didFindCharacters(characters);
}

- (void)parser:(id<PCKParser>)parser didEncounterError:(NSError *)error {
}

#pragma mark Private methods

static const char *NUMBER_ELEMENT_NAME = "number";
static const char *TITLE_ELEMENT_NAME = "title";
static const char *CHAPTER_ELEMENT_NAME = "chapter";

- (PCKXMLParserDelegate *)createParserDelegate {
    PCKXMLParserDelegate *parserDelegate = [[PCKXMLParserDelegate alloc] init];

    __block NSMutableString *propertyValue = nil;
    __block Chapter *chapter = nil;

    parserDelegate.didStartElement = (PCKXMLParserDelegateBlock)^(const char *elementName) {
        if (chapter) {
            [chapter parser:nil didStartElement:elementName attributeCount:0 attributeData:nil];
        } else if (0 == strcmp(elementName, CHAPTER_ELEMENT_NAME)) {
            chapter = [[Chapter alloc] init];
        } else if (0 == strcmp(elementName, NUMBER_ELEMENT_NAME) || 0 == strcmp(elementName, TITLE_ELEMENT_NAME)) {
            propertyValue = [[NSMutableString alloc] init];
        }
    };

    parserDelegate.didEndElement = ^(const char *elementName) {
        if (0 == strcmp(elementName, CHAPTER_ELEMENT_NAME)) {
            [chapters_ addObject:chapter];
             chapter = nil;
        } else if (chapter) {
            [chapter parser:nil didEndElement:elementName];
        } else if (propertyValue) {
            if (0 == strcmp(elementName, NUMBER_ELEMENT_NAME)) {
                self.number = propertyValue;
            } else {
                self.title = propertyValue;
            }
             propertyValue = nil;
        }
    };

    parserDelegate.didFindCharacters = ^(const char *characters) {
        if (chapter) {
            [chapter parser:nil didFindCharacters:characters];
        } else if (propertyValue) {
            [propertyValue appendString:[NSString stringWithCString:characters encoding:NSUTF8StringEncoding]];
        }
    };

    return parserDelegate;
}

@end
