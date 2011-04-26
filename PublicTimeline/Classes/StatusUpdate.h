//
//  StatusUpdate.h
//  PublicTimeline
//
//  Created by Rahul Malik on 4/24/11.
//  Copyright 2011 University of Illinois at Urbana-Champaign. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface StatusUpdate :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * userName;

@end



