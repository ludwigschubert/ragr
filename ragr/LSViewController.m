//
//  LSViewController.m
//  ragr
//
//  Created by Ludwig Schubert on 10.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "LSViewController.h"
#import "NRGridViewCell.h"
#import "Rageface.h"
#import "RagefaceCell.h"
#import "LSSearchBar.h"
#import "LSSound.h"
#import "PRTween.h"

typedef enum {
    CellSize6Columns = 1,
    CellSize5Columns = 2,
    CellSize4Columns = 3,
    CellSize3Columns = 4,
    CellSize2Columns = 5,
    CellSize1Columns = 6
} CellSize;

CGSize CGSizeFromCellSize(CellSize cellSize);
CGSize CGSizeFromCellSize(CellSize cellSize)
{
    switch (cellSize) {
        case CellSize1Columns:   return CGSizeMake(300, 300);
        case CellSize2Columns:   return CGSizeMake(150, 150);
        case CellSize3Columns:   return CGSizeMake(100, 100);
        case CellSize4Columns:    return CGSizeMake( 75,  75);
        case CellSize5Columns: return CGSizeMake( 60,  60);
        case CellSize6Columns:   return CGSizeMake( 50,  50);
        default:             return CGSizeZero;
    }
}

static NSString *kBebasNeueFontName = @"Bebas Neue";


@interface LSViewController ()

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) NSFetchedResultsController *ragefacesFRC;

@property (nonatomic, assign) BOOL searchIsActive;
@property (nonatomic, strong) LSSearchBar *searchBar;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) NSMutableArray *filteredData;
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGR;
@property (nonatomic, assign) dispatch_queue_t queue;
@property (nonatomic, assign) CellSize currentCellSize;

- (void)filterContentForSearchText:(NSString*)searchText;
- (CAAnimation*)lidAnimationForKeyPath:(NSString*)keyPath;

@end

@implementation LSViewController

#pragma mark - View lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        self.searchIsActive = NO;
        self.filteredData = [NSMutableArray new];
        NSInteger cellSizeInteger = [[NSUserDefaults standardUserDefaults] integerForKey:CellSizeKey];
        if (cellSizeInteger == 0) {
            self.currentCellSize = CellSize6Columns;
        } else {
            self.currentCellSize = (CellSize)cellSizeInteger;
        }
        
    }
    return self;
}

- (void)loadView
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    self.view = [[UIView alloc] initWithFrame:window.frame];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.autoresizesSubviews = YES;
    self.view.contentMode = UIViewContentModeRedraw;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //        self.view.layer.cornerRadius = 5;
        //        self.view.layer.masksToBounds = YES;
    } else {
        ;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    {
        self.ragefacesFRC = [Rageface fetchAllSortedBy:@"timesCopied" ascending:NO withPredicate:nil groupBy:nil];
        self.ragefacesFRC.delegate = self;
        [self.ragefacesFRC performFetch:nil];
    } // Set up NSFetchedResultsController
    
    self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    {
        self.layout = [[UICollectionViewFlowLayout alloc] init];
        self.layout.minimumInteritemSpacing = 0.0;
        self.layout.minimumLineSpacing = 0.0;
        self.layout.sectionInset = UIEdgeInsetsMake(0.0, 10.0, 10.0, 10.0);
        self.gridView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
        self.gridView.delegate = self;
        self.gridView.dataSource = self;
        
        self.gridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.gridView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.jpg"]];
        self.gridView.alwaysBounceVertical = YES;
        [self.view addSubview:self.gridView];
        
        [self.gridView registerClass:[RagefaceCell class] forCellWithReuseIdentifier:[RagefaceCell cellIdentifier]];
        
        
        //        self.gridView.cellSize = CGSizeFromCellSize(self.currentCellSize);
        
        
        //        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //            self.gridView.layer.cornerRadius = 5;
        //            self.gridView.layer.masksToBounds = YES;
        //        } else {
        //            ;
        //        }
        
    } // Grid View Setup
    
    {
        //        self.settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-44, -44.0, 44, 44)];
        //        settingsButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        //        [settingsButton setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
        //        [settingsButton setImage:[UIImage imageNamed:@"settings_pressed"] forState:UIControlStateHighlighted];
        //        settingsButton.contentMode = UIViewContentModeCenter;
        //        settingsButton.showsTouchWhenHighlighted = YES;
        //        [self.gridView addSubview:settingsButton];
    } // Settings Button
    
    {
        CGRect frame;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            frame = CGRectMake(0, -44.0-5, self.view.frame.size.width-self.settingsButton.frame.size.width, 44.0);
        } else {
            frame = CGRectMake(self.view.frame.size.width*(1-0.618)/2, -44.0-5, self.view.frame.size.width*0.618, 44.0);
        }
        
        self.searchBar = [[LSSearchBar alloc] initWithFrame:frame];
        self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        
        self.searchBar.backgroundImage = [UIImage new];
        [self.searchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchFieldBackground"] forState:UIControlStateNormal];
        [self.searchBar setImage:[UIImage imageNamed:@"magnification"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
        [self.searchBar setImage:[UIImage imageNamed:@"x"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
        [self.searchBar setImage:[UIImage imageNamed:@"x_pressed"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
        [self.searchBar setPositionAdjustment:UIOffsetMake(0, 1) forSearchBarIcon:UISearchBarIconSearch];
        self.searchBar.searchTextPositionAdjustment = UIOffsetMake(0.0, 1.0);
        
        UITextField *textField = [self.searchBar textField];
        UIFont *bebasFont = [UIFont fontWithName:kBebasNeueFontName size:[UIFont systemFontSize]+2.0];
        textField.font = bebasFont;
        
        
        self.searchBar.spellCheckingType = UITextSpellCheckingTypeNo;
        self.searchBar.placeholder = @"e.g. Me Gusta, Happy, Troll …";
        self.searchBar.delegate = self;
        
        self.gridView.contentInset = UIEdgeInsetsMake(searchBar.frame.size.height+5, 0, 0, 0);
        [self.gridView addSubview:searchBar];
        self.gridView.autoresizesSubviews = YES;
    } // Add Search Bar
    
    {
        self.logoHeaderView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
        self.logoHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.logoHeaderView.contentMode = UIViewContentModeCenter;
        self.logoHeaderView.frame = CGRectMake(0,
                                               -(self.logoHeaderView.frame.size.height + self.searchBar.frame.size.height),
                                               self.view.frame.size.width,
                                               self.logoHeaderView.frame.size.height);
        [self.gridView addSubview:self.logoHeaderView];
    } // Add Logo Header that is only visible when scrolling
    
    {
        self.pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
        [self.view addGestureRecognizer:self.pinchGR];
    } // Add Gesture Recognizer for resizing
}

- (void)viewDidUnload
{
    [self setGridView:nil];
    [self setLogoHeaderView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.gridView.contentOffset = CGPointMake(0, -(self.view.frame.size.height/2.0)-50-22);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.33 animations:^{
        self.gridView.contentOffset = CGPointMake(0, -10);
    }];
    
    [self.gridView becomeFirstResponder];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - UICollectionViewDatasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.searchIsActive) {
        return 1;
    } else {
        return 1;     //FIRST RELEASE
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //return 0; //For Screenshotting :)
    
    if (self.searchIsActive) {
        return self.filteredData.count;
    } else {
        if (section == 0) {
            return self.ragefacesFRC.fetchedObjects.count;
        } else if (section == 1) {
            //FIRST RELEASE
        }
    }
    
    NSAssert(NO, @"More than two sections; this wasn't planned O_o"); return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [RagefaceCell cellIdentifier];
    RagefaceCell* cell = (RagefaceCell*)[self.gridView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    Rageface *rageface;
    if (self.searchIsActive) {
        rageface = [self.filteredData objectAtIndex:indexPath.row];
    } else {
        rageface = self.ragefacesFRC.fetchedObjects[indexPath.row];
    }
    
    cell.rageface = rageface;
    
    return cell;
}


//- (UIView*)gridView:(NRGridView*)gridView viewForHeaderInSection:(NSInteger)section
//{
//    return nil; //FIRST RELEASE
//    
//    UIImage *sectionHeaderImage;
//    
//    if (searchIsActive) {
//        return nil;
//    } else {
//        if (section == 1) {
//            sectionHeaderImage = [[UIImage imageNamed:@"favoritesHeaderBackground"] stretchableImageWithLeftCapWidth:100 topCapHeight:0];
//        } else {
//            sectionHeaderImage = [[UIImage imageNamed:@"allRagefacesHeaderBackground"] stretchableImageWithLeftCapWidth:100 topCapHeight:0];
//        } 
//    }
//    
//    UIImageView *headerImageView = [[UIImageView alloc] initWithImage:sectionHeaderImage];
//    return headerImageView;
//}

//- (CGFloat)gridView:(NRGridView*)gridView heightForHeaderInSection:(NSInteger)section
//{
//    return 0; //FIRST RELEASE
//    
//    if (searchIsActive) {
//        return 0;
//    } else {
//        return 30;
//    }
//    
//}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    {
        NSAssert(collectionView == self.gridView, @"Mixed up Gridviews");
    } // Preconditions
    
//    [self.gridView deselectItemAtIndexPath:indexPath animated:YES];
    
    RagefaceCell* cell = (RagefaceCell*)[self.gridView cellForItemAtIndexPath:indexPath];
    
    Rageface *rageface;
    if (self.searchIsActive) {
        rageface = self.filteredData[indexPath.row];
    } else {
        rageface = self.ragefacesFRC.fetchedObjects[indexPath.row];
    }
    
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setData:UIImagePNGRepresentation(rageface.imageForSending)
          forPasteboardType:(NSString*)kUTTypePNG];
    } // Copy to clipboard
    
    rageface.timesCopied++;
    
    {
        UIImageView *animationView = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
        animationView.contentMode = UIViewContentModeScaleAspectFit;
        animationView.image = rageface.imageAtNativeResolution;
        animationView.center = [self.view convertPoint:cell.center fromView:self.gridView];
        [self.view addSubview:animationView];
        
        cell.alpha = 0.0;
        [UIView animateWithDuration:0.67
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             animationView.layer.transform = CATransform3DMakeScale(8, 8, 1);
                             animationView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [animationView removeFromSuperview];
                             
                             {
                                 cell.alpha = 1.0;
                                 CAKeyframeAnimation *animation = [CAKeyframeAnimation
                                                                   animationWithKeyPath:@"transform"];
                                 
                                 CATransform3D scale1 = CATransform3DMakeScale(0.01, 0.01, 1);
                                 CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
                                 CATransform3D scale3 = CATransform3DMakeScale(0.85, 0.85, 1);
                                 CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
                                 
                                 NSArray *frameValues = [NSArray arrayWithObjects:
                                                         [NSValue valueWithCATransform3D:scale1],
                                                         [NSValue valueWithCATransform3D:scale2],
                                                         [NSValue valueWithCATransform3D:scale3],
                                                         [NSValue valueWithCATransform3D:scale4],
                                                         nil];
                                 [animation setValues:frameValues];
                                 
                                 NSArray *frameTimes = [NSArray arrayWithObjects:
                                                        [NSNumber numberWithFloat:0.0],
                                                        [NSNumber numberWithFloat:0.5],
                                                        [NSNumber numberWithFloat:0.9],
                                                        [NSNumber numberWithFloat:1.0],
                                                        nil];
                                 [animation setKeyTimes:frameTimes];
                                 
                                 animation.fillMode = kCAFillModeRemoved;
                                 animation.removedOnCompletion = YES;
                                 animation.duration = 0.3;
                                 [cell.layer addAnimation:animation forKey:@"Recharging"];
                                 
                             } // "Recharge" Pop-In animation
                         }];
        
    } // Fire Copy Animation
    
    [LSSound play:@"copy.caf"];
}


- (void)animationDidStop:(CAAnimation *)theAnimation
                finished:(BOOL)flag
{
    [self.animationImageView removeFromSuperview];
    self.animationImageView = nil;
}

//- (void)gridView:(NRGridView*)gridView didLongPressCellAtIndexPath:(NSIndexPath*)indexPath
//{
//    [self.gridView becomeFirstResponder];
//    
//    UIMenuController* menuController = [UIMenuController sharedMenuController];
//    NRGridViewCell* cell = [self.gridView cellAtIndexPath:indexPath];
//    Rageface *rageface;
//    if (self.searchIsActive) {
//        rageface = [self.filteredData objectAtIndex:indexPath.row];
//    } else {
//        rageface = self.ragefacesFRC.fetchedObjects[indexPath.row];
//    }
//    
//    UIMenuItem *descriptionMenuItem = [[UIMenuItem alloc] initWithTitle:rageface.humanSearchableDescription action:@selector(handleTest:)];
//    menuController.arrowDirection = UIMenuControllerArrowUp;
//    [menuController setMenuItems:[NSArray arrayWithObject:descriptionMenuItem]];
//    [menuController setTargetRect:cell.frame 
//                           inView:self.gridView];
//    
//    [menuController setMenuVisible:YES animated:YES];
//}
//
//#pragma mark - UIMenuController Actions
//
//- (void)handleTest:(id)sender
//{
//    [self.gridView unhighlightPressuredCellAnimated:YES];
//}
//
//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
//{
//    return (action == @selector(handleTest:));
//}

#pragma mark - Pinch
- (void)pinch:(UIPinchGestureRecognizer*)sender
{
    switch (self.pinchGR.state) {
        case UIGestureRecognizerStateBegan:
            {
//                CGPoint point = [sender locationInView:self.gridView];
//                
//                NSIndexPath *indexPathOfTargetedCell;
//                NSArray *indexPaths = [self.gridView indexPathsForVisibleCells];
//                for (NSIndexPath *indexPath in indexPaths) {
//                    NRGridViewCell *cell = [self.gridView cellAtIndexPath:indexPath];
//                    CGRect cellBounds = cell.bounds;
//                    if (CGRectContainsPoint(cellBounds, point)) {
//                        indexPathOfTargetedCell = indexPath;
//                    }
//                }
//                NSAssert(indexPathOfTargetedCell, @"Did'nt hit any cell?");
//                
//                [self.gridView scrollRectToItemAtIndexPath:indexPathOfTargetedCell
//                                                  animated:YES
//                                            scrollPosition:NRGridViewScrollPositionAtMiddle];
            }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat scale = self.pinchGR.scale;
            CGSize size = CGSizeFromCellSize(self.currentCellSize);
            
            //Don't let cells become too tiny, as performance degrades...
            CGFloat scaledSizeWidth = size.width*scale;
            scaledSizeWidth = floor( MAX(scaledSizeWidth, (300.0 / 7) + 1.0) );
            scaledSizeWidth = floor( MIN(scaledSizeWidth, (300.0 / 1)) );
            
            self.layout.itemSize = CGSizeMake(scaledSizeWidth, scaledSizeWidth);
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGFloat width = self.layout.itemSize.width;
            if (width <= 300/6) {
                [self changeCellSizeTo:CellSize6Columns];
            } else if (width <= 300/5) {
                [self changeCellSizeTo:CellSize5Columns];
            } else if (width <= 300/4) {
                [self changeCellSizeTo:CellSize4Columns];
            } else if (width <= 300/3) {
                [self changeCellSizeTo:CellSize3Columns];
            } else if (width <= 300/2) {
                [self changeCellSizeTo:CellSize2Columns];
            } else {
                [self changeCellSizeTo:CellSize1Columns];
            }
        }
            break;
        default:
            break;
    }
  
}

- (void)changeCellSizeTo:(CellSize)cellSize
{
    if (cellSize < CellSize6Columns) cellSize = CellSize6Columns;
    if (cellSize > CellSize1Columns) cellSize = CellSize1Columns;
    
    CGFloat distance = ABS(self.layout.itemSize.width - CGSizeFromCellSize(cellSize).width) / self.layout.itemSize.width;
    
    [PRTweenCGSizeLerp lerp:self.layout
                   property:@"itemSize"
                       from:self.layout.itemSize
                         to:CGSizeFromCellSize(cellSize)
                   duration:0.5 * distance + 0.25
             timingFunction:&PRTweenTimingFunctionExpoOut
                updateBlock:nil
              completeBlock:^{
                  self.currentCellSize = cellSize;

                  [[NSUserDefaults standardUserDefaults] setInteger:cellSize forKey:CellSizeKey];
              }];
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
//    [self.gridView scrollRectToVisible:self.searchBar.frame animated:YES];
//    [self.gridView scrollToItemAtIndexPath:[[NSIndexPath alloc] initWithIndex:0]
//                          atScrollPosition:UICollectionViewScrollPositionTop
//                                  animated:YES];
    
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.searchBar setCloseButtonTitle:@"" forState:UIControlStateNormal];

    [self.filteredData removeAllObjects];
    [self.filteredData addObjectsFromArray:self.ragefacesFRC.fetchedObjects];
    self.searchIsActive = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    
    self.searchBar.text = nil;
    self.searchIsActive = NO;
    [gridView reloadData];
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""]) {
        [self.filteredData removeAllObjects];
        [self.filteredData addObjectsFromArray:self.ragefacesFRC.fetchedObjects];
        
    } else {
        [self filterContentForSearchText:searchText];
    }
    
    NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:0];
    [self.gridView reloadSections:set];
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText
{	
	[self.filteredData removeAllObjects]; // First clear the filtered array.

    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
	for (Rageface *rageface in self.ragefacesFRC.fetchedObjects)
	{
        NSString *compareText = [[rageface.humanSearchableDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] lowercaseString];
        
        NSRange range = [compareText rangeOfString:[searchText lowercaseString]];
        if (range.location != NSNotFound)
        {
            [self.filteredData addObject:rageface];
        }
	}
}

- (CAAnimation*)lidAnimationForKeyPath:(NSString*)keyPath
{
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animation.duration = 0.67;
    animation.delegate = self;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    
    // Create arrays for values and associated timings.
    float size = 1.0;
    float delta = 0.9;
    NSMutableArray *values = [NSMutableArray array];
    NSMutableArray *timings = [NSMutableArray array];
    while (delta > 0.05) {
        // Bounce back to partially closed position
        // Starts at closed position, then each bounce is smaller
        [values addObject:[NSNumber numberWithFloat:size-delta]];
        [timings addObject:kCAMediaTimingFunctionEaseIn];
        // Bounce back to fully open position (135°)
        [values addObject:[NSNumber numberWithFloat:size]];
        [timings addObject:kCAMediaTimingFunctionEaseOut];
        // Reduce the size of the bounce by the lid's tension
        delta *= 0.4;
    }
    animation.values = values;
    animation.timingFunctions = timings;
    return animation;
}

#pragma mark - Restkit Data Loading

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
//    NSLog(@"%@", objectLoader.response.bodyAsString);
//    NSLog(@"%@", objects.description);
    
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
}

-(void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"%@", error.description);
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
}

#pragma mark - NSFetchedResultsControllerDelegate

//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
//{
//
//}

//-(void)controller:(NSFetchedResultsController *)controller
// didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
//          atIndex:(NSUInteger)sectionIndex
//    forChangeType:(NSFetchedResultsChangeType)type
//{
//    NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:sectionIndex];
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
//            [self.gridView insertSections:set];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.gridView deleteSections:set];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self.gridView reloadSections:set];
//            break;
//    }
//}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.gridView reloadData];
//            [self.gridView insertItemsAtIndexPaths:@[ newIndexPath ]];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.gridView reloadData];
//            [self.gridView deleteItemsAtIndexPaths:@[ indexPath ]];
            break;
            
        case NSFetchedResultsChangeUpdate:
//            [self.gridView reloadItemsAtIndexPaths:@[ in dexPath ]];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.gridView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    
//}

#pragma mark - Properties
@synthesize layout;
@synthesize gridView;
@synthesize logoHeaderView;
@synthesize searchBar;
@synthesize settingsButton;
@synthesize filteredData;
@synthesize searchIsActive;
@synthesize animationImageView;
@synthesize queue;
@synthesize pinchGR;
@synthesize currentCellSize;

@end
