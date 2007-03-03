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

@implementation Phage


- (void)awakeFromNib
{
    [[board window] makeKeyAndOrderFront:self];
    [board setController:self];
    [board setTheme:[NSArray arrayWithObjects:
        [NSImage imageNamed:@"Empty"],
        [NSImage imageNamed:@"RedCircle"],
        [NSImage imageNamed:@"RedDiamond"],
        [NSImage imageNamed:@"RedSquare"],
        [NSImage imageNamed:@"RedTriangle"],
        [NSImage imageNamed:@"YellowCircle"],
        [NSImage imageNamed:@"YellowDiamond"],
        [NSImage imageNamed:@"YellowSquare"],
        [NSImage imageNamed:@"YellowTriangle"],
        [NSImage imageNamed:@"Dirty"],
        nil]];
        
    [self resetGame];
}

/** Displays an alert when "Game Over" is detected. */
- (void)gameOverAlert
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];

    int winner = [ab winner];
    NSString *msg = winner == 2  ? @"You lost!" :
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

/** Performs undo twice (once for AI, once for human) 
and updates views in between. */
- (IBAction)undo:(id)sender
{
    [ab undo];
    [self updateViews];
    [ab undo];
    [self autoMove];
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

/** Initiate a new game. */
- (IBAction)newGame:(id)sender
{
    if ([ab countMoves]) {
		[self newGameAlert];
	}
	else {
		[self resetGame];
	}
}

/** Make the AI perform a move. */
- (void)aiMove
{
    if ([ab iterativeSearch]) {
        [self autoMove];
    }
    else {
        NSLog(@"AI cannot move");
    }
}

/** Perform the given move. */
- (void)move:(id)m
{
    @try {
        id moves = [[ab state] movesAvailable];
        if ([moves indexOfObject:m] == NSNotFound)
            [NSException raise:@"illegal move" format:@"illegal move"];
        
        [ab move:m];
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
    return [ab state];
}

- (void)dealloc
{
    [ab release];
    [super dealloc];
}

/** Figure out if the AI should move "by itself". */
- (void)autoMove
{
    [self updateViews];
    
    if ([ab isGameOver]) {
        [self gameOverAlert];
    }
    if (2 == [[self state] player]) {
        [self aiMove];
        [self updateViews];
    }
}

- (void)resetGame
{
    [ab release];
    ab = [[SBAlphaBeta alloc] initWithState:
        [[PhageState new] autorelease]];

    [self autoMove];
}

- (void)updateViews
{
    [board setState:[[ab state] array]];
    [board setNeedsDisplay:YES];
    [[board window] display];
}



@end