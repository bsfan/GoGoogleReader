//
//  ViewController.h
//  GoGoogleReader
//
//  Created by Tuo Huang on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController 
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
- (IBAction)loginButtonPressed:(id)sender;

-(IBAction)textFieldDoneEditing:(UITextField *)textField;
-(IBAction)backgroundTap:(id)sender;

@end
