//
//  Copyright 2013 Roy Clarkson.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//
//  SSCreateToppingViewController.m
//  PizzaShop
//
//  Created by Roy Clarkson on 2/14/13.
//

#import "SSCreateToppingViewController.h"
#import "SSTopping.h"
#import "SSConnectionSettings.h"

@interface SSCreateToppingViewController ()

- (void)saveDataDidFinishWithData:(NSData *)data;
- (void)saveDataDidFailWithError:(NSError *)error;

@end

@implementation SSCreateToppingViewController

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)saveData:(id)sender
{
    SSTopping *topping = [[SSTopping alloc] initWithName:self.textName.text];
    
    NSURL *url = [SSConnectionSettings urlWithFormat:@"/toppings"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSData *postData = [NSJSONSerialization dataWithJSONObject:[topping dictionaryValue] options:0 error:nil];
	NSString *contentLength = [NSString stringWithFormat:@"%d", [postData length]];
    
    NSLog(@"%@", [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]);
    
	[request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
	[request setHTTPBody:postData];
	
	NSLog(@"%@", request);
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
         NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
         
         if (statusCode == 201 && error == nil)
         {
             [self saveDataDidFinishWithData:data];
         }
         else if (error)
         {
             [self saveDataDidFailWithError:error];
         }
         else if (statusCode != 201)
         {
             // check and handle status code
             NSLog(@"HTTP Status Code: %i", statusCode);
         }
     }];
}

- (void)saveDataDidFinishWithData:(NSData *)data
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)saveDataDidFailWithError:(NSError *)error
{
    // handle error
    NSLog(@"%@", [error localizedDescription]);
}


#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.topItem.title = @"Create Topping";
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveData:)];
    self.navigationItem.rightBarButtonItem = saveButton;
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textName resignFirstResponder];
    return NO;
}

@end
