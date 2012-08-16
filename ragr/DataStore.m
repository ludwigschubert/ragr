//
//  DataStore.m
//  RWE Energierechner
//
//  Created by Ludwig Schubert on 22.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DataStore.h"
#import "parseCSV.h"

#import "Rageface.h"

#define dataFileName @"ragefaces"
#define csvFileName  @"ragefaces"

@implementation DataStore

@synthesize storedData, favorites;

- (void)parseCSV
{
    NSString *csvPath = [[NSBundle mainBundle] pathForResource:csvFileName ofType:@"csv"];
    CSVParser *parser = [CSVParser new];
    [parser setEncoding:NSUTF8StringEncoding];
    
    [parser openFile: csvPath];
    NSMutableArray *csvContent = [parser parseFile];
    
    self.storedData = [NSMutableArray arrayWithCapacity:csvContent.count];

    for (int c = 0; c < [csvContent count]; c++) { //No title line
        NSArray *deviceDescription = [csvContent objectAtIndex: c];
        
        Rageface *rageface = [Rageface new];
        rageface.filename = [deviceDescription objectAtIndex:0];
        rageface.humanReadableDescription = [deviceDescription objectAtIndex:1];

        [self.storedData addObject:rageface];
    }
    [parser closeFile];
    
//    NSArray *sortedByUsage = [self.storedData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        Rageface *r1 = (Rageface*)obj1;
//        Rageface *r2 = (Rageface*)obj2;
//        return [[NSNumber numberWithInteger:r1.timesCopied] compare:[NSNumber numberWithInteger:r2.timesCopied]];
//    }];
    //    self.favorites = [sortedByUsage subarrayWithRange:NSMakeRange(0, 10)];
    
    [self save];
}

- (void)load
{
    NSString *archivePath = [[NSBundle mainBundle] pathForResource:dataFileName ofType:@"keyedArchive"];
    
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:archivePath]){
            self.storedData = [NSKeyedUnarchiver unarchiveObjectWithFile:archivePath];
            
                NSArray *sortedByUsage = [self.storedData sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    Rageface *r1 = (Rageface*)obj1;
                    Rageface *r2 = (Rageface*)obj2;
                    return [[NSNumber numberWithInteger:r2.views] compare:[NSNumber numberWithInteger:r1.views]];
                }];
            self.storedData = [NSMutableArray arrayWithArray:sortedByUsage];	
            //NSLog(@"[INFO] Loaded Data %@ from path: %@", self.storedData, archivePath);
        } else {
            NSLog(@"[ERROR] Couldn't load Data from path: %@", archivePath);
            [self parseCSV];
        }
    } // Data

}

- (void)save
{
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *archivePath;
    
    {
        archivePath = [documentsDirectory stringByAppendingPathComponent:dataFileName];
        BOOL success = [NSKeyedArchiver archiveRootObject:self.storedData
                                                   toFile:archivePath];
        if (success) {
            NSLog(@"[INFO] Saved HouseholdItems %@ to path: %@", self.storedData, archivePath);
        } else {
            NSLog(@"[ERROR] Couldn't save HouseholdItems to path: %@", archivePath);
        }
        
    } // HouseholdItems
    
}

- (void)didEnterBackground:(id)sender
{
    [self save];
}

#pragma mark - Singleton Stuff

static DataStore *sharedInstance = nil;

// Get the shared instance and create it if necessary.
+ (DataStore *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

// We can still have a regular init method, that will get called the first time the Singleton is used.
- (id)init
{
    self = [super init];
    
    if (self) {
        self.favorites = [NSMutableArray new];
        //[self parseCSV]; //DEBUG
                         [self load];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    
    return self;
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
