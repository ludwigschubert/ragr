//
//  Rageface+Restkit.m
//  ragr
//
//  Created by Ludwig Schubert on 16.08.12.
//
//

#import "Rageface+Restkit.h"

@implementation Rageface (Restkit)

static RKObjectMapping *_mapping = nil;

+ (RKObjectMapping*)mapping
{
    if (!_mapping) {
        RKManagedObjectMapping* mapping = [RKManagedObjectMapping mappingForEntityWithName:@"Rageface"
                                                                      inManagedObjectStore:[RKObjectManager sharedManager].objectStore];
        mapping.primaryKeyAttribute = @"idFromAPI";
        [mapping mapKeyPath:@"face_id" toAttribute:@"idFromAPI"];
        [mapping mapKeyPath:@"face_revision" toAttribute:@"revision"];
        [mapping mapKeyPath:@"face_category" toAttribute:@"category"];
        [mapping mapKeyPath:@"face_filename" toAttribute:@"filename"];
        [mapping mapKeyPath:@"face_url" toAttribute:@"url"];
        [mapping mapKeyPath:@"face_tags" toAttribute:@"tags"];

        _mapping = mapping;
    }
    return _mapping;
} //mapping

+ (void)registerMapping
{
    [[RKObjectManager sharedManager].mappingProvider setMapping:[self mapping] forKeyPath:@"items"];
} //registerMapping

+ (NSString*)resourcePath
{
    return @"";
} //resourcePath


@end
