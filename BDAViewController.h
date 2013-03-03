//
//  BDAViewController.h
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/16/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDAShipController.h"

@interface BDAViewController : UIViewController <UIGestureRecognizerDelegate, ProcessShipDelegate>
{
    BDAShipController *boatViewDelegate;
}

@end
