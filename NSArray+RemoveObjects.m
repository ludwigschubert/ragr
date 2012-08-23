//
//  NSArray+RemoveObjects.m
//  ragr
//
//  Created by Ludwig Schubert on 20.08.12.
//
//

#import "NSArray+RemoveObjects.h"

@implementation NSArray (RemoveObjects)

-(NSArray*)arrayByRemovingObjectsFromArray:(NSArray *)otherArray
{
    NSMutableArray *mutableCopy = [NSMutableArray arrayWithCapacity:self.count];
    [mutableCopy addObjectsFromArray:self];
    [mutableCopy removeObjectsInArray:otherArray];
    return [NSArray arrayWithArray:mutableCopy];
}

@end
