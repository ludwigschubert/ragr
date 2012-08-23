//
//  Rageface+Restkit.h
//  ragr
//
//  Created by Ludwig Schubert on 16.08.12.
//
//

#import "Rageface.h"

@interface Rageface (Restkit)

+ (RKObjectMapping*)mapping;
+ (void)registerMapping;
+ (NSString*)resourcePath;

@end
