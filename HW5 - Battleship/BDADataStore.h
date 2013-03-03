//
//  BDADataStore.h
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/28/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDASectorView.h"

@interface BDADataStore : NSObject 
{
    NSMutableArray *allItems;
}

+ (BDADataStore *)defaultStore;

- (NSArray *)allItems;

- (NSString *)itemArchivePath;

- (BOOL)saveChanges:(NSString*)lastSector;
@end
