//
//  RagefaceCell.h
//  ragr
//
//  Created by Ludwig Schubert on 27.07.12.
//
//

#import <UIKit/UIKit.h>
#import "NRGridViewCell.h"

@class Rageface;

@interface RagefaceCell : NRGridViewCell

@property (nonatomic, strong) Rageface *rageface;

+ (NSString*)cellIdentifier;

@end
