//
//  EntryDetailsViewController.h
//  GoGoogleReader
//
//  Created by Tuo Huang on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntryDetailsViewController : UIViewController <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (copy, nonatomic) NSString *htmlContent;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@end
