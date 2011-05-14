//
//  Topic.m
//  Tapatalk
//
//  Created by Manuel Burghard on 20.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Topic.h"


@implementation Topic
@synthesize topicID, title, forumID, hasNewPost, numberOfPosts;

- (void)dealloc {
    self.numberOfPosts = 0;
    self.hasNewPost = NO;
    self.title = nil;
    self.topicID = 0;
    self.forumID = 0;
    [super dealloc];
}


@end
