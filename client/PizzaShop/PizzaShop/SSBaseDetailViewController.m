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
//  SSBaseDetailViewController.m
//  PizzaShop
//
//  Created by Roy Clarkson on 2/12/13.
//

#import "SSBaseDetailViewController.h"
#import "SSConnectionSettings.h"

@interface SSBaseDetailViewController ()

- (void)saveDataDidFinishWithData:(NSData *)data;
- (void)saveDataDidFailWithError:(NSError *)error;

@end

@implementation SSBaseDetailViewController

- (IBAction)saveData:(id)sender
{
    self.base.name = self.textName.text;
    
    NSURL *url = [SSConnectionSettings urlWithFormat:@"/bases"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSError *jsonError;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:[self.base dictionaryValue] options:0 error:&jsonError];
    NSLog(@"%@", [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]);
	NSString *contentLength = [NSString stringWithFormat:@"%d", [postData length]];
    
	[request setHTTPMethod:@"PUT"];
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
         
         if (statusCode == 200 && error == nil)
         {
             [self saveDataDidFinishWithData:data];
         }
         else if (error)
         {
             [self saveDataDidFailWithError:error];
         }
         else if (statusCode != 200)
         {
             // check and handle status code
             NSLog(@"HTTP Status: %i", statusCode);
         }
     }];
}

- (void)saveDataDidFinishWithData:(NSData *)data
{
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    self.base = [[SSBase alloc] initWithDictionary:dictionary];
    [self.navigationController popViewControllerAnimated:YES];
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
    
    self.title = @"Base Detail";
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveData:)];
    self.navigationItem.rightBarButtonItem = saveButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.base)
    {
        self.textName.text = self.base.name;
    }
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textName resignFirstResponder];
    return NO;
}

@end
