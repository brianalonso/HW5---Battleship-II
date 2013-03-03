//
//  BDASectorView.m
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/16/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import "BDASectorView.h"
#import "BDAGlobals.h"

@interface BDASectorView()

@property (copy, nonatomic) UIColor *lineColor;
@property (copy, nonatomic) UIColor *backgroundColor;

@end

@implementation BDASectorView {
    // Private ivars
    int rowNumber;
    int colNumber;
    NSString *rowLetter;
}
// Synthesize the readonly properties
@synthesize rowLetter, colNumber, rowNumber;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame row:(int) rowNum  col:(int) colNum;
{
    // Create a gameboard of individual views
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        rowNumber = rowNum;
        colNumber = colNum;
        rowLetter = self.rowLetters[rowNum];
        self.lineColor = [UIColor blackColor];
        self.backgroundColor = [UIColor lightGrayColor];
    }
    return self;
}

- (NSArray *)rowLetters
{
    // Called to return the row letter given the current row number
    NSString *letters = @"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z";
    return [letters componentsSeparatedByString:@" "];
}


#pragma mark - Draw the sector

- (void)drawRect:(CGRect)rect
{
    // Draw the grid sector box to the passed height and width
	
	//	Get the drawing context
	CGContextRef context =  UIGraphicsGetCurrentContext ();
	
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [self lineColor].CGColor);
    CGContextSetFillColorWithColor(context, [self backgroundColor].CGColor);
    
    // Define a rect in the shape of the square
    CGRect blockRect = CGRectMake(0, 0,  self.bounds.size.width, self.bounds.size.height);
    CGContextAddRect(context, blockRect);
    CGContextDrawPath(context, kCGPathFillStroke);
}
@end
