//
//  KSPropertyListEncoder.h
//  Sandvox
//
//  Created by Mike on 10/02/2011.
//  Copyright 2011 Karelia Software. All rights reserved.
//

// Encodes objects into a hierarchy of dictionaries etc.


#import <Foundation/Foundation.h>


@interface KSPropertyListEncoder : NSCoder
{
  @private
    NSMutableArray  *_objects;
}

// The object last encoded by -encodeRootObject:, usually a dictionary
- (id)rootPropertyList;

@end
