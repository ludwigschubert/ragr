//
//  LSViewController.h
//  ragr
//
//  Created by Ludwig Schubert on 10.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NRGridView.h"

@interface LSViewController : UIViewController <NRGridViewDelegate, NRGridViewDataSource, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet NRGridView *gridView;
@property (strong, nonatomic) IBOutlet UIView *logoHeaderView;

@end
