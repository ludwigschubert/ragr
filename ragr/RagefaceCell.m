//
//  RagefaceCell.m
//  ragr
//
//  Created by Ludwig Schubert on 27.07.12.
//
//

#import "RagefaceCell.h"
#import "Rageface.h"

@interface RagefaceCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation RagefaceCell

static NSString* cellIdentifier = @"RagefaceCellIdentifier";

+ (NSString*)cellIdentifier
{
    return cellIdentifier;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //Variable size Background Image
        UIImage *cellBackgroundImage = [UIImage imageNamed:@"cellBackground"];
        UIImage *stretchableCellBackgroundImage = [cellBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        self.backgroundView = [[UIImageView alloc] initWithImage:stretchableCellBackgroundImage];
        
        //Image View
        CGRect imageViewFrame = CGRectInset(self.contentView.bounds, 4.0, 4.0);
        self.imageView = [[UIImageView alloc] initWithFrame:imageViewFrame];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:self.imageView];
        self.contentView.autoresizesSubviews = YES;
        self.contentView.clipsToBounds = YES; 
    }
    return self;
}

- (void)dealloc
{
    [ImageManager cancelAllRequestsForCallback:self];
    self.rageface = nil;
    self.imageView = nil;
}

- (void)prepareForReuse
{
    [ImageManager cancelAllRequestsForCallback:self];
    
    self.imageView.image = [UIImage imageNamed:@"loadingIndicator"];
    [super prepareForReuse];
}

@synthesize rageface = _rageface;
- (void)setRageface:(Rageface *)rageface
{
    if (_rageface != rageface) {
        _rageface = rageface;
        
        UIImage *myCachedImage = [SDImageCache.sharedImageCache imageFromKey:_rageface.thumbnailKey];
        if (myCachedImage) {
            self.imageView.image = myCachedImage;
        } else {
            self.imageView.image = [UIImage imageNamed:@"loadingIndicator"];  
            [_rageface thumbnailInCallback:^(UIImage *thumbnail, Rageface *rageface) {
                if (_rageface == rageface) {
                    self.imageView.image = thumbnail;
                } else { //this cell got a new rageface before old one could display
                    ;//TODO
                }
            }];
        }
        
    }
}

@synthesize imageView;

#pragma mark - ImageManagerDelegate

- (void)receiveImage:(UIImage*)image ForKey:(NSString*)imageKey
{
    self.imageView.image = image;
    NSAssert([imageKey isEqualToString:self.rageface.thumbnailKey], @"RagefaceCell received wrong image :(");
}
@end
