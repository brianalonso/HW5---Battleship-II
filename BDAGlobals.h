//
//  BDAGlobals.h
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/20/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BDAGameModel.h"

#define BLOCK_HEIGHT 50.0
#define BLOCK_WIDTH  50.0

#define XPAD  8.0
#define YPAD  5.0

#define NumberOfShips 3
#define BoatHeight 48
#define CarrierWidth 198
#define CommandShipWidth 148
#define SubWidth 98

static NSString * const kBoatArrayKey = @"kBoatArrayKey";
static NSString * const kBoatTypeKey = @"kBoatTypeKey";
static NSString * const kBoatStartX = @"kBoatStartX";
static NSString * const kBoatStartY = @"kBoatStartY";
static NSString * const kPiecePlaced = @"kPiecePlaced";
static NSString * const kCurrentX = @"kCurrentX";
static NSString * const kCurrentY = @"kCurrentY";
static NSString * const kLastSector = @"kLastSector";
static NSString * const kRotated = @"kRotated";

@interface BDAGlobals : NSObject

enum typeBoat
{
    typeAircraft = 1,
    typeSub = 2,
    typeCommandShip = 3
};

@end
