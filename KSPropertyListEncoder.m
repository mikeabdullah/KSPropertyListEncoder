//
//  KSPropertyListEncoder.m
//  Sandvox
//
//  Created by Mike on 10/02/2011.
//  Copyright 2011 Karelia Software. All rights reserved.
//

#import "KSPropertyListEncoder.h"


@implementation KSPropertyListEncoder

- (BOOL)allowsKeyedCoding; { return YES; }

#pragma mark Stack

/*  Maintain a stack of mutable dictionaries and arrays, that corresponds to the current object being encoded
 */

- (void)pushPropertyList:(id)object forKey:(NSString *)key;
{
    if (key)
    {
        [(NSMutableDictionary *)[_objects lastObject] setObject:object forKey:key];
    }
    else
    {
        [(NSMutableArray *)[_objects lastObject] addObject:object];
    }
    [_objects addObject:object];
}

- (void)popPropertyList;
{
    if ([_objects count] > 1) [_objects removeLastObject];
}

#pragma mark Encoding

- (void)encodeObject:(id)objv forKey:(NSString *)key
{
    // Nil needs its own simple behaviour
    if (!objv)
    {
        [[_objects lastObject] removeObjectForKey:key];
    }
    
    // Arrays get special treatment to avoid recursing through them checking plist-compatibility
    else if ([objv isKindOfClass:[NSArray class]])
    {
        [self pushPropertyList:[NSMutableArray arrayWithCapacity:[objv count]] forKey:key];
        for (id anObject in objv)
        {
            [self encodeObject:anObject forKey:nil];
        }
        [self popPropertyList];
    }
    
    // Dictionaries are already most of the way there
    else if ([objv isKindOfClass:[NSDictionary class]])
    {
        [self pushPropertyList:[NSMutableDictionary dictionary] forKey:key];
        for (NSString *aKey in objv)
        {
            [self encodeObject:[objv objectForKey:aKey] forKey:aKey];
        }
        [self popPropertyList];
    }
    
    // Native, simple plist objects archive themselves
    else if ([NSPropertyListSerialization propertyList:objv isValidForFormat:NSPropertyListXMLFormat_v1_0])
    {
        [[_objects lastObject] setObject:objv forKey:key];
    }
    
    // Everything else is turned into a dictionary
    else
    {
        [self pushPropertyList:[NSMutableDictionary dictionary] forKey:key];
        [objv encodeWithCoder:self];
        [self popPropertyList];
    }
}

- (void)encodeRootObject:(id)rootObject;
{
    // Reset the stack and go!
    [_objects release]; _objects = [[NSMutableArray alloc] init];
    [self encodeObject:rootObject forKey:nil];
}

- (id)rootPropertyList; { return [_objects objectAtIndex:0]; }

@end
