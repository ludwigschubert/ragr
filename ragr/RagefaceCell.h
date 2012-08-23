//
//  RagefaceCell.h
//  ragr
//
//  Created by Ludwig Schubert on 27.07.12.
//
//

#import <UIKit/UIKit.h>

#import "ImageManager.h"

@class Rageface;

@interface RagefaceCell : UICollectionViewCell <ImageManagerDelegate>

@property (nonatomic, strong) Rageface *rageface;

+ (NSString*)cellIdentifier;

@end
