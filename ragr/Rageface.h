//
//  Rageface.h
//  ragr
//
//  Created by Ludwig Schubert on 10.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Rageface : NSObject

@property (nonatomic, readonly) UIImage *thumbnail;
@property (nonatomic, readonly) UIImage *fullResolutionImage;
@property (nonatomic, readonly) NSString *humanSearchableDescription;
@property (nonatomic, assign, getter=isHasCachedImage) BOOL hasCachedImage;

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *humanReadableDescription;
@property (nonatomic, copy) NSString *tags;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, assign) NSUInteger timesCopied;
@property (nonatomic, assign) NSUInteger views;

@end
