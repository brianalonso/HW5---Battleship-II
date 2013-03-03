//
//  BDAGameModel.m
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/16/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import "BDAGameModel.h"
#import "BDASectorView.h"
#import "BDAGlobals.h"

@implementation BDAGameModel 
@synthesize sectors, rectAircraftCarrier, rectCommandShip, rectSubmarine, boats;


#pragma mark Properties
- (CGRect) rectCommandShip_Start
{
    return rectCommandShip_Start;
}

- (void) setRectCommandShip_Start:(CGRect) aRect
{
    rectCommandShip_Start = aRect;
    
    // Also save a copy to the rectCommandShip
    self.rectCommandShip = aRect;
}

- (CGRect) rectSubmarine_Start
{
    return rectSubmarine_Start;
}

- (void) setRectSubmarine_Start:(CGRect) aRect
{
    rectSubmarine_Start = aRect;
    
    // Also save a copy to the rectSubmarine
    self.rectSubmarine = aRect;
}

- (CGRect) rectAircraftCarrier_Start
{
    return rectSubmarine_Start;
}

- (void) setRectAircraftCarrier_Start:(CGRect) aRect
{
    rectAircraftCarrier_Start = aRect;
    
    // Also save a copy to the rectAircraftCarrier
    self.rectAircraftCarrier = aRect;
}

- (id)init {
    self = [super init];
    
    if (self) {
        // Init the grid array to hold the 36 sectors
        sectors = [[NSMutableArray alloc] initWithCapacity:36];
        
        BDASectorView* gameSector;
        
        // Start the game board in the top-middle of the device screen
        for (int row = 0; row<=5; row++)
        {
            for (int col = 0; col<=5; col++)
            {
                gameSector = [[BDASectorView alloc ]
                              // Offset the left and top sides of the game board
                      initWithFrame: CGRectMake(XPAD + col * BLOCK_WIDTH ,
                                                YPAD + row * BLOCK_HEIGHT,
                                                BLOCK_WIDTH, BLOCK_HEIGHT)
                                row:row
                                col:col+1];
                
                // Add the sector to the game model
                [sectors addObject:gameSector];
            }
        }
        // Init the boats dictionary to hold the ship pieces
        boats = [NSMutableDictionary dictionaryWithCapacity:NumberOfShips];
    }
    
    return self;
}

@end
