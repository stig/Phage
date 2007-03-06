/*
 Copyright (C) 2006 Stig Brautaset. All rights reserved.
 
 This file is part of CocoaGames.
 
 CocoaGames is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 CocoaGames is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with CocoaGames; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
 */
#import "BoardView.h"
#import "Phage.h"
#import "PhageState.h"
#import "PhageMove.h"

@implementation BoardView

- (void)dealloc
{
    [disks release];
    [controller release];
    [super dealloc];
}

- (void)setController:(id)this
{
    if (controller != this) {
        [controller release];
        controller = [this retain];
    }
}

- (void)setTheme:(id)this
{
    [disks release];
    disks = [this retain];
}

- (void)drawState
{
    /* ick! */
    int map[Dirty+1] = { 0, };
    map[ Empty ] = 0;
    map[ Black | Circle ] = 1;
    map[ Black | Diamond ] = 2;
    map[ Black | Square ] = 3;
    map[ Black | Triangle ] = 4;
    map[ White | Circle ] = 5;
    map[ White | Diamond ] = 6;
    map[ White | Square ] = 7;
    map[ White | Triangle ] = 8;
    map[ Dirty ] = 9;

    for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
            int slot = [[[state objectAtIndex:r] objectAtIndex:c] intValue];
            NSImageCell *ic = [self cellAtRow:r column:c];
            [ic setImage:[disks objectAtIndex:map[slot]]];
            [ic setImageScaling:NSScaleToFit];
            [ic setImageFrameStyle:NSImageFrameNone];
            [self drawCell:ic];
        }
    }
    [self setNeedsDisplay:YES];
}

- (void)setState:(NSArray *)this moves:(NSArray *)moves
{
    if (legalMoves != moves) {
        [legalMoves release];
        legalMoves = [moves retain];
    }

    if (state != this) {
        [state release];
        state = [this retain];
        
        rows = [this count];
        cols = [[this lastObject] count];
        
        int r, c;
        [self getNumberOfRows:&r columns:&c];
        if (r != rows || c != cols) {
            [self renewRows:rows columns:cols];
            
            /* such.. a.. hack... - make the matrix resize, as this is
               the only way I've found to get the cells to resize. */
            NSSize s = [self frame].size;
            [self setFrameSize:NSMakeSize(100,100)];
            [self setFrameSize:s];
        }
    }
    [self drawState];
}

- (void)mouseDown:(NSEvent *)event
{
    if (!controller)
        return;
    NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
    int r, c;
    [self getRow:&r column:&c forPoint:p];
    NSImageCell *ic = [self cellAtRow:r column:c];
    
    if (!selectedOrigin) {
        for (int i = 0; i < [legalMoves count]; i++) {
            id o = [legalMoves objectAtIndex:i];
            if ([o srcRow] == r && [o srcCol] == c) {
                [ic setImageFrameStyle:NSImageFrameGroove];
                [self drawCell:ic];
                selectedOrigin = YES;
                srcRow = r;
                srcCol = c;
                break;
            }
        }
        
    } else if (r == srcRow && c == srcCol) {
        [ic setImageFrameStyle:NSImageFrameNone];
        [self drawCell:ic];
        selectedOrigin = NO;
        
    } else {
        id move = [PhageMove moveFromR:srcRow c:srcCol toR:r c:c];
        if ([legalMoves indexOfObject:move] != NSNotFound) {
            selectedOrigin = NO;
            [controller move:move];

        }
    }
}

@end
