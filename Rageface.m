//
//  Rageface.m
//  ragr
//
//  Created by Ludwig Schubert on 16.08.12.
//
//

#import "Rageface.h"

@implementation Rageface

@dynamic humanSearchableDescription;
-(NSString *)humanSearchableDescription
{
    return [NSString stringWithFormat:@"%@ %@", self.tags, self.category];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@, %@", self.filename, self.category, self.tags];
}

@dynamic idFromAPI;
@dynamic revision;
@dynamic category;
@dynamic filename;
@dynamic url;
@dynamic tags;
@dynamic timesCopied;

@end
