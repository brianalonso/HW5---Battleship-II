//
//  BDAViewController.m
//  HW5 - Battleship
//
//  Created by Brian Alonso on 2/16/13.
//  Copyright (c) 2013 Brian Alonso. All rights reserved.
//

#import "BDAViewController.h"
#import "BDAAppDelegate.h"
#import "BDASectorView.h"
#import "BDAShipController.h"
#import "BDAGlobals.h"
#import "BDADataStore.h"

@interface BDAViewController ()
// Outlets
@property (weak, nonatomic) IBOutlet UILabel *lblSector;
@property (weak, nonatomic) IBOutlet UIButton *buttonStart;

@property (nonatomic, strong) NSArray *horizontalConstraints;
@property (nonatomic, strong) NSArray *verticalConstraints;

- (IBAction)buttonStartPressed:(id)sender;

@end

@implementation BDAViewController {
    // Define reference to a global game piece array
    BDAAppDelegate *appDelegate;
    BDASectorView *lastSector;
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // Apply the constraints to the button and label
    [self _updateViewConstraints];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Reference the game model array defined globally in the AppDelegate
    appDelegate = (BDAAppDelegate *)[[UIApplication sharedApplication] delegate];
        
    // initialize the game model
    appDelegate.gameModel = [[BDAGameModel alloc] init];
    
    // Iterate over the sectors in the model, drawing them
    for (BDASectorView* sector in appDelegate.gameModel.sectors) {
        
        // Configure gesture recognizer for a tap for the sector view
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handleSectorTap:)];
        [sector addGestureRecognizer:tap];
        
        //	Add the grid sector view to the view hierarchy
        [self.view addSubview:sector];
    }
    
    // Build each of the ship pieces
    [self _InstantiateShips];
    
    // Disable the Begin Game button until restore is performed
    self.buttonStart.hidden = YES;
    
    // Restore the ship piece data from the archive, if present
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [[NSMutableData alloc] initWithContentsOfFile:filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        
        NSMutableArray *archivedShips = [unarchiver decodeObjectForKey:kBoatArrayKey];
        [unarchiver finishDecoding];
        
        BOOL bHide = NO;
        for (BDAShipController *savedShip in archivedShips) {
            // Apply the archived values to the ship pieces
            for (NSString *key in appDelegate.gameModel.boats)
            {
                BDAShipController *boat = [appDelegate.gameModel.boats objectForKey:key];
                
                if (savedShip.boatType == boat.boatType)
                {
                    boat.piecePlaced = savedShip.piecePlaced;
                    boat.rotated = savedShip.rotated;
                    
                    // Move the pieces to their archived positions
                    [UIView animateWithDuration:0.50f animations:^{
                        boat.center = CGPointMake(savedShip.center.x, savedShip.center.y);
                        
                        // The ship piece is rotated, set it back to horizontal
                        if (boat.rotated == YES)
                        {
                            // Convert the degrees to radians and animate the movement
                            CGFloat radians = 90 * M_PI / 180;
                            boat.transform  = CGAffineTransformRotate(boat.transform, radians);
                        }
                    }];
                    
                    // Display the last game board grid sector accessed
                    self.lblSector.text = savedShip.lastSector;
                    
                    // Check if all ship pieces are positioned correctly
                    if (savedShip.piecePlaced == NO)
                    {
                        // Found a ship piece that is not placed
                        bHide = YES;
                    }
                    break;
                }
            }
        }
        // Show or hide the Start Game button
        [self _restoreArchivedStartButton:bHide];
    }
    
    // Setup a notification for existing app when it moves to background
    UIApplication *app = [UIApplication sharedApplication];
                                    [[NSNotificationCenter defaultCenter]
                                     addObserver:self
                                     selector:@selector(applicationWillResignActive:)
                                     name:UIApplicationWillResignActiveNotification
                                     object:app];
}

#pragma mark Encoding/Decoding

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"battleship.archive"];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    // Application will become inactive
    // Archive game information
    [self _archiveData];
}

#pragma mark Create Ship Pieces

- (void)_InstantiateShips
{
    //----------------------------
    // Create the Aircraft Carrier
    
    CGRect rectCarrier = CGRectMake(0, 0, CarrierWidth, BoatHeight);
    BDAShipController *boatView_Carrier = [[BDAShipController alloc] initWithFrame:rectCarrier
                                                                  boatType:typeAircraft];
    // Set myself as the delegate to handle screen interaction
    [boatView_Carrier setDelegate:self];
    
    // Move the boat to the starting position
    boatView_Carrier.boatStartX = CarrierWidth/2 + 115.0;
    boatView_Carrier.boatStartY = BoatHeight/2 + 370.0;
    boatView_Carrier.center = CGPointMake(boatView_Carrier.boatStartX, boatView_Carrier.boatStartY);
    [self.view addSubview:boatView_Carrier];
    
    // Add the Carrier to the game model
    appDelegate.gameModel.rectAircraftCarrier_Start = boatView_Carrier.frame;
    
    // Add the ship pieces to the model's dictionary
    [appDelegate.gameModel.boats setObject: boatView_Carrier forKey: [NSString stringWithFormat:@"%i", boatView_Carrier.boatType]];
    
    //----------------------------
    // Create the Submarine
    CGRect rectSubmarine = CGRectMake(0, 0, SubWidth, BoatHeight);
    BDAShipController *boatView_Sub = [[BDAShipController alloc] initWithFrame:rectSubmarine
                                               boatType:typeSub];
    // Set myself as the delegate to handle screen interaction
    [boatView_Sub setDelegate:self];

    // Move the boat to the starting position
    boatView_Sub.boatStartX = SubWidth/2 + 5.0;
    boatView_Sub.boatStartY = BoatHeight/2 + 315.0;
    boatView_Sub.center = CGPointMake(boatView_Sub.boatStartX, boatView_Sub.boatStartY);

    [self.view addSubview:boatView_Sub];
    
    // Add the Submarine to the game model
    appDelegate.gameModel.rectSubmarine_Start = boatView_Sub.frame;
    
    // Add the ship pieces to the model's dictionary
    [appDelegate.gameModel.boats setObject: boatView_Sub forKey: [NSString stringWithFormat:@"%i", boatView_Sub.boatType]];
    

    //----------------------------
    // Create the command ship  
    CGRect rectCommandShip = CGRectMake(0, 0, CommandShipWidth, BoatHeight);
    BDAShipController *boatView_CommandShip = [[BDAShipController alloc] initWithFrame:rectCommandShip
                                               boatType:typeCommandShip];
    // Set myself as the delegate to handle screen interaction
    [boatView_CommandShip setDelegate:self];
    
    // Move the boat to the starting position
    boatView_CommandShip.boatStartX = CommandShipWidth/2 + 135.0;
    boatView_CommandShip.boatStartY = BoatHeight/2 + 315.0;
    boatView_CommandShip.center = CGPointMake(boatView_CommandShip.boatStartX, boatView_CommandShip.boatStartY);
    [self.view addSubview:boatView_CommandShip];
    
    // Add the Command ship to the game model
    appDelegate.gameModel.rectCommandShip_Start = boatView_CommandShip.frame;
    
    // Add the ship pieces to the model's dictionary
    [appDelegate.gameModel.boats setObject: boatView_CommandShip forKey: [NSString stringWithFormat:@"%i", boatView_CommandShip.boatType]];
}

#pragma mark GestureRecognizers

- (void)handleSectorTap:(UIGestureRecognizer *)gestureRecognizer
{
    // A sector of the grid was tapped (not occupied by a ship)
    BDASectorView *tappedSector = (BDASectorView*) gestureRecognizer.view;
    
    // Display the tapped sector's row and column in the label
    [self displaySector:tappedSector];
}


#pragma mark Archive data

- (void) _archiveData
{
    // Convert the last sector to a string
    NSString *ls = @"??";
    if (lastSector != nil)
        ls = [NSString stringWithFormat:@"%@%i", lastSector.rowLetter, lastSector.colNumber];
    
    // Archive the game information
    BOOL success = [[BDADataStore defaultStore] saveChanges:ls];
    if(success) {
        NSLog(@"Saved all of the Battleship items");
    } else {
        NSLog(@"Could not save any of the Battleship items");
    }

}

#pragma mark DelegateMethod

- (void) showStartButton:(BOOL)display
{
    self.buttonStart.hidden = display;
}

- (void) displaySector: (BDASectorView *)sector
{
    // Display the tapped sector's row and column in the label
    self.lblSector.text = [NSString stringWithFormat:@"%@%i", sector.rowLetter, sector.colNumber];
    
    // save the last sector accessed
    lastSector = sector;
}

- (void) archiveData
{
    // Archive game information
    [self _archiveData];
}

- (void) _restoreArchivedStartButton:(BOOL)bHide
{
    [self showStartButton:bHide];
    if (bHide == NO) {
        if ([[[self buttonStart] titleForState:UIControlStateNormal] isEqual: @"Begin Game"])
        {
            // Start the game
            [[self buttonStart] setTitle:@"Reset Game" forState:UIControlStateNormal];
        }
    }
}

#pragma mark ActionMethods

- (IBAction)buttonStartPressed:(id)sender
{
    if ([[[self buttonStart] titleForState:UIControlStateNormal] isEqual: @"Begin Game"])
    {
        // Start the game
        [[self buttonStart] setTitle:@"Reset Game" forState:UIControlStateNormal];
    }
    else
    {
        // Move the ships back to their starting point
        [UIView animateWithDuration:0.50f animations:^{
            for (NSString *key in appDelegate.gameModel.boats)
            {
                BDAShipController *boat = [appDelegate.gameModel.boats objectForKey:key];
            
                boat.center = CGPointMake(boat.boatStartX, boat.boatStartY);
                boat.piecePlaced = NO;
                
                // The ship piece is rotated, set it back to horizontal
                if (boat.rotated == YES)
                {
                    // Convert the degrees to radians and animate the movement
                    CGFloat radians = 90 * M_PI / 180;
                    boat.transform  = CGAffineTransformRotate(boat.transform, radians);
                }
                boat.rotated = NO;      // A reset ship piece is horizontal
                // Save the ship frame location for the next move
                switch (boat.boatType) {
                    case typeSub:
                        appDelegate.gameModel.rectSubmarine = boat.frame;
                        break;
                    case typeCommandShip:
                        appDelegate.gameModel.rectCommandShip = boat.frame;
                        break;
                    case typeAircraft:
                        appDelegate.gameModel.rectAircraftCarrier = boat.frame;
                        break;
                    default:
                        break;
                }

            }
            // Set the button to Begin Game
            [[self buttonStart] setTitle:@"Begin Game" forState:UIControlStateNormal];
        }];
    }
    
    // Archive game information
    [self _archiveData];
}

#pragma mark Constraints

- (void)_updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.lblSector setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.buttonStart setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // Clear the constraints for the button and label
    if (self.horizontalConstraints != nil) {
        [self.view removeConstraints:self.horizontalConstraints];
        self.horizontalConstraints = nil;
    }
    
    if (self.verticalConstraints != nil) {
        [self.view removeConstraints:self.verticalConstraints];
        self.verticalConstraints = nil;
    }
    
    NSMutableArray *horizConstraints = [NSMutableArray array];
    [horizConstraints addObject: [NSLayoutConstraint constraintWithItem:self.lblSector
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:-10]];
    
    [horizConstraints addObject: [NSLayoutConstraint constraintWithItem:self.buttonStart
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:-10]];
    
    self.horizontalConstraints = horizConstraints;
    [self.view addConstraints:self.horizontalConstraints];
    
    NSMutableArray *vertConstraints = [NSMutableArray array];
    [vertConstraints addObject: [NSLayoutConstraint constraintWithItem:self.buttonStart
                                                             attribute:NSLayoutAttributeBaseline
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.lblSector
                                                             attribute:NSLayoutAttributeBaseline
                                                            multiplier:1.0
                                                              constant:0]];
    
    self.verticalConstraints = vertConstraints;
    [self.view addConstraints:self.verticalConstraints];
    
    [self.view setNeedsUpdateConstraints];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
