//
//  DataStore.h
//  RWE Energierechner
//
//  Created by Ludwig Schubert on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataStore : NSObject

+ (id)sharedInstance;

@property (nonatomic, strong) NSMutableArray *storedData;
@property (nonatomic, strong) NSMutableArray *favorites;

- (void)save;

@end
