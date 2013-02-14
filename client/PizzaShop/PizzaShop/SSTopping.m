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
//  SSTopping.m
//  PizzaShop
//
//  Created by Roy Clarkson on 2/11/13.
//

#import "SSTopping.h"

@implementation SSTopping

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init])
    {
        if (dictionary)
        {
            self.toppingId = [dictionary objectForKey:@"id"];
            self.name = [[dictionary objectForKey:@"name"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            self.version = [dictionary objectForKey:@"version"];
        }
    }
    return self;
}

- (id)initWithName:(NSString *)name
{
    if (self = [super init])
    {
        self.toppingId = (id)[NSNull null];
        self.name = name;
        self.version = (id)[NSNull null];
    }
    return self;
}

- (NSDictionary *)dictionaryValue
{
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                self.toppingId, @"id",
                                [self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], @"name",
                                self.version, @"version",
                                nil];
    return dictionary;
}

@end
