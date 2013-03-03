//
//  BDADataStore.m
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/28/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import "BDADataStore.h"
#import "BDAGlobals.h"
#import "BDAShipController.h"
#import "BDAAppDelegate.h"

@implementation BDADataStore{
    // Define reference to a global game piece array
    BDAAppDelegate *appDelegate;
}


+ (BDADataStore *)defaultStore
{
    static BDADataStore *defaultStore = nil;
    if(!defaultStore)
        defaultStore = [[super allocWithZone:nil] init];
    
    return defaultStore;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultStore];
}

- (id)init
{
    self = [super init];
    if(self) {
        // Reference the game model array defined globally in the AppDelegate
        appDelegate = (BDAAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString *path = [self itemArchivePath];
        allItems = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // If the array hadn't been saved previously, create a new empty one
        if(!allItems)
            allItems = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)itemArchivePath
{
    NSArray *documentDirectories =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get the only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"battleship.archive"];
}

- (BOOL)saveChanges:(NSString*)lastSector
{
    // returns success or failure
    NSString *filePath = [self itemArchivePath];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
                                 initForWritingWithMutableData:data];
    // Fill the archiver object
    [allItems removeAllObjects];
    for (NSString *key in appDelegate.gameModel.boats)
    {
        BDAShipController *boat = [appDelegate.gameModel.boats objectForKey:key];
        boat.lastSector = lastSector;
        
        [allItems addObject:boat];
    }
    [archiver encodeObject:allItems forKey:kBoatArrayKey];
    [archiver finishEncoding];
    [data writeToFile:filePath atomically:YES];

    return YES;
}

- (NSArray *)allItems
{
    return allItems;
}

@end
