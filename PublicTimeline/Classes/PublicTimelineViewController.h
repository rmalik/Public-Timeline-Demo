//
//  RootViewController.h
//  PublicTimeline
//
//  Created by Rahul Malik on 4/23/11.
//  Copyright University of Illinois at Urbana-Champaign 2011. All rights reserved.
//

@interface PublicTimelineViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	NSMutableData *_jsonResponse;
	UIActivityIndicatorView * _loadingSpinner;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
