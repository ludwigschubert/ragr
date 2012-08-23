//
//  LSViewController.h
//  ragr
//
//  Created by Ludwig Schubert on 10.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRGridView.h"

@interface LSViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, RKObjectLoaderDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UICollectionView *gridView;
@property (strong, nonatomic) UIView *logoHeaderView;

@end
