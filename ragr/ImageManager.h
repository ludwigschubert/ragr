//
//  ImageManager.h
//  ragr
//
//  Created by Ludwig Schubert on 24.08.12.
//
//

#import <Foundation/Foundation.h>

@protocol ImageManagerDelegate <NSObject>

- (void)receiveImage:(UIImage*)image ForKey:(NSString*)imageKey;

@end

@interface ImageManager : NSObject

+ (void)requestImageWithKey:(NSString*)imageKey withCallback:(id<ImageManagerDelegate>)delegate;

+ (void)cancelRequestForImageWithKey:(NSString*)imageKey;
+ (void)cancelAllRequestsForCallback:(id<ImageManagerDelegate>)delegate;


@end
