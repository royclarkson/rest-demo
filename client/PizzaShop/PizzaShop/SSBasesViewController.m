//
//  Copyright 2013 the original author or authors.
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
//  SSBasesViewController.m
//  PizzaShop
//
//  Created by Roy Clarkson on 2/11/13.
//

#import "SSBasesViewController.h"
#import "SSConnectionSettings.h"
#import "SSBase.h"
#import "SSBaseDetailViewController.h"
#import "SSCreateBaseViewController.h"

@interface SSBasesViewController ()

@property (strong, nonatomic) NSArray *bases;

- (void)fetchDataDidFinishWithData:(NSData *)data;
- (void)fetchDataDidFailWithError:(NSError *)error;
- (void)updateTableData:(NSData *)data;
- (void)deleteBase:(SSBase *)base;
- (void)deleteDidFinishWithData:(NSData *)data;
- (void)deleteDidFailWithError:(NSError *)error;

@end

@implementation SSBasesViewController

- (IBAction)fetchData:(id)sender
{
    NSURL *url = [SSConnectionSettings urlWithFormat:@"/bases"];
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
            SSBase *base = [[SSBase alloc] initWithDictionary:dictionary];
            [array addObject:base];
        }];
        self.bases = array;
    }
}

- (IBAction)createBase:(id)sender
{
    SSCreateBaseViewController *createBaseViewController = [[SSCreateBaseViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:createBaseViewController animated:YES completion:NULL];
}

- (void)deleteBase:(SSBase *)base
{
    NSURL *url = [SSConnectionSettings urlWithFormat:@"/bases/%@", base.baseId];
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
    
    self.title = @"Bases";
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchData:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createBase:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self fetchData:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.bases = nil;
}


#pragma mark - 
#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bases.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    SSBase *base = [self.bases objectAtIndex:indexPath.row];
    [cell.textLabel setText:base.name];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SSBase *base = [self.bases objectAtIndex:indexPath.row];
        
        // remove base from local array and update table
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.bases];
        [tempArray removeObjectAtIndex:indexPath.row];
        self.bases = tempArray;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        // send RESTful request to delete base
        [self deleteBase:base];
    }
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSBaseDetailViewController *detailViewController = [[SSBaseDetailViewController alloc] initWithNibName:nil bundle:nil];
    detailViewController.base = [self.bases objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

@end
