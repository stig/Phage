/*
 Copyright (C) 2006,2007 Stig Brautaset. All rights reserved.
 
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
#import "BoardView.h"
#import "Phage.h"
#import "PhageState.h"

@interface BoardView (BoardViewPrivate)
- (void)drawState;
@end


@implementation BoardView

- (void)dealloc
{
    [hint release];
    [disks release];
    [super dealloc];
}

#pragma mark Setters


- (void)setTheme:(id)this
{
    if (disks != this) {
        [disks release];
        disks = [this retain];
        [self drawState];        
    }
}

- (void)setHint:(id)this
{
    if (hint != this) {
        [hint release];
        hint = [this retain];
        [self drawState];        
    }
}

- (void)setHighlightMoves:(BOOL)x
{
    highlightMoves = x;
    NSLog(@"highlighting moves: %@", x ? @"Yes" : @"No");
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
        
        /* when setting a new state, reset the hint */
        [hint release];
        hint = nil;
    }
    [self drawState];
}

#pragma mark Misc

- (void)drawState
{
    /* ick! */
    int map[Dirty+1] = { 0, };
    map[ Empty ] = 0;
    map[ Black | Diamond ]  = 1;
    map[ Black | Triangle ] = 2;
    map[ Black | Square ]   = 3;
    map[ Black | Circle ]   = 4;
    map[ White | Circle ]   = 5;
    map[ White | Square ]   = 6;
    map[ White | Triangle ] = 7;
    map[ White | Diamond ]  = 8;
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
    
    if (hint) {
        int sr = [[hint objectForKey:@"srcRow"] intValue];
        int sc = [[hint objectForKey:@"srcCol"] intValue];
        int dr = [[hint objectForKey:@"dstRow"] intValue];
        int dc = [[hint objectForKey:@"dstCol"] intValue];
        
        /*
           The following two lines doesn't do anything yet. I have to
           create a custome NSImageCell subclass and override
           setHighlighted: first. I'll get to that.
         */
         [self highlightCell:YES atRow:sr column:sc];
         [self highlightCell:YES atRow:dr column:dc];
        
        /* TODO: remove this when we use a custom NSImageCell subclass */
        NSImageCell *ic = [self cellAtRow:sr column:sc];
        [ic setImageFrameStyle:NSImageFrameButton];

        ic = [self cellAtRow:dr column:dc];
        [ic setImageFrameStyle:NSImageFrameButton];
    }
    
    [self setNeedsDisplay:YES];
}


- (void)mouseDown:(NSEvent *)event
{
    if (![self delegate])
        return;
    NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
    int r, c;
    [self getRow:&r column:&c forPoint:p];
    NSImageCell *ic = [self cellAtRow:r column:c];
    
    if (!selectedOrigin) {
        for (int i = 0; i < [legalMoves count]; i++) {
            id o = [legalMoves objectAtIndex:i];
            if ([[o valueForKey:@"srcRow"] intValue] == r
                    && [[o valueForKey:@"srcCol"] intValue] == c) {
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
        id move = [PhageState moveFromR:srcRow c:srcCol toR:r c:c];
        if ([legalMoves indexOfObject:move] != NSNotFound) {
            selectedOrigin = NO;
            [[self delegate] move:move];

        }
    }
}

@end
