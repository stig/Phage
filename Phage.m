/*
Copyright (C) 2007 Stig Brautaset. All rights reserved.

This file is part of Phage.

Phage is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

Phage is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Phage; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

#import "Phage.h"
#import "PhageState.h"


#define INTERVAL 0.3

@implementation Phage


- (NSArray *)chopImage:(NSImage *)image rows:(unsigned)rows columns:(unsigned)cols
{
    id a = [NSMutableArray array];
    
    NSSize imgsize = [image size];
    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            
            id img = [[NSImage alloc] initWithSize:NSMakeSize(100, 100)];
        
            /* fugly, but the simplest way of determining the source rectancle */
            NSRect src = NSMakeRect(imgsize.width / (float)cols * c,
                                    imgsize.height - (imgsize.height / (float)rows) * (1.0 + r),
                                    imgsize.width / (float)cols,
                                    imgsize.height / (float)rows);
        
            [img lockFocus];
            [image drawInRect:NSMakeRect(0, 0, 100, 100)
                    fromRect:src
                   operation:NSCompositeCopy
                    fraction:1.0];
            [img unlockFocus];
            [a addObject:[img autorelease]];
        }
    }
    return a;
}


- (void)resetGame
{
    [ab release];
    ab = [[SBAlphaBeta alloc] initWithState:
        [[PhageState new] autorelease]];
    [self autoMove];
}

- (void)awakeFromNib
{

    ai = 2;         /* The AI player plays second. */
    automatic = NO; /* Should the AI move for both players? */

    [[board window] makeKeyAndOrderFront:self];
    [board setController:self];
    pieces = [[self chopImage:[NSImage imageNamed:@"pieces"] rows:2 columns: 5] retain];
    [board setTheme:pieces];

    [[blackMoves tableColumnWithIdentifier:@"piece"] setDataCell:[NSImageCell new]];
    [[whiteMoves tableColumnWithIdentifier:@"piece"] setDataCell:[NSImageCell new]];

    [self resetGame];
}

- (void)dealloc
{
    [ab release];
    [super dealloc];
}

#pragma mark Alerts

/** Displays an alert when "Game Over" is detected. */
- (void)gameOverAlert
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];

    int winner = [ab winner];
    NSString *msg = winner == ai ? @"You lost!" :
                    !winner      ? @"You managed a draw!" :
                                   @"You won!";
    
    [alert setMessageText:msg];
    [alert setInformativeText:@"Do you want to play another game?"];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self resetGame];
    }
}


/** Displays an alert when the "New Game" action is chosen. */
- (void)newGameAlert
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"Start a new game"];
    [alert setInformativeText:@"Are you sure you want to terminate the current game and start a new one?"];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self resetGame];
    }
}

#pragma mark IBActions

/**
Performs undo twice (once for AI, once for human) 
and updates views in between.
*/
- (IBAction)undo:(id)sender
{
    [ab undoLastMove];
    [self updateViews];
    [ab undoLastMove];
    [self autoMove];
}

- (IBAction)newGame:(id)sender
{
    automatic = NO;
    if ([ab countMoves]) {
        [self newGameAlert];
    }
    else {
        [self resetGame];
    }
}

- (IBAction)hint:(id)sender
{
    id move = [ab moveFromSearchWithInterval:INTERVAL];
    [board setHint:move];
}

- (IBAction)toggleAutomatic:(id)sender
{
    automatic = automatic ? NO : YES;
    NSLog(@"set automatic state: %u", automatic);
    [self autoMove];
}

#pragma mark Actions

/** Perform the given move. */
- (void)move:(id)m
{
    @try {
        id moves = [ab movesAvailable];
        if ([moves indexOfObject:m] == NSNotFound)
            [NSException raise:@"illegal move" 
                        format:@"illegal move"];
        
        [ab applyMove:m];
    }
    @catch (id any) {
        NSLog(@"Illegal move attempted: %@", m);
    }
    @finally {
        [self autoMove];
    }
}

/** Return the current state (pass-through to SBAlphaBeta). */
- (id)state
{
    return [ab currentState];
}

/** Figure out if the AI should move "by itself". */
- (void)autoMove
{
    [self updateViews];
    
    if ([ab isGameOver]) {
        automatic = NO;
        [self gameOverAlert];
    }
    if (automatic || ai == [ab playerTurn]) {
        if ([ab applyMoveFromSearchWithInterval:INTERVAL]) {
            [self autoMove];
        }
        else {
            automatic = NO;
            NSLog(@"AI cannot move");
        }
        [self updateViews];
    }
}

- (void)updateViews
{
    [board setState:[[self state] array] moves:[ab movesAvailable]];
    [board setNeedsDisplay:YES];
    [blackMoves reloadData];
    [whiteMoves reloadData];
    [[board window] display];
}


#pragma mark NSTableView

- (int)numberOfRowsInTableView:(NSTableView *)this
{
    return 4;
}

- (id)tableView:(NSTableView *)this objectValueForTableColumn:(NSTableColumn *)column row:(int)row
{
    int offset = this == whiteMoves ? 5 : 1;
    id piece;
    switch ([this columnWithIdentifier:[column identifier]]) {
        case 0:
            piece = [pieces objectAtIndex:offset + row];
            break;
        case 1:
            piece = [NSNumber numberWithInt: [[self state] movesLeftForIndex: offset + row]];
            break;
        default:
            [NSException raise:@"impossible"
                        format:@"I was passed a column I don't know about"];
    }
    return piece;
}



@end
