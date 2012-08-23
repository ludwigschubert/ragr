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

@property (nonatomic, retain) NSNumber * idFromAPI;
@property (nonatomic, retain) NSNumber * revision;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) id url;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSNumber * timesCopied;

@end
