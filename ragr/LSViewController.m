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
#import "DataStore.h"
#import "Rageface.h"
#import "RagefaceCell.h"
#import "LSSearchBar.h"
#import "LSSound.h"
#import "PRTween.h"

typedef enum {
    CellSize6Columns = 1,
    CellSize5Columns = 2,
    CellSize4Columns = 3,
    CellSize3Columns = 4
} CellSize;

CGSize CGSizeFromCellSize(CellSize cellSize);
CGSize CGSizeFromCellSize(CellSize cellSize)
{
    switch (cellSize) {
        case CellSize3Columns:   return CGSizeMake(100, 100);
        case CellSize4Columns:    return CGSizeMake( 75,  75);
        case CellSize5Columns: return CGSizeMake( 60,  60);
        case CellSize6Columns:   return CGSizeMake( 50,  50);
        default:             return CGSizeZero;
    }
}

static NSString *kBebasNeueFontName = @"Bebas Neue";


@interface LSViewController ()

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

#pragma mark - Properties

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

#pragma mark - Grid View Datasource

- (NSInteger)numberOfSectionsInGridView:(NRGridView *)gridView
{
    if (self.searchIsActive) {
        return 1;
    } else {
        return 1;     //FIRST RELEASE
    }
}

- (NSInteger)gridView:(NRGridView*)gridView numberOfItemsInSection:(NSInteger)section
{
    //return 0; //For Screenshotting :)
    
    if (self.searchIsActive) {
        return self.filteredData.count;
    } else {
        if (section == 0) {
            return [[DataStore sharedInstance] storedData].count;
        } else if (section == 1) {
            
        }
    }
    
    NSAssert(NO, @"More than two sections; this wasn't planned O_o"); return 0;
}

- (NRGridViewCell*)gridView:(NRGridView*)gridView cellForItemAtIndexPath:(NSIndexPath*)indexPath
{
    RagefaceCell* cell;
    {
        NSString *identifier = [RagefaceCell cellIdentifier];
        cell = (RagefaceCell*)[self.gridView dequeueReusableCellWithIdentifier:identifier];
        
        if(cell == nil){
            cell = [[RagefaceCell alloc] initWithReuseIdentifier:identifier];
        }
    } // Get Cell
    
    Rageface *rageface;
    if (self.searchIsActive) {
        rageface = [self.filteredData objectAtIndex:indexPath.row];
    } else {
        rageface = [[[DataStore sharedInstance] storedData] objectAtIndex:indexPath.row];
    }
    
    cell.rageface = rageface;
    
    return cell;
}

- (UIView*)gridView:(NRGridView*)gridView viewForHeaderInSection:(NSInteger)section
{
    return nil; //FIRST RELEASE
    
    UIImage *sectionHeaderImage;
    
    if (searchIsActive) {
        return nil;
    } else {
        if (section == 1) {
            sectionHeaderImage = [[UIImage imageNamed:@"favoritesHeaderBackground"] stretchableImageWithLeftCapWidth:100 topCapHeight:0];
        } else {
            sectionHeaderImage = [[UIImage imageNamed:@"allRagefacesHeaderBackground"] stretchableImageWithLeftCapWidth:100 topCapHeight:0];
        } 
    }
    
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage:sectionHeaderImage];
    return headerImageView;
}

- (CGFloat)gridView:(NRGridView*)gridView heightForHeaderInSection:(NSInteger)section
{
    return 0; //FIRST RELEASE
    
    if (searchIsActive) {
        return 0;
    } else {
        return 30;
    }
    
}


#pragma mark - Grid View Delegate

- (void)gridView:(NRGridView*)aGridView didSelectCellAtIndexPath:(NSIndexPath*)indexPath
{
    {
        NSAssert(aGridView == self.gridView, @"Mixed up Gridviews");
    } // Preconditions
    
    [self.gridView deselectCellAtIndexPath:indexPath animated:NO];
    
    NRGridViewCell* cell = [self.gridView cellAtIndexPath:indexPath];
    
    Rageface *rageface;
    if (self.searchIsActive) {
        rageface = [self.filteredData objectAtIndex:indexPath.row];
    } else {
        rageface = [[[DataStore sharedInstance] storedData] objectAtIndex:indexPath.row];
    }
    
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setData:UIImagePNGRepresentation(rageface.fullResolutionImage)
          forPasteboardType:(NSString*)kUTTypePNG];
    } // Copy to clipboard
    
    rageface.timesCopied++;
    
    {
        UIImageView *animationView = [[UIImageView alloc] initWithFrame:cell.imageView.frame];
        animationView.contentMode = UIViewContentModeScaleAspectFit;
        animationView.image = rageface.fullResolutionImage;
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

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    [self.animationImageView removeFromSuperview];
    self.animationImageView = nil;
}

- (void)gridView:(NRGridView*)gridView didLongPressCellAtIndexPath:(NSIndexPath*)indexPath
{
    [self.gridView becomeFirstResponder];
    
    UIMenuController* menuController = [UIMenuController sharedMenuController];
    NRGridViewCell* cell = [self.gridView cellAtIndexPath:indexPath];
    Rageface *rageface;
    if (self.searchIsActive) {
        rageface = [self.filteredData objectAtIndex:indexPath.row];
    } else {
        rageface = [[[DataStore sharedInstance] storedData] objectAtIndex:indexPath.row];
    }
    
    UIMenuItem *descriptionMenuItem = [[UIMenuItem alloc] initWithTitle:rageface.humanSearchableDescription action:@selector(handleTest:)];
    menuController.arrowDirection = UIMenuControllerArrowUp;
    [menuController setMenuItems:[NSArray arrayWithObject:descriptionMenuItem]];
    [menuController setTargetRect:cell.frame 
                           inView:self.gridView];
    
    [menuController setMenuVisible:YES animated:YES];
}

#pragma mark - UIMenuController Actions

- (void)handleTest:(id)sender
{
    [self.gridView unhighlightPressuredCellAnimated:YES];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(handleTest:));
}

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
    
    self.queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    
    {
        self.gridView = [[NRGridView alloc] initWithLayoutStyle:NRGridViewLayoutStyleVertical];
        self.gridView.delegate = self;
        self.gridView.dataSource = self;
        self.gridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.gridView.frame = self.view.frame;
        [self.view addSubview:self.gridView];
        
        self.gridView.cellSize = CGSizeFromCellSize(self.currentCellSize);
        self.gridView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"texture.jpg"]];
        self.gridView.alwaysBounceVertical = YES;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.gridView.layer.cornerRadius = 5;
            self.gridView.layer.masksToBounds = YES;
        } else {
            ;
        }

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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (Rageface *rageface in [[DataStore sharedInstance] storedData]) {
            UIImage *thumb = rageface.thumbnail;
            thumb = nil;
        }
    });
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
            scaledSizeWidth = floor( MAX(scaledSizeWidth, (320.0 / 7) + 1) );
            scaledSizeWidth = floor( MIN(scaledSizeWidth, (320.0 / 3) - 1) );
            
            self.gridView.cellSize = CGSizeMake(scaledSizeWidth, scaledSizeWidth);
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGFloat width = self.gridView.cellSize.width;
            if (width <= self.gridView.bounds.size.width/6) {
                [self changeCellSizeTo:CellSize6Columns];
            } else if (width <= self.gridView.bounds.size.width/5) {
                [self changeCellSizeTo:CellSize5Columns];
            } else if (width <= self.gridView.bounds.size.width/4) {
                [self changeCellSizeTo:CellSize4Columns];
            } else {
                [self changeCellSizeTo:CellSize3Columns];
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
    if (cellSize > CellSize3Columns) cellSize = CellSize3Columns;
    
    CGFloat distance = ABS(self.gridView.cellSize.width - CGSizeFromCellSize(cellSize).width) / self.gridView.cellSize.width;
    
    [PRTweenCGSizeLerp lerp:self.gridView
                   property:@"cellSize"
                       from:self.gridView.cellSize
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
    [self.gridView scrollRectToVisible:self.searchBar.frame animated:YES];
    
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self.searchBar setCloseButtonTitle:@"" forState:UIControlStateNormal];

    [self.filteredData removeAllObjects];
    [self.filteredData addObjectsFromArray:[[DataStore sharedInstance] storedData]];
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
        [self.filteredData addObjectsFromArray:[[DataStore sharedInstance] storedData]];
    } else {
        [self filterContentForSearchText:searchText];
    }
    
    [gridView reloadData];
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
    
	for (Rageface *rageface in [[DataStore sharedInstance] storedData])
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

@end
