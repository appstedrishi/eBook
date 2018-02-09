#import <Foundation/Foundation.h>

@class Concept;

@interface Aura : NSObject

+ (id)aura;

+ (NSString *)deviceID;
+ (NSString *)hostName;
+ (NSString *)serverName;
// This resposne handler block which will handle Dictionary resposne from server
typedef void (^DictionaryResponse) (BOOL success, NSString *urlResponse, NSData *data);
-(void)getSuggestedQuestionsForHighlight:(NSString *)section andText:(NSString* )text completionHandler:(DictionaryResponse)autocompleteResponse
; //suggested question for highlited view

-(void)answerQuestionForQ:(NSString *)question completionHandler:(DictionaryResponse)autocompleteResponse;


-(void)getSuggestedQuestionsList:(NSString *)query andKeywords:(NSString *)keywords completionHandler:(DictionaryResponse)autocompleteResponse;

@end
