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
//  SSToppingsViewController.m
//  PizzaShop
//
//  Created by Roy Clarkson on 2/11/13.
//

#import "SSToppingsViewController.h"
#import "SSConnectionSettings.h"
#import "SSTopping.h"
#import "SSToppingDetailViewController.h"
#import "SSCreateToppingViewController.h"

@interface SSToppingsViewController ()

@property (strong, nonatomic) NSArray *toppings;

- (void)fetchDataDidFinishWithData:(NSData *)data;
- (void)fetchDataDidFailWithError:(NSError *)error;
- (void)updateTableData:(NSData *)data;
- (void)deleteTopping:(SSTopping *)topping;
- (void)deleteDidFinishWithData:(NSData *)data;
- (void)deleteDidFailWithError:(NSError *)error;

@end

@implementation SSToppingsViewController

- (IBAction)fetchData:(id)sender
{
    NSURL *url = [SSConnectionSettings urlWithFormat:@"/toppings"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSLog(@"%@", request);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
         if (statusCode == 200 && data.length > 0 && error == nil)
         {
             [self fetchDataDidFinishWithData:data];
         }
         else if (error)
         {
             [self fetchDataDidFailWithError:error];
         }
         else if (statusCode != 200)
         {
             // check and handle status code
             NSLog(@"HTTP Status: %ld", (long)statusCode);
         }
     }];
}

- (void)fetchDataDidFinishWithData:(NSData *)data
{
    [self updateTableData:data];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)fetchDataDidFailWithError:(NSError *)error
{
    // handle error
    NSLog(@"%@", [error localizedDescription]);
    [self.refreshControl endRefreshing];
}

- (void)updateTableData:(NSData *)data
{
    NSError *error;
    NSArray *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!error)
    {
        NSLog(@"%@", results);
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [results enumerateObjectsUsingBlock:^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
            SSTopping *topping = [[SSTopping alloc] initWithDictionary:dictionary];
            [array addObject:topping];
        }];
        self.toppings = array;
    }
}

- (IBAction)createTopping:(id)sender
{
    SSCreateToppingViewController *createToppingViewController = [[SSCreateToppingViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:createToppingViewController animated:YES completion:NULL];
}

- (void)deleteTopping:(SSTopping *)topping
{
    NSURL *url = [SSConnectionSettings urlWithFormat:@"/toppings/%@", topping.toppingId];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
	[request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	
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
             [self deleteDidFinishWithData:data];
         }
         else if (error)
         {
             [self deleteDidFailWithError:error];
         }
         else if (statusCode != 200)
         {
             // check and handle status code
             NSLog(@"HTTP Status: %i", statusCode);
         }
     }];
}

- (void)deleteDidFinishWithData:(NSData *)data
{
    [self updateTableData:data];
    [self.tableView reloadData];
}

- (void)deleteDidFailWithError:(NSError *)error
{
    // handle error
    NSLog(@"%@", [error localizedDescription]);
}


#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Toppings";
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchData:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createTopping:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.toppings = nil;
}


#pragma mark - 
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.toppings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    SSTopping *topping = [self.toppings objectAtIndex:indexPath.row];
    [cell.textLabel setText:topping.name];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SSTopping *topping = [self.toppings objectAtIndex:indexPath.row];
        
        // remove topping from local array and update table
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.toppings];
        [tempArray removeObjectAtIndex:indexPath.row];
        self.toppings = tempArray;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        // send RESTful request to delete topping
        [self deleteTopping:topping];
    }
}


#pragma mark - 
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSToppingDetailViewController *detailViewController = [[SSToppingDetailViewController alloc] initWithNibName:nil bundle:nil];
    detailViewController.topping = [self.toppings objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
