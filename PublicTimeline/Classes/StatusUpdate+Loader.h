//
//  StatusUpdate+Loader.h
//  PublicTimeline
//
//  Created by Rahul Malik on 4/25/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import "StatusUpdate.h"

@interface StatusUpdate(Loader) 
	// Loads attributes from JSON Response for a Status update
	- (void) loadFromJSONObject:(NSDictionary *)jsonObj;
@end
