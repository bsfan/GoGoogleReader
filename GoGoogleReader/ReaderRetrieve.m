//
//  ReaderRetrieve.m
//  GoGoogleReader
//
//  Created by Tuo Huang on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReaderRetrieve.h"
#import "SBJson.h"

@implementation ReaderRetrieve

-(void)getRSSFromGoogle{
    NSLog(@"-------------");
    NSString *gUserString = @"clarkhtse@gmail.com";
    NSString *gPassString = @"";
    NSString *GOOGLE_CLIENT_AUTH_URL = @"https://www.google.com/accounts/ClientLogin?client=YourClient";
    NSString *gSourceString = @"YourClient";
    
    /*  Google clientLogin API:
     Content-type: application/x-www-form-urlencoded
     Email=userName
     Passwd=password
     accountType=HOSTED_OR_GOOGLE
     service=xapi
     source = @"myComp-myApp-1.`0"
     */
    
    //define our return objects
    BOOL authOK;
    NSString *authMessage = [[NSString alloc] init];
    NSArray *returnArray = nil;
    //begin NSURLConnection prep:
    NSMutableURLRequest *httpReq = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:GOOGLE_CLIENT_AUTH_URL] ];
    [httpReq setTimeoutInterval:30.0];
    //[httpReq setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [httpReq setHTTPMethod:@"POST"];
    //set headers
    [httpReq addValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];
    //set post body
    NSString *requestBody = [[NSString alloc] 
                             initWithFormat:@"Email=%@&Passwd=%@&service=reader&accountType=HOSTED_OR_GOOGLE&source=%@",
                             gUserString, gPassString, [NSString stringWithFormat:@"%@%d", gSourceString]];
    
    [httpReq setHTTPBody:[requestBody dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = nil;
    NSString *responseStr = nil;
    NSArray *responseLines = nil;
    NSString *errorString;
    //NSDictionary *dict;
    int responseStatus = 0;
    //this should be quick, and to keep same workflow, we'll do this sync.
    //this should also get us by without messing with threads and run loops on Tiger.
    data = [NSURLConnection sendSynchronousRequest:httpReq returningResponse:&response error:&error];
    
    if ([data length] > 0) {
        responseStr = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        NSLog(@"Response From Google: %@", responseStr);
//        NSLog(@"Response Data From Google: %@", data);
        responseStatus = [response statusCode];
        //dict = [[NSDictionary alloc] initWithDictionary:[response allHeaderFields]];
        //if we got 200 authentication was successful
        if (responseStatus == 200 ) {
            authOK = TRUE;
            authMessage = @"Successfully authenticated with Google. You can now start viewing your unread feeds.";
            responseLines = [responseStr componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            NSString *SID, *auth;
            for(NSString *pair in responseLines){
                NSArray *keyValue = [pair componentsSeparatedByString:@"="];
                if([[keyValue objectAtIndex:0] isEqualToString:@"SID"])
                    SID = [keyValue objectAtIndex:1];
                else if ([[keyValue objectAtIndex:0] isEqualToString:@"Auth"])
                    auth = [keyValue objectAtIndex:1];
            }
          
            //set expiry date to 7 days from now
            NSDate *expiryDate = [NSDate dateWithTimeIntervalSinceNow:3600 * 24 * 7];
            
            //compose the session according to http://code.google.com/p/pyrfeed/wiki/GoogleReaderAPI
            NSDictionary *clientSessionProp = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"0", NSHTTPCookieVersion,
                                             expiryDate, NSHTTPCookieExpires,
                                             @"SID", NSHTTPCookieName,
                                             SID, NSHTTPCookieValue,
                                             @".google.com", NSHTTPCookieDomain,
                                             @"/", NSHTTPCookiePath,
                                             nil];
            
            NSHTTPCookie* clientCookie = [NSHTTPCookie cookieWithProperties:clientSessionProp];
            
            //milestone 1
            //get subscirption list
            u_int64_t now = abs(round([[NSDate date] timeIntervalSince1970] * 1000));
            NSURL *subscriptionListUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/reader/api/0/subscription/list?output=json&client=scroll&ck=%qu", now]];
            
            NSLog(@"==========send subscript ajax: %@", subscriptionListUrl);
            NSString *authParameter = [NSString stringWithFormat:@"GoogleLogin auth=%@", auth];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:subscriptionListUrl cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10];

            
            [request setHTTPMethod:@"GET"];
            [request setValue:authParameter forHTTPHeaderField:@"Authorization"];
            //[request setValue:clientCookie forHTTPHeaderField:@"Cookie"];
//            
//            NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies: [NSArray arrayWithObjects: clientCookie, nil]];
//            [request setAllHTTPHeaderFields:headers];
            [request setHTTPShouldHandleCookies:YES];
            
            NSError *requestError = nil;
            NSURLResponse *response = nil;
            
            NSData *result =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
           
            //convert to data to human-readabe string
            NSString *responseString = [[NSString alloc] initWithData:result encoding:NSASCIIStringEncoding];
            NSLog(@"===============yes, %@", responseString);

            
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
            }
                
        }
        //403 = authentication failed.
        else if (responseStatus == 403) {
            authOK = FALSE;
            //get Error code.
            responseLines  = [responseStr componentsSeparatedByString:@"\n"];
            //find the line with the error string:
            int i;
            for (i =0; i < [responseLines count]; i++ ) {
                if ([[responseLines objectAtIndex:i] rangeOfString:@"Error="].length != 0) {
                    errorString = [responseLines objectAtIndex:i] ;
                }
            }
            
            errorString = [errorString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            /*
             Official Google clientLogin Error Codes:
             Error Code Description
             BadAuthentication  The login request used a username or password that is not recognized.
             NotVerified    The account email address has not been verified. The user will need to access their Google account directly to resolve the issue before logging in using a non-Google application.
             TermsNotAgreed The user has not agreed to terms. The user will need to access their Google account directly to resolve the issue before logging in using a non-Google application.
             CaptchaRequired    A CAPTCHA is required. (A response with this error code will also contain an image URL and a CAPTCHA token.)
             Unknown    The error is unknown or unspecified; the request contained invalid input or was malformed.
             AccountDeleted The user account has been deleted.
             AccountDisabled    The user account has been disabled.
             ServiceDisabled    The user's access to the specified service has been disabled. (The user account may still be valid.)
             ServiceUnavailable The service is not available; try again later.
             */
            
            if ([errorString  rangeOfString:@"BadAuthentication" ].length != 0) {
                authMessage = @"Please Check your Username and Password and try again.";
            }else if ([errorString  rangeOfString:@"NotVerified"].length != 0) {
                authMessage = @"This account has not been verified. You will need to access your Google account directly to resolve this";
            }else if ([errorString  rangeOfString:@"TermsNotAgreed" ].length != 0) {
                authMessage = @"You have not agreed to Google terms of use. You will need to access your Google account directly to resolve this";
            }else if ([errorString  rangeOfString:@"CaptchaRequired" ].length != 0) {
                authMessage = @"Google is requiring a CAPTCHA response to continue. Please complete the CAPTCHA challenge in your browser, and try authenticating again";
                //NSString *captchaURL = [responseStr substringFromIndex: [responseStr rangeOfString:@"CaptchaURL="].length]; 
                //either open the standard URL in a browser, or show a custom sheet with the image and send it back...
                //parse URL to append to GOOGLE_CAPTCHA_URL_PREFIX
                //but for now... just launch the standard URL.
                //[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:GOOGLE_CAPTCHA_STANDARD_UNLOCK_URL]];         
            }else if ([errorString  rangeOfString:@"Unknown" ].length != 0) {
                authMessage = @"An Unknow error has occurred; the request contained invalid input or was malformed.";
            }else if ([errorString  rangeOfString:@"AccountDeleted" ].length != 0) {
                authMessage = @"This user account previously has been deleted.";
            }else if ([errorString  rangeOfString:@"AccountDisabled" ].length != 0) {
                authMessage = @"This user account has been disabled.";
            }else if ([errorString  rangeOfString:@"ServiceDisabled" ].length != 0) {
                authMessage = @"Your access to the specified service has been disabled. Please try again later.";
            }else if ([errorString  rangeOfString:@"ServiceUnavailable" ].length != 0) {
                authMessage = @"The service is not available; please try again later.";
            }
            
        }//end 403 if
        
    }
    //check most likely: no internet connection error:
    if (error != nil) {
        authOK = FALSE;
        if ( [error domain]  == NSURLErrorDomain) {
            authMessage = @"Could not reach Google.com. Please check your Internet Connection";
        }else {
            //other error
            authMessage = [authMessage stringByAppendingFormat:@"Internal Error. Please contact notoptimal.net for further assistance. Error: %@", [error localizedDescription] ];
        }
    }
    //NSLog (@"err localized description %@", [error localizedDescription]) ;
    //NSLog (@"err localized failure reasons %@", [error localizedFailureReason]) ;
    //NSLog(@"err code  %d", [error code]) ;
    //NSLog (@"err domain %@", [error domain]) ;
    
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authentication" message:authMessage delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alertView show];

}

#pragma mark SBJsonStreamParserAdapterDelegate methods

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array {
    [NSException raise:@"unexpected" format:@"Should not get here"];
}

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict {
    NSLog(@"hellow orld : dict %@ " , dict);
    NSArray *subscriptions = [dict objectForKey:@"subscriptions"];
    for(NSDictionary *d in subscriptions)
        NSLog(@"----%@", d);
}

@end
