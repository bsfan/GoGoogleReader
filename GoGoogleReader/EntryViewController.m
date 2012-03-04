//
//  EntryViewController.m
//  GoGoogleReader
//
//  Created by Tuo Huang on 3/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EntryViewController.h"
#import "SBJson.h"


@interface EntryViewController () 
@property (nonatomic, strong) NSArray *items;
@end


@implementation EntryViewController

@synthesize feedUrl = _feedUrl;
@synthesize items = _items;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableString *formatFeedUrl = [self.feedUrl mutableCopy];
    [formatFeedUrl appendString:@"/feed/"];
    
    
   //http://www.google.com/reader/api/0/stream/contents/feed/http%3A//blog.stackoverflow.com/feed/

    NSURL *subscriptionListUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/reader/api/0/stream/contents/feed/%@", [formatFeedUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
    NSLog(@"==========send subscript ajax: %@", subscriptionListUrl);
    //NSString *authParameter = [NSString stringWithFormat:@"GoogleLogin auth=%@", auth];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:subscriptionListUrl cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10];
    
    
    [request setHTTPMethod:@"GET"];
//    [request setValue:authParameter forHTTPHeaderField:@"Authorization"];
    //[request setValue:clientCookie forHTTPHeaderField:@"Cookie"];
    //            
    //            NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies: [NSArray arrayWithObjects: clientCookie, nil]];
    //            [request setAllHTTPHeaderFields:headers];
    [request setHTTPShouldHandleCookies:YES];
    
    NSError *requestError = nil;
    NSURLResponse *response = nil;
    
    NSData *result =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&requestError];
    
    //convert to data to human-readabe string
    NSString *responseString = [[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding];
//    NSLog(@"===============yes, %@", responseString);
    
    
    SBJsonStreamParserAdapter *adapter =  [[SBJsonStreamParserAdapter alloc] init];
    adapter.delegate = self;
    SBJsonStreamParser *parser = [[SBJsonStreamParser alloc] init];
    parser.delegate = adapter;
    
    // Parse the new chunk of data. The parser will append it to
    // its internal buffer, then parse from where it left off in
    // the last chunk.
    SBJsonStreamParserStatus status = [parser parse:result];
    
    if (status == SBJsonStreamParserError) {
        //tweet.text = [NSString stringWithFormat: @"The parser encountered an error: %@", parser.error];
        NSLog(@"Parser error: %@", parser.error);
        
    } else if (status == SBJsonStreamParserWaitingForData) {
        NSLog(@"Parser waiting for more data");
    }else if(status == SBJsonStreamParserComplete){
        NSLog(@"Parser done!");
        
    }             

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    
    NSDictionary *item = [self.items objectAtIndex:row];
    // Configure the cell...
    cell.textLabel.text = [item objectForKey:@"title"];
    cell.detailTextLabel.text = [item objectForKey:@"author"];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark SBJsonStreamParserAdapterDelegate methods

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    [NSException raise:@"unexpected" format:@"Should not get here"];
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
    NSLog(@"reponse: %@", dict);
    self.items = [dict objectForKey:@"items"];
}
@end
