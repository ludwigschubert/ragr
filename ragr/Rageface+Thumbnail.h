//
//  Rageface+Thumbnail.h
//  ragr
//
//  Created by Ludwig Schubert on 16.08.12.
//
//

#import "Rageface.h"

#import <SDWebImage/SDWebImageManagerDelegate.h>

@interface Rageface (Thumbnail) <SDWebImageManagerDelegate>

@property (readonly) UIImage *imageAtNativeResolution;
@property (readonly) UIImage *imageThumbnail;
@property (readonly) UIImage *imageForSending;

@property (readonly) NSString *nativeResolutionKey;
@property (readonly) NSString *thumbnailKey;
@property (readonly) NSString *forSendingKey;

- (void)thumbnailInCallback:(void(^)(UIImage *thumbnail, Rageface *rageface))callbackBlock;

@end
