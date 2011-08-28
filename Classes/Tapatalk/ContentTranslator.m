//
//  ContentTranslator.m
//  Apfeltalk Magazin
//
//  Created by Manuel Burghard on 12.05.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// Tranlation table:
// :-) = \ue056
// ;-) = \ue405
// :-( = \ue058
// :-/ = \ue40e
// :-o = \ue40b
// :-D = \ue057
// :-* = \ue418
// :-p = \ue105
// :-[ = \ue058
// :-! = \ue40d
// 8-) = \ue402
// :angry: = \ue416
// :innocent: = \ue417
// :-c = \ue411

#import "ContentTranslator.h"
#import "Base64Transcoder.h"


@implementation ContentTranslator
@synthesize atTranslations, iOSTranslations;
- (NSString *)translateStringForiOS:(NSString *)aString {
    NSString *string = [NSString stringWithString:aString];
    string = [string stringByReplacingOccurrencesOfString:@"[QUOTE]" withString:@"Zitat:\n---------\n"];
    string = [string stringByReplacingOccurrencesOfString:@"[/QUOTE]" withString:@"\n---------\n"];
    string = [string stringByReplacingOccurrencesOfString:@"[quote]" withString:@"Zitat:\n---------\n"];
    string = [string stringByReplacingOccurrencesOfString:@"[/quote]" withString:@"\n---------\n"];
    string = [string stringByReplacingOccurrencesOfString:@"[Quote]" withString:@"Zitat:\n---------\n"];
    string = [string stringByReplacingOccurrencesOfString:@"[/Quote]" withString:@"\n---------\n"];
    
    if ([string isMatchedByRegex:@"\\[.+=\"\\bhttps?://[a-zA-Z0-9\\-.]+(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?\"\\].+\\[.+\\]"]) {
        NSArray *elements = [string componentsMatchedByRegex:@"\\[.+=\"\\bhttps?://[a-zA-Z0-9\\-.]+(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?\"\\].+\\[.+\\]"];
        
        for (NSString *s in elements) {
            NSString *u = [s stringByMatching:@"\\bhttps?://[a-zA-Z0-9\\-.]+(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?"];
            string = [string stringByReplacingOccurrencesOfString:s withString:u];
        }
    }
    
    if ([string isMatchedByRegex:@"\\[.+=\\bhttps?://[a-zA-Z0-9\\-.]+(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?\\].+\\[.+\\]"]) {
        NSArray *elements = [string componentsMatchedByRegex:@"\\[.+=\\bhttps?://[a-zA-Z0-9\\-.]+(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?\\].+\\[.+\\]"];
        
        for (NSString *s in elements) {
            NSString *u = [s stringByMatching:@"\\bhttps?://[a-zA-Z0-9\\-.]+(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?"];
            string = [string stringByReplacingOccurrencesOfString:s withString:u];
        }
    }
    
    string = [string stringByReplacingOccurrencesOfString:@"[/URL]" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"[URL]" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"[/url]" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"[url]" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"[/IMG]" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"[IMG]" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"[/img]" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"[img]" withString:@""];
    
    for (int i = 0; i < [iOSTranslations count]; i++) {
        NSString *currentKey = [[iOSTranslations allKeys] objectAtIndex:i];
        string = [string stringByReplacingOccurrencesOfString:currentKey withString:[iOSTranslations objectForKey:currentKey]];
    }
    
    return  string;
}

- (NSString *)translateStringForAT:(NSString *)aString {
    NSString *string = [NSString stringWithString:aString];
    
    for (int i = 0; i < [atTranslations count]; i++) {
        NSString *currentKey = [[atTranslations allKeys] objectAtIndex:i];
        string = [string stringByReplacingOccurrencesOfString:currentKey withString:[atTranslations objectForKey:currentKey]];
    }
    
    return string;
}

NSString * decodeString(NSString *aString) {
    NSData *stringData = [aString dataUsingEncoding:NSASCIIStringEncoding];
    size_t decodedDataSize = EstimateBas64DecodedDataSize([stringData length]);
    uint8_t *decodedData = calloc(decodedDataSize, sizeof(uint8_t));
    Base64DecodeData([stringData bytes], [stringData length], decodedData, &decodedDataSize);
    
    stringData = [NSData dataWithBytesNoCopy:decodedData length:decodedDataSize freeWhenDone:YES];
    
    return [[[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding] autorelease];;
    
}

NSString * encodeString(NSString *aString) {
    NSData *stringData = [aString dataUsingEncoding:NSUTF8StringEncoding];
    size_t encodedDataSize = EstimateBas64EncodedDataSize([stringData length]);
    char *encodedData = malloc(encodedDataSize);
    Base64EncodeData([stringData bytes], [stringData length], encodedData, &encodedDataSize);
    
    stringData = [NSData dataWithBytesNoCopy:encodedData length:encodedDataSize freeWhenDone:YES];
    
    return [[[NSString alloc] initWithData:stringData encoding:NSASCIIStringEncoding] autorelease];
    
}

#pragma mark -

+ (ContentTranslator *)contentTranslator {
    return [[[ContentTranslator alloc] init] autorelease];
}

- (id)init {
    self = [super init];
    if (self) {
        NSArray *atSmilies = [NSArray arrayWithObjects:@":-)", @":)", @";-)", @";)", @":-(", @":(", @":-/", @":-o", @":-D", @":-*", @":-p", @":-[", @":-!", @"8-)", @":angry:", @":innocent:", @":-c", nil];
        NSArray *iOSSmilies = [NSArray arrayWithObjects:@"\ue056", @"\ue056", @"\ue405", @"\ue405", @"\ue058", @"\ue058", @"\ue40e", @"\ue40b", @"\ue057", @"\ue418", @"\ue105", @"\ue058", @"\ue40d", @"\ue402", @"\ue416", @"\ue417", @"\ue411", nil];
        
        self.atTranslations = [NSDictionary dictionaryWithObjects:atSmilies forKeys:iOSSmilies];
        self.iOSTranslations = [NSDictionary dictionaryWithObjects:iOSSmilies forKeys:atSmilies];
    }
    return self;
}

- (void)dealloc {
    self.atTranslations = nil;
    self.iOSTranslations = nil;
    [super dealloc];
}

@end
