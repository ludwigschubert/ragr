//
//  DataManager.m
//  ragr
//
//  Created by Ludwig Schubert on 20.08.12.
//
//

#import "DataManager.h"

#import <SDWebImage/SDWebImagePrefetcher.h>

@interface DataManager ()

@property (nonatomic, strong) RKManagedObjectStore *managedObjectStore;

@end

@implementation DataManager

#pragma mark - Lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        {
            RKObjectManager *manager = [RKObjectManager managerWithBaseURLString:@"http://ragefac.es/api/"];
            self.managedObjectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"ragefacesStore.sqlite"
                                                                   usingSeedDatabaseName:nil
                                                                      managedObjectModel:nil
                                                                                delegate:self];
            manager.objectStore = self.managedObjectStore;
            
            [Rageface registerMapping];
        } // Set Up Restkit Communication
        
        //Register for UIApplicationDidEnterBackgroundNotifications so we can save the context
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleEnteredBackground:)
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];
        
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self updateRagefaces];
        });
    }
    return self;
}

- (void)dealloc
{
    self.managedObjectStore = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods

- (void)updateRagefaces
{
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:[Rageface resourcePath]
                                                      delegate:self];
    
    UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
}

#pragma mark - Notification & Event Handlers

- (void)handleEnteredBackground:(id)sender
{
    RKObjectManager *manager = [RKObjectManager sharedManager];
    
    NSError *error;
    BOOL saveWasSuccessful = [manager.objectStore save:&error];
    if (!saveWasSuccessful) {
        NSLog(@"%@", error.description);
    }
}

#pragma mark - Delegates

#pragma mark RKObjectLoaderDelegate

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    //TODO
    NSLog(@"%@", error.description);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    if (objects.count > 0) { // Saves a few cycles
        NSArray *urlsToPrefetch = [objects valueForKey:@"url"]; //This works like array.map{ |face| face -> face.url }
        [SDWebImagePrefetcher.sharedImagePrefetcher prefetchURLs:urlsToPrefetch];
    }
}

/**
 Invoked when the object loader has finished loading
 */
- (void)objectLoaderDidFinishLoading:(RKObjectLoader *)objectLoader
{
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
}

- (void)objectLoaderDidLoadUnexpectedResponse:(RKObjectLoader *)objectLoader
{
    //TODO
}

#pragma mark SDWebImageManagerDelegate

- (void)webImageManager:(SDWebImageManager *)imageManager didFailWithError:(NSError *)error forURL:(NSURL *)url
{
    NSLog(@"%@", error.description);
}

#pragma mark - Property Synthesizes

@synthesize managedObjectStore;

@end
