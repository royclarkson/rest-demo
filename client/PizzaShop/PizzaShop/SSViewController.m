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
//  SSViewController.m
//  PizzaShop
//
//  Created by Roy Clarkson on 2/11/13.
//


#import "SSViewController.h"
#import "SSBasesViewController.h"
#import "SSToppingsViewController.h"
#import "SSPizzasViewController.h"
#import "SSPizzaOrdersViewController.h"

@interface SSViewController ()

@property (strong, nonatomic) NSArray *menuItems;
@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) SSBasesViewController *basesViewController;
@property (strong, nonatomic) SSToppingsViewController *toppingsViewController;
@property (strong, nonatomic) SSPizzasViewController *pizzasViewController;
@property (strong, nonatomic) SSPizzaOrdersViewController *pizzaOrdersViewController;

@end

@implementation SSViewController


#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Pizza Shop";
    self.menuItems = @[@"Bases", @"Toppings", @"Pizzas", @"Pizza Orders"];
    self.basesViewController = [[SSBasesViewController alloc] initWithNibName:nil bundle:nil];
    self.toppingsViewController =[[SSToppingsViewController alloc] initWithNibName:nil bundle:nil];
    self.pizzasViewController = [[SSPizzasViewController alloc] initWithNibName:nil bundle:nil];
    self.pizzaOrdersViewController = [[SSPizzaOrdersViewController alloc] initWithNibName:nil bundle:nil];
    self.viewControllers = @[self.basesViewController, self.toppingsViewController, self.pizzasViewController, self.pizzaOrdersViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *vc = [self.viewControllers objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"menuItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    
    NSString *label = [self.menuItems objectAtIndex:indexPath.row];
    [cell.textLabel setText:label];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

@end
