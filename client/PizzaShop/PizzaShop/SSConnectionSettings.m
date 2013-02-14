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
//  SSConnectionSettings.m
//  PizzaShop
//
//  Created by Roy Clarkson on 2/11/13.
//

#define PIZZASHOP_URL @"http://127.0.0.1:8080/pizzashop"

#import "SSConnectionSettings.h"

@implementation SSConnectionSettings

+ (NSString *)url
{
    return PIZZASHOP_URL;
}

+ (NSURL *)urlWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2)
{
    va_list arguments;
    va_start(arguments, format);
    NSString* s = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", PIZZASHOP_URL, s]];
}

@end
