//
//  BDAShipController.h
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/16/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDASectorView.h"

@protocol ProcessShipDelegate <NSObject, NSCoding>
@required
- (void) showStartButton: (BOOL)display;
- (void) displaySector: (BDASectorView *)sector;
- (void) archiveData;
@end

@interface BDAShipController : UIView <UIGestureRecognizerDelegate>
{
    id <ProcessShipDelegate> delegate;
}

@property (retain) id delegate;

@property int boatType;
@property float boatStartX;
@property float boatStartY;
@property BOOL piecePlaced;
@property NSString *lastSector;
@property BOOL rotated;

// Public interface
-(id)initWithFrame:(CGRect)frame boatType:(int)type;
@end
