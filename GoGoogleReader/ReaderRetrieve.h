//
//  ReaderRetrieve.h
//  GoGoogleReader
//
//  Created by Tuo Huang on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReaderRetrieve : NSObject

@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;

-(void)getRSSFromGoogle;

@end
