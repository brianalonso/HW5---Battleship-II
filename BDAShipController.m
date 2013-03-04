//
//  BDAShipController.m
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/16/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import "BDAShipController.h"
#import "BDASectorView.h"
#import "BDAAppDelegate.h"
#import "BDAGlobals.h"
#import "BDAViewController.h"
#import <AVFoundation/AVAudioPlayer.h>

#define DEFAULT_RADIUS 3.0

@interface BDAShipController()

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UIRotationGestureRecognizer *rotationGesture;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

// Methods
- (void)_snapShip:(CGPoint)newPoint view:(CGRect)frame;
@end

@implementation BDAShipController {
    // Private ivars
    float boatStartX, boatStartY;
    CGPoint currentPoint, previousPoint;
    BDAAppDelegate *appDelegate;
    CGFloat rotation;
    CGFloat degrees;
    UIAlertView *alert;
    AVAudioPlayer *clickPlayer;
}
@synthesize boatStartX, boatStartY, boatType, delegate, lastSector, rotated;

- (id)initWithFrame:(CGRect)frame boatType:(int)type
{
	if (self = [super initWithFrame:frame])
    {
        // Reference the game model array defined globally in the AppDelegate
        appDelegate = (BDAAppDelegate *)[[UIApplication sharedApplication] delegate];
        
        self.backgroundColor = [UIColor blueColor];
		self.userInteractionEnabled = YES;
        
        // Save type of boat for later
        self.boatType = type;
        
        // Set the rotation flag
        self.rotated = NO;
        
        // Initialize the intial placement flag
        self.piecePlaced = NO;
        
        // Add the rotation recognizer for the ship's View
        self.rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(doRotate:)];
        self.rotationGesture.delegate = self;
        [self addGestureRecognizer:self.rotationGesture];
        
        // Add the Pan gesture recognizer for the ship
        self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(moveBoat:)];
        [self.panRecognizer setMinimumNumberOfTouches:1];
        [self.panRecognizer setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:self.panRecognizer];
        
        self.tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                                   action:@selector(handleBoatTap:)];
        [self.tapGesture setNumberOfTapsRequired:1];
        [self addGestureRecognizer:self.tapGesture];

        // setup the sound
        [self _setupSound];
        
        // Draw the rounded rectangle for the ship
        [self setNeedsDisplayInRect:frame];
    }
	return self;
}

- (void)drawRect:(CGRect)rect {
    // Draw a white border within the boat
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Draw the rounded rectangle style
    CGContextSetStrokeColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
    
    // Set 5pts rounded rectangle inside border of boat
    CGRect rrect = CGRectMake(CGRectGetMinX(rect)+5, CGRectGetMinY(rect)+5, CGRectGetWidth(rect)-10, CGRectGetHeight(rect)-10);
    CGFloat radius = DEFAULT_RADIUS;
  
    CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
    
    // Start at 1
    CGContextMoveToPoint(context, minx, midy);
    // Add an arc through 2 to 3
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    // Add an arc through 4 to 5
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    // Add an arc through 6 to 7
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    // Add an arc through 8 to 9
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    // Close the path
    CGContextClosePath(context);
    // Fill & stroke the path
    CGContextDrawPath(context, kCGPathFillStroke);
}

#pragma mark - Sound setup
- (void) _setupSound
{
    // Play a sound
    NSURL *clickSoundURL = [NSURL fileURLWithPath: [[NSBundle mainBundle]
                                                    pathForResource: @"click"
                                                    ofType: @"aiff"]];
    clickPlayer = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:clickSoundURL
                   error:nil];
    
    // Prepare to play sounds
    [clickPlayer prepareToPlay];
}

- (void) _playClick {
    [clickPlayer play];
    
}

#pragma mark - Gesture recognizers

- (void)doRotate:(UIRotationGestureRecognizer *)gesture
{
    // Rotation started or in progress
    if ([gesture state] == UIGestureRecognizerStateBegan || [gesture state] == UIGestureRecognizerStateChanged)
    {
        rotation += gesture.rotation;
        [gesture view].transform = CGAffineTransformMakeRotation(rotation);
        [gesture setRotation:0];
    }
    
    // rotation ended, handle snap to function
    if (gesture.state == UIGestureRecognizerStateEnded) {
        degrees = fmodf(rotation * 180 / M_PI, 360);
        NSLog(@"Rotation in Degrees: %f", degrees);
        
        CGFloat computed = abs(fmodf(degrees, 180.0f));
        if (computed < 45) {
            self.rotated = NO;
            computed = 0;
        }
        else
            if (computed < 180) {
                self.rotated = YES;
                computed = 90;
            }
        
        degrees = -(computed + degrees);
    
        NSLog(@"Snap to Degrees: %f", degrees);
        rotation = 0;
        
        // Convert the degrees to radians and animate the movement
        CGFloat radians = degrees * M_PI / 180;
        
        [UIView animateWithDuration:1.0f animations:^{
            CGAffineTransform transform = CGAffineTransformRotate([gesture view].transform, radians);
            [gesture view].transform = transform;
        }];
        
        // The point of the ship did not move, just rotated
        CGPoint newPoint = CGPointMake(self.center.x,self.center.y);
        
        // Shap the boat to the sector
        [self _snapShip:newPoint view:[gesture view].frame];
        
    }
}

- (void)moveBoat:(UIPanGestureRecognizer *)panRecognizer
{
    if (self.panRecognizer.state == UIGestureRecognizerStateBegan) {
        // Save the initial position in case we have to move the boat back
        previousPoint = CGPointMake(self.center.x, self.center.y);
        self.piecePlaced = NO;
    }
    
    CGPoint translation = [panRecognizer translationInView:self.superview];
    
    // Determine new point based on where the touch is now located
    CGPoint newPoint = CGPointMake(self.center.x + (translation.x - currentPoint.x),
                                   self.center.y + (translation.y - currentPoint.y));
    
    // Stay within the bounds of the sector board of the game
    float midPointX = 0.0;
    float midPointY = 0.0;
    if (self.rotated) {
        // Ship piece is rotated; swap X and Y
        midPointY = CGRectGetMidX(self.bounds);
        midPointX = CGRectGetMidY(self.bounds);
    }
    else
    {
        // Ship piece is horizontal
        midPointX = CGRectGetMidX(self.bounds);
        midPointY = CGRectGetMidY(self.bounds);
    }
    
    // Check if trying to drag off of the right screen boundary
    if (newPoint.x > self.superview.bounds.size.width  - midPointX - XPAD)
        newPoint.x = self.superview.bounds.size.width - midPointX - XPAD;
    else if (newPoint.x < midPointX)
        // Dont allow drag past left edge of screen
        newPoint.x = midPointX;
    
    // Check if trying to drag off the bottom of the screen (superview)
    if (newPoint.y > self.superview.bounds.size.height  - midPointY - YPAD)
        newPoint.y = self.superview.bounds.size.height - midPointY - YPAD;
    else if (newPoint.y < midPointY)
        // Top of screen
        newPoint.y = midPointY;
    
    // Set new center location for the ship piece
    self.center = newPoint;

    // Snap the ship to the closest sector
    if (self.panRecognizer.state == UIGestureRecognizerStateEnded) {
        [self _snapShip:newPoint view:panRecognizer.view.frame];
    }
    
    // Reset the translation to the beginning
    [panRecognizer setTranslation:CGPointZero inView:self];
    
    // Check if all ship pieces are positioned correctly
    BOOL bHide = NO;
    for (NSString *key in appDelegate.gameModel.boats)
    {
        BDAShipController *boat = [appDelegate.gameModel.boats objectForKey:key];
        
        if (boat.piecePlaced == NO)
        {
            // Found a ship piece that is not placed
            bHide = YES;
            break;
        }
    }
    
    // Show or hide the Start Game command button
    [[self delegate] showStartButton:bHide];
}

- (void)_snapShip:(CGPoint)newPoint view:(CGRect)frame
{
    // Search for an intersection of the boat imageview with the sectors
    for (BDASectorView* sector in appDelegate.gameModel.sectors) {
        CGRect intersection = CGRectIntersection(sector.frame, frame);
        
        if(CGRectIsNull(intersection)) {
            // Didn't find a grid sector.  The piece was moved off the playing grid
        }
        else
        {
            // Locate the sector where the pan ended by converting the ship piece's target point to the sector's scale
            CGPoint lastPoint = [self.superview convertPoint:newPoint toView:sector.superview];
            lastPoint.x -= XPAD;
            lastPoint.y -= YPAD;
            if (CGRectContainsPoint(sector.frame, lastPoint))
            {
                int offset = 0;
                int yValue = 0;
                int xValue = 0;
                
                if (self.rotated)
                {
                    // Ship piece is vertcal
                    switch (self.boatType) {
                        case typeSub:
                            offset = BLOCK_HEIGHT/2;
                            break;
                        case typeCommandShip:
                            offset = (3 * BLOCK_HEIGHT) / 2;
                            break;
                        case typeAircraft:
                            offset = (4 * BLOCK_HEIGHT) / 2;
                            break;
                        default:
                            break;
                    }
               
                    yValue = YPAD + (BLOCK_HEIGHT * (sector.rowNumber-1)) + offset;
                    
                    // Make sure the ship is within the vertical bounds of the board
                    if (yValue + offset > (YPAD + (BLOCK_HEIGHT * 5)))
                        yValue -= BLOCK_HEIGHT;
                    xValue = XPAD + (sector.colNumber * BLOCK_WIDTH) - (BLOCK_WIDTH/2);
                }
                else
                {
                    // Ship piece is horizontal
                    if (self.boatType == typeCommandShip)
                        offset = BLOCK_WIDTH/2;
                    
                    xValue = XPAD + (BLOCK_WIDTH * (sector.colNumber-1)) + offset;
                    if (xValue - XPAD <= 0)
                        xValue += BLOCK_WIDTH;
                    yValue = YPAD + (sector.rowNumber * BLOCK_HEIGHT) + (BLOCK_HEIGHT/2);
                }
                
                NSLog(@"Calculated ship location x: %i  y: %i", xValue, yValue);
                
                // Nudge the boat to align edge with nearest sector
                [UIView animateWithDuration:0.25f animations:^{
                    // Snap the ship piece
                    self.center = CGPointMake(xValue,yValue);
                    
                    // Check if this ship intersects with any other ship piece
                    BOOL bIntersects = NO;
                    switch (self.boatType) {
                        case typeSub:
                            bIntersects = (CGRectIntersectsRect(self.frame, appDelegate.gameModel.rectAircraftCarrier)) |
                            CGRectIntersectsRect(self.frame, appDelegate.gameModel.rectCommandShip);
                            break;
                        case typeCommandShip:
                            bIntersects = (CGRectIntersectsRect(self.frame, appDelegate.gameModel.rectAircraftCarrier)) |
                            CGRectIntersectsRect(self.frame, appDelegate.gameModel.rectSubmarine);
                            break;
                        case typeAircraft:
                            bIntersects = (CGRectIntersectsRect(self.frame, appDelegate.gameModel.rectSubmarine)) |
                            CGRectIntersectsRect(self.frame, appDelegate.gameModel.rectCommandShip);
                            break;
                        default:
                            break;
                    }
                    // Don't allow ship pieces to overlap
                    if (bIntersects == YES) {
                        alert = [[UIAlertView alloc]
                                 initWithTitle:@"Ships cannot overlap"
                                 message:nil
                                 delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
                        [alert show];
                    }
                    else
                    {
                        // The ship piece has been correctly placed
                        self.piecePlaced = YES;
                        
                        [self _playClick];
                        
                        // Save the ship frame location for the next move
                        switch (self.boatType) {
                            case typeSub:
                                appDelegate.gameModel.rectSubmarine = self.frame;
                                break;
                            case typeCommandShip:
                                appDelegate.gameModel.rectCommandShip = self.frame;
                                break;
                            case typeAircraft:
                                appDelegate.gameModel.rectAircraftCarrier = self.frame;
                                break;
                            default:
                                break;
                        }
                    }
                }];
            }
        }
    }
    
    // Archive data via a delegate
    [[self delegate] archiveData];
}

- (void)handleBoatTap:(UIGestureRecognizer *)gestureRecognizer
{
    // Search for an intersection of the boat view with the grid sector view
    for (BDASectorView* sector in appDelegate.gameModel.sectors) {
        CGRect intersection = CGRectIntersection(sector.frame, [gestureRecognizer.view frame]);
        
        if(CGRectIsNull(intersection)) {
            // No matching sector for this tap
        }
        else
        {
            // The user tapped on a portion of a ship covering two or more sectors
            // Locate the sector that the tap was in by converting the target point to the grid sector's scale
            
            CGPoint targetPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
            CGPoint tapPoint = [gestureRecognizer.view convertPoint:targetPoint toView:sector.superview];
            
            // Adjust the X and Y starting points given the offset of grid board superview
            tapPoint.x -= XPAD;
            tapPoint.y -= YPAD;
            
            // Check if the tap point is within a game grid sector
            if (CGRectContainsPoint(sector.frame, tapPoint))
            {
                // Found the sector underneath the ship tap point
                NSLog(@"Tapped in sector x: %f, y:%f", tapPoint.x, tapPoint.y);
                              
                // Display the tapped sector's row and column in the label
                [[self delegate] displaySector:sector];
                break;
            }
        }
    }
}


- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [UIView animateWithDuration:1.0f animations:^{
        // Move the boat back to its original position because it overlapped
        self.center = previousPoint;
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]];
}

#pragma mark Encoder/Decoder

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        self.boatType = [aDecoder decodeIntForKey:kBoatTypeKey];
        self.boatStartX = [aDecoder decodeFloatForKey:kBoatStartX];
        self.boatStartY = [aDecoder decodeFloatForKey:kBoatStartY];
        self.piecePlaced = [aDecoder decodeBoolForKey:kPiecePlaced];
        float x = [aDecoder decodeFloatForKey:kCurrentX];
        float y = [aDecoder decodeFloatForKey:kCurrentY];
        self.center = CGPointMake(x,y);
        self.lastSector = [aDecoder decodeObjectForKey:kLastSector];
        self.rotated = [aDecoder decodeBoolForKey:kRotated];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder;
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeInt:self.boatType forKey:kBoatTypeKey];
    [aCoder encodeFloat:self.boatStartX forKey:kBoatStartX];
    [aCoder encodeFloat:self.boatStartY forKey:kBoatStartY];
    [aCoder encodeBool:self.piecePlaced forKey:kPiecePlaced];
    [aCoder encodeFloat:self.center.x forKey:kCurrentX];
    [aCoder encodeFloat:self.center.y forKey:kCurrentY];
    [aCoder encodeObject:self.lastSector forKey:kLastSector];
    [aCoder encodeBool:self.rotated forKey:kRotated];
}


@end
