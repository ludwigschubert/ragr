//
//  RagefaceCell.m
//  ragr
//
//  Created by Ludwig Schubert on 27.07.12.
//
//

#import "RagefaceCell.h"
#import "Rageface.h"

@implementation RagefaceCell

static NSString* cellIdentifier = @"RagefaceCellIdentifier";

+ (NSString*)cellIdentifier
{
    return cellIdentifier;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectZero;
        self.selectionBackgroundView = nil;
        self.opaque = YES;
        self.imageView.opaque = YES;
        self.imageView.backgroundColor = [UIColor whiteColor];
        
        //Variable size Background Image
        UIImage *cellBackgroundImage = [UIImage imageNamed:@"cellBackground"];
        UIImage *stretchableCellBackgroundImage = [cellBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        self.backgroundView = [[UIImageView alloc] initWithImage:stretchableCellBackgroundImage];
        self.backgroundView.frame = self.frame;
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.autoresizesSubviews = YES;
        
        self.selectionBackgroundView = nil;
    }
    return self;
}

@synthesize rageface = _rageface;

- (void)setRageface:(Rageface *)rageface {
    _rageface = rageface;
    
    if (_rageface.hasCachedImage) {
        self.imageView.image = _rageface.thumbnail;
    } else {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
            UIImage *image = rageface.thumbnail;
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
                [self setNeedsLayout];
                
                self.alpha = 0.0;
                [UIView animateWithDuration:0.33
                                 animations:^{
                                     self.alpha = 1.0;
                                 }];
            });
        });
    }
}

@end
