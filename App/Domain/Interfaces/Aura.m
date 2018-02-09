#import "Aura.h"
#import "Concept.h"
#import "NSString+PivotalCore.h"

NSString *SETTINGS_HOST_PREFERENCE_KEY = @"host_preference";
NSString *SETTINGS_PORT_PREFERENCE_KEY = @"port_preference";
NSString *CUSTOM_HOST_PREFERENCE_KEY = @"custom_host_preference";
NSString *USE_CUSTOM_HOST_PREFERENCE_KEY = @"use_custom_host_preference";


static const NSTimeInterval TIMEOUT = 60; // 3 minutes

static Aura *aura__;

@implementation Aura


+ (void)initialize {
    aura__ = [[Aura alloc] init];
}

+ (id)aura {
    return aura__;
}

+ (NSString *)deviceID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return [NSString stringWithFormat:@"%@ (%@)", [UIDevice currentDevice].name, (__bridge NSString *) uuidStr];
}

+ (NSString *)hostName {
    NSLog(@"server info %@",[NSString stringWithFormat:@"%@:%ld", [Aura serverName], (long)[[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_PORT_PREFERENCE_KEY]]);
    
    return [NSString stringWithFormat:@"%@:%ld", [Aura serverName], (long)[[NSUserDefaults standardUserDefaults] integerForKey:SETTINGS_PORT_PREFERENCE_KEY]];
}

+ (NSString *)serverName {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:USE_CUSTOM_HOST_PREFERENCE_KEY] 
        && [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_HOST_PREFERENCE_KEY]) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:CUSTOM_HOST_PREFERENCE_KEY];
    }
	else return [[NSUserDefaults standardUserDefaults] stringForKey:SETTINGS_HOST_PREFERENCE_KEY];
}

- (NSURLRequest *)buildRequestForPath:(NSString *)path andData:(NSString *)dataString {
    NSString *escapedUUID = [[Aura deviceID] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];//[[Aura deviceID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES];
    NSData *data = [[NSString stringWithFormat:@"%@&uuid=%@", dataString, escapedUUID] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *dataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[data length]];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setTimeoutInterval:TIMEOUT];
    NSLog(@"auraurl %@",[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", [Aura hostName], path]]);
    [request setURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/%@", [Aura hostName], path]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:data];
    
    return request;
}

#pragma mark PCKHTTPInterface protected methods
- (NSString *)host {
	return [Aura hostName];
}
#pragma mark -New Web method-
-(void)getSuggestedQuestionsForHighlight:(NSString *)section andText:(NSString* )text completionHandler:(DictionaryResponse)autocompleteResponse
{
    NSString *escapedSection = [section stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSString *escapedText = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    
    NSURLRequest *request = [self buildRequestForPath:@"suggested_questions_lists"
                                              andData:[NSString stringWithFormat:@"section=%@&text=%@", escapedSection, escapedText]];
    NSLog(@"%@",request);
  NSURLSessionDataTask *dataTask=  [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^( NSData *data,NSURLResponse *response,NSError *connectionError)
     {
         if (!connectionError)
         {
             NSString *responseString =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; //xml data
                        NSLog(@"Response String = \n%@", responseString);
             
             NSError *error = nil;
             NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
             
                 NSLog(@"%@",responseDictionary);
                 
                 // If success
                 if (200==[(NSHTTPURLResponse *)response statusCode])
                 {
                    
                     autocompleteResponse(YES, responseString,data);
                 }
                 else{
                     autocompleteResponse(NO, @"We are unable to parse server response.",nil);
                 }
         }
         else
         {
             autocompleteResponse(NO, @"Please check your network connection.",nil);
         }
     }];
    [dataTask resume];
}
-(void)answerQuestionForQ:(NSString *)question completionHandler:(DictionaryResponse)autocompleteResponse
{
    NSString *escapedQuestion = [question stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];//[question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES];
    
    NSURLRequest *request = [self buildRequestForPath:@"answers"
                                              andData:[NSString stringWithFormat:@"question=%@", escapedQuestion]];
    NSLog(@"%@",request);
    NSURLSessionDataTask *dataTask=  [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^( NSData *data,NSURLResponse *response,NSError *connectionError)
                                      {
                                          if (!connectionError)
                                          {
                                              NSString *responseString =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; //xml data
                                              NSLog(@"Response String = \n%@", responseString);
                                              
                                              NSError *error = nil;
                                              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                                              
                                              NSLog(@"%@",responseDictionary);
                                              
                                              // If success
                                              if (200==[(NSHTTPURLResponse *)response statusCode])
                                              {
                                                  
                                                  autocompleteResponse(YES, responseString,data);
                                              }
                                              else{
                                                  autocompleteResponse(NO, @"We are unable to parse server response.",nil);
                                              }
                                              
                                          }
                                          else
                                          {
                                              autocompleteResponse(NO, @"Please check your network connection.",nil);
                                          }
                                      }];
    [dataTask resume];
    
}
-(void)getSuggestedQuestionsList:(NSString *)query andKeywords:(NSString *)keywords completionHandler:(DictionaryResponse)autocompleteResponse
{
    NSString *escapedQuestion = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];//[query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES];
    NSString *escapedText = [keywords stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];//[keywords stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES];
    
    
    NSURLRequest *request = [self buildRequestForPath:@"formatted_structured_questions_lists"
                                              andData:[NSString stringWithFormat:@"concept=%@&question=%@", escapedText, escapedQuestion]];
    NSURLSessionDataTask *dataTask=  [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^( NSData *data,NSURLResponse *response,NSError *connectionError)
                                      {
                                          if (!connectionError)
                                          {
                                              NSString *responseString =  [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; //xml data
                                              NSLog(@"Response String = \n%@", responseString);
                                              
                                              NSError *error = nil;
                                              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                                              
                                              NSLog(@"%@",responseDictionary);
                                              
                                              // If success
                                              if (200==[(NSHTTPURLResponse *)response statusCode])
                                              {
                                                  
                                                  autocompleteResponse(YES, responseString,data);
                                              }
                                              else{
                                                  autocompleteResponse(NO, @"We are unable to parse server response.",nil);
                                              }
                                              
                                          }
                                          else
                                          {
                                              autocompleteResponse(NO, @"Please check your network connection.",nil);
                                          }
                                      }];
    [dataTask resume];
}

@end
