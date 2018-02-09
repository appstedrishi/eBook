#import "Chapter.h"
#import "Concept.h"
#import "PCKXMLParser.h"
#import "PCKXMLParserDelegate.h"

@interface Chapter ()

@property (nonatomic, strong, readwrite) NSString *number;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSArray *concepts;
@property (nonatomic, strong) PCKXMLParserDelegate *parserDelegate;

- (PCKXMLParserDelegate *)createParserDelegate;
- (BOOL)isConceptElement:(const char *)elementName;
- (BOOL)isPropertyElement:(const char *)elementName;

@end

@implementation Chapter

@synthesize number = number_, title = title_, concepts = concepts_, parserDelegate = parserDelegate_;

#pragma mark NSCoding

static NSString *NUMBER_KEY = @"number";
static NSString *TITLE_KEY = @"title";
static NSString *CONCEPTS_KEY = @"concepts";

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.number = [decoder decodeObjectForKey:NUMBER_KEY];
        self.title = [decoder decodeObjectForKey:TITLE_KEY];
        self.concepts = [decoder decodeObjectForKey:CONCEPTS_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.number forKey:NUMBER_KEY];
    [coder encodeObject:self.title forKey:TITLE_KEY];
    [coder encodeObject:self.concepts forKey:CONCEPTS_KEY];
}

#pragma mark init
- (id)init {
    if (self = [super init]) {
        self.concepts = [NSMutableArray array];
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

static const char *CONCEPT_ELEMENT_NAME = "concept";
static const char *OVERVIEW_ELEMENT_NAME = "overview";
static const char *REVIEW_ELEMENT_NAME = "review";
static const char *NUMBER_ELEMENT_NAME = "number";
static const char *TITLE_ELEMENT_NAME = "title";

- (PCKXMLParserDelegate *)createParserDelegate {
    PCKXMLParserDelegate *parserDelegate = [[PCKXMLParserDelegate alloc] init];

    __block Concept *concept = nil;
    __block NSMutableString *propertyValue = nil;

    parserDelegate.didStartElement = (PCKXMLParserDelegateBlock)^(const char *elementName) {
        if (concept) {
            [concept parser:nil didStartElement:elementName attributeCount:0 attributeData:nil];
        } else if ([self isConceptElement:elementName]) {
            concept = [[Concept alloc] initWithChapter:self];
        } else if ([self isPropertyElement:elementName]) {
            propertyValue = [[NSMutableString alloc] init];
        }
    };

    parserDelegate.didEndElement = ^(const char *elementName) {
        if ([self isConceptElement:elementName]) {
            [concepts_ addObject:concept];
             concept = nil;
        } else if (concept) {
            [concept parser:nil didEndElement:elementName];
        } else if (propertyValue) {
            if (0 == strncmp(elementName, NUMBER_ELEMENT_NAME, strlen(elementName))) {
                self.number = propertyValue;
            } else {
                self.title = propertyValue;
            }
             propertyValue = nil;
        }
    };

    parserDelegate.didFindCharacters = ^(const char *characters) {
        if (concept) {
            [concept parser:nil didFindCharacters:characters];
        } else if (propertyValue) {
            [propertyValue appendString:[NSString stringWithCString:characters encoding:NSUTF8StringEncoding]];
        }
    };

    return parserDelegate;
}

- (BOOL)isConceptElement:(const char *)elementName {
    return 0 == strncmp(elementName, CONCEPT_ELEMENT_NAME, strlen(elementName))
    || 0 == strncmp(elementName, OVERVIEW_ELEMENT_NAME, strlen(elementName))
    || 0 == strncmp(elementName, REVIEW_ELEMENT_NAME, strlen(elementName));
}

- (BOOL)isPropertyElement:(const char *)elementName {
    return 0 == strncmp(elementName, NUMBER_ELEMENT_NAME, strlen(elementName))
    || 0 == strncmp(elementName, TITLE_ELEMENT_NAME, strlen(elementName));
}

@end
