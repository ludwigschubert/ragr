//
//  Rageface+Thumbnail.m
//  ragr
//
//  Created by Ludwig Schubert on 16.08.12.
//
//

#import "Rageface+Thumbnail.h"

#import <SDWebImage/SDWebImageManager.h>

//static NSString *kImageAtNativeResolutionSuffix = nil;
static NSString *kImageForSendingSuffix = @"_forSending";
static NSString *kImageThumbnailSuffix = @"_thumbnail";

static CGSize kImageThumbnailSize = {100.0, 100.0};
static CGSize kImageForSendingSize = {600.0, 600.0};

@implementation Rageface (Thumbnail)

@dynamic imageAtNativeResolution;
- (UIImage *)imageAtNativeResolution
{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    return [cache imageFromKey:self.nativeResolutionKey];
}

@dynamic imageForSending;
- (UIImage *)imageForSending
{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    return [cache imageFromKey:self.nativeResolutionKey];
}

- (void)createImageForSending
{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *native = [cache imageFromKey:self.nativeResolutionKey];
    UIImage *thumbnail = [native scaleToFitSize:kImageForSendingSize];
    [cache storeImage:thumbnail forKey:self.forSendingKey];
}

@dynamic imageThumbnail;
- (UIImage *)imageThumbnail
{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *cachedThumbnail = [cache imageFromKey:self.thumbnailKey];
    return cachedThumbnail;
    
//    if (cachedThumbnail) {
//        return cachedThumbnail;
//    } else {
//        //Kick off thumbnail creation
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            [self createImageThumbnail];
//        });
//        //Return full size image for now
//        return [cache imageFromKey:self.nativeResolutionKey];
//    }
}

- (void)createImageThumbnail
{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    UIImage *native = [cache imageFromKey:self.nativeResolutionKey];
    UIImage *thumbnail = [native scaleToFitSize:kImageThumbnailSize];
    [cache storeImage:thumbnail forKey:self.thumbnailKey];
}

#pragma mark - Keys

@dynamic nativeResolutionKey;
- (NSString *)nativeResolutionKey
{
    return self.url.absoluteString;
}

@dynamic thumbnailKey;
-(NSString *)thumbnailKey
{
    return [self.nativeResolutionKey stringByAppendingString:kImageThumbnailSuffix];
}

@dynamic forSendingKey;
-(NSString *)forSendingKey
{
    return [self.nativeResolutionKey stringByAppendingString:kImageForSendingSuffix];
}

#pragma mark - Callbacks

- (void)thumbnailInCallback:(void(^)(UIImage *thumbnail, Rageface *rageface))callbackBlock
{
    SDImageCache *cache = [SDImageCache sharedImageCache];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadWithURL:self.url
                    delegate:self
                     options:SDWebImageRetryFailed
                    progress:nil
                     success:^(UIImage *image) {
                         [cache storeImage:image forKey:self.nativeResolutionKey];
                         [self createImageThumbnail];
                         callbackBlock(self.imageThumbnail, self);
                     }
                     failure:nil];
}


@end
