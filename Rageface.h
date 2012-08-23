//
//  Rageface.h
//  ragr
//
//  Created by Ludwig Schubert on 16.08.12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Rageface : NSManagedObject

@property (nonatomic, readonly) NSString *humanSearchableDescription;

@property (nonatomic) int64_t idFromAPI;
@property (nonatomic) int64_t revision;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic) int64_t timesCopied;

@end
