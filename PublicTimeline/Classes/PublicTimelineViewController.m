//
//  RootViewController.m
//  PublicTimeline
//
//  Created by Rahul Malik on 4/23/11.
//  Copyright University of Illinois at Urbana-Champaign 2011. All rights reserved.
//

#import "PublicTimelineViewController.h"
#import "JSON.h"
#import "StatusUpdate.h"
#import "StatusUpdate+Loader.h"

// Twitter Public Timeline api endpoint
// API Documentation: http://dev.twitter.com/doc/get/statuses/public_timeline
NSString * const kPublicTimelineRequestURL = @"http://api.twitter.com/1/statuses/public_timeline.json";

// cell style constants
NSString * const kUserScreenNameFont = @"Helvetica-Bold";
NSString * const kStatusUpdateFont = @"Helvetica";

// cell tag constants
int const kUserScreenNameViewTag = 1;
int const kStatusUpdateViewTag = 2;

@implementation PublicTimelineViewController

@synthesize fetchedResultsController, managedObjectContext;


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	
	// create a refresh button to fetch the latest public timeline
    UIBarButtonItem* refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPublicTimeline)];
    self.navigationItem.rightBarButtonItem = refreshButton;
    [refreshButton release];
	
	// add a loading indicator to show that a request is in progress
	_loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:_loadingSpinner] autorelease];
	
	// initial fetch request results
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
}

- (void)viewDidUnload {
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	fetchedResultsController = nil;
	_loadingSpinner = nil;
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return YES;
}

#pragma mark -
#pragma mark Twitter API Calls

- (void)refreshPublicTimeline {	
	// show the loading indicator
	[_loadingSpinner startAnimating];
	
	// create the api request to fetch the public timeline
	NSURLRequest * publicTimelineRequest = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:kPublicTimelineRequestURL]] autorelease];
	
	// for this example we'll handle the response but 
	NSURLConnection * requestConnection = [[NSURLConnection connectionWithRequest:publicTimelineRequest delegate:self] retain];

	// initialize where we will store the response
	_jsonResponse =  [[NSMutableData data] retain];

	// send request
	[requestConnection start];
}

- (void)saveTweets:(NSArray *)tweets {
	// read the tweet attributes and insert new objects in core data
	for (NSDictionary * tweet in tweets){
		StatusUpdate * statusUpdate = [NSEntityDescription insertNewObjectForEntityForName:@"StatusUpdate" inManagedObjectContext:managedObjectContext];
		[statusUpdate loadFromJSONObject:tweet];
	}
	
	// save the context
	NSError *error = nil;
	if (![managedObjectContext save:&error]){
		NSLog(@"Save error %@, %@", error, [error userInfo]);
	}
	
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to our jsonResponse.
    [_jsonResponse appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    [_jsonResponse setLength:0];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{	
	// parse the the json response -> nsarray
	SBJsonParser * jsonParser = [[SBJsonParser alloc] init];
	NSArray * tweets = [jsonParser objectWithData:_jsonResponse];

	// save the tweets to core data
	[self saveTweets:tweets];
		
	// release the connection, and the data object
    [connection release];
    [_jsonResponse release];

	// stop the loading indicator
	[_loadingSpinner stopAnimating];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    [_jsonResponse release];
	
	// request is no longer in progress, stop the animation
	[_loadingSpinner stopAnimating];
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"TweetCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
	// Configure the cell.
	StatusUpdate *aStatusUpdate = [fetchedResultsController objectAtIndexPath:indexPath];
	
	id userName = [cell.contentView viewWithTag:kUserScreenNameViewTag];
	id tweetUpdate = [cell.contentView viewWithTag:kStatusUpdateViewTag];
	
	if (!userName){
		userName = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 2.0, cell.contentView.frame.size.width, 14.0)];
		[userName setFont:[UIFont fontWithName:kUserScreenNameFont size:12.0]];
		[userName setTag:kUserScreenNameViewTag];
		[cell.contentView addSubview:userName];
		[userName release];
	} else {
		userName = (UILabel *)userName;
	}
	if (!tweetUpdate){
		tweetUpdate = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 15.0, cell.contentView.frame.size.width - 10.0, cell.contentView.frame.size.height - 15.0)];
		[tweetUpdate setFont:[UIFont fontWithName:kStatusUpdateFont size:14.0]];
		[tweetUpdate setTag:kStatusUpdateViewTag];	
		[cell.contentView addSubview:tweetUpdate];
		[tweetUpdate release];
	} else {
		tweetUpdate = (UILabel *)tweetUpdate;
	}

	// update the user name label
	[userName setText:[aStatusUpdate userName]];

	// update the status label
	[tweetUpdate setText:[aStatusUpdate status]];
	
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
	*/
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"StatusUpdate" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:managedObjectContext 
																								  sectionNameKeyPath:nil 
																										   cacheName:@"Tweets"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];;
	
	return fetchedResultsController;
}    


// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	// In the simplest, most efficient, case, reload the table view.
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}


- (void)dealloc {
	[fetchedResultsController release];
	[managedObjectContext release];
	[_loadingSpinner release];
    [super dealloc];
}


@end

