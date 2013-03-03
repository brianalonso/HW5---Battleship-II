//
//  BDAGameModel.h
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/16/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDAGameModel : NSObject {
    NSMutableArray* sectors;
    NSMutableDictionary* boats;
    CGRect rectAircraftCarrier;
    CGRect rectCommandShip;
    CGRect rectSubmarine;
    CGRect rectAircraftCarrier_Start;
    CGRect rectCommandShip_Start;
    CGRect rectSubmarine_Start;
}

// Public properties
@property (readonly) NSMutableArray* sectors;
@property (nonatomic, strong) NSMutableDictionary* boats;

- (CGRect) rectAircraftCarrier_Start;
- (void) setRectAircraftCarrier_Start:(CGRect) aRect;
- (CGRect) rectCommandShip_Start;
- (void) setRectCommandShip_Start:(CGRect) aRect;
- (CGRect) rectSubmarine_Start;
- (void) setRectSubmarine_Start:(CGRect) aRect;

@property (assign, nonatomic) CGRect rectAircraftCarrier;
@property (assign, nonatomic) CGRect rectCommandShip;
@property (assign, nonatomic) CGRect rectSubmarine;
@end
