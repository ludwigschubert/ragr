//
//  Rageface.m
//  ragr
//
//  Created by Ludwig Schubert on 10.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Rageface.h"

@interface Rageface ()

@end

#define THUMBNAIL_SUFFIX 					@"_thumb"

@implementation Rageface

#pragma mark - Properties
@synthesize hasCachedImage;

@dynamic thumbnail;
- (UIImage *)thumbnail
{
    NSString *thumbnailName = [NSString stringWithFormat:@"%@%@", self.filename, THUMBNAIL_SUFFIX];
    UIImage *thumb = [UIImage imageNamed:thumbnailName];
    if (thumb) {
        self.hasCachedImage = YES;
        return thumb;
    } else {
        self.hasCachedImage = YES;
        return [self fullResolutionImage];
    }
}

@dynamic fullResolutionImage;
-(UIImage *)fullResolutionImage
{
    return [UIImage imageNamed:self.filename];
}

@dynamic humanSearchableDescription;
-(NSString *)humanSearchableDescription
{
    return [NSString stringWithFormat:@"%@ %@ %@", self.humanReadableDescription, self.tags, self.category];
}

@synthesize filename;
@synthesize humanReadableDescription;
@synthesize timesCopied;
@synthesize tags;
@synthesize category;
@synthesize views;

/*  Keyed Archiving */
//
- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject:self.filename forKey:@"filename"];
    [encoder encodeObject:self.humanReadableDescription forKey:@"humanReadableDescription"];
    [encoder encodeObject:self.tags forKey:@"tags"];
    [encoder encodeObject:self.category forKey:@"category"];
    [encoder encodeInteger:self.timesCopied forKey:@"timesCopied"];
    [encoder encodeInteger:self.views forKey:@"views"];
}

- (id)initWithCoder:(NSCoder *)decoder 
{
    self = [super init];
    if (self) {
        self.filename = [decoder decodeObjectForKey:@"filename"];
        self.humanReadableDescription = [decoder decodeObjectForKey:@"humanReadableDescription"];
        self.tags = [decoder decodeObjectForKey:@"tags"];
        self.category = [decoder decodeObjectForKey:@"category"];
        self.timesCopied = [decoder decodeIntegerForKey:@"timesCopied"];
        self.views = [decoder decodeIntegerForKey:@"views"];
        
        self.hasCachedImage = NO;
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %@, %@", self.humanReadableDescription, self.filename, self.category, self.tags];
}

@end
