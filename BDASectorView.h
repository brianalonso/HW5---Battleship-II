//
//  BDASectorView.h
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/16/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BDASectorView : UIView 

- (id)initWithFrame:(CGRect)frame row:(int) rowNum  col: (int) colNum;

@property (readonly) int colNumber;
@property (readonly) NSString *rowLetter;
@property (readonly) int rowNumber;

@end
