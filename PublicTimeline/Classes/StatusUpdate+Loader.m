//
//  StatusUpdate+Loader.m
//  PublicTimeline
//
//  Created by Rahul Malik on 4/25/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "StatusUpdate+Loader.h"

// json key constants
NSString * const kStatusTextParam = @"text";
NSString * const kUserInfoParam = @"user";
NSString * const kUserScreenNameParam = @"screen_name";
NSString * const kCreatedDateParam = @"created_at";

// created date parsing format (Mon Apr 25 07:55:24 +0000)
NSString * const kCreatedDateFormat = @"EEE LLL dd HH:mm:ss Z yyyy";

@implementation StatusUpdate(Loader)
	- (void) loadFromJSONObject:(NSDictionary *)jsonObj {
		// load the status message
		[self setStatus:[jsonObj objectForKey:kStatusTextParam]];
		
		// load the user name
		NSDictionary * userInfo = [jsonObj objectForKey:kUserInfoParam];
		[self setUserName:[userInfo objectForKey:kUserScreenNameParam]];
		
		// load the created date
		static NSDateFormatter * formatter;
		if (!formatter){
			formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:kCreatedDateFormat];
		}
		
		[self setCreatedDate:[formatter dateFromString:[jsonObj objectForKey:kCreatedDateParam]]];
	}
@end
