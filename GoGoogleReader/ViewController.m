//
//  ViewController.m
//  GoGoogleReader
//
//  Created by Tuo Huang on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "ReaderRetrieve.h"
#import "SubscriptionViewController.h"

@implementation ViewController
@synthesize username = _username;
@synthesize password = _password;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"GoGoogleReader";
    self.username.returnKeyType = UIReturnKeyDone;
    self.password.returnKeyType = UIReturnKeyDone;
    self.password.secureTextEntry = YES;
    self.username.text = @"just.test.ggr@gmail.com";
    self.password.text = @"justatest";
}

- (void)viewDidUnload
{
    [self setUsername:nil];
    [self setPassword:nil];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)loginButtonPressed:(id)sender {
    NSLog(@"username: %@, password: %@", self.username.text, self.password.text);
    ReaderRetrieve *reader = [[ReaderRetrieve alloc] init];
    reader.username = self.username.text;
    reader.password = self.password.text;
    NSDictionary *result = [reader getRSSFromGoogle];
    NSLog(@"============================================ %@", result);
//    NSDate *future = [NSDate dateWithTimeIntervalSinceNow: 0.06 ];
//    [NSThread sleepUntilDate:future];
    SubscriptionViewController *subscriptionController = [[SubscriptionViewController alloc] init];
    subscriptionController.subscriptions = result;

    [self.navigationController pushViewController:subscriptionController animated:YES];
}

-(IBAction)textFieldDoneEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}
-(IBAction)backgroundTap:(id)sender{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
}
@end
