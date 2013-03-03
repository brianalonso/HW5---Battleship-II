//
//  BDAAppDelegate.h
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/16/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BDAGameModel.h"

@class BDAViewController;

@interface BDAAppDelegate : UIResponder <UIApplicationDelegate> {
    BDAGameModel* gameModel;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BDAViewController *viewController;
@property (strong, nonatomic) BDAGameModel* gameModel;
@end
