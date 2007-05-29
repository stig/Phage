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
    id st = [[PhageState new] autorelease];
    [self setAlphaBeta:[[SBAlphaBeta alloc] initWithState:st]];

    [super resetGame];
}

- (void)awakeFromNib
{
    [[board window] makeKeyAndOrderFront:self];
    [board setDelegate:self];
    pieces = [[self chopImage:[NSImage imageNamed:@"pieces"] rows:2 columns: 5] retain];
    [board setTheme:pieces];

    [[blackMoves tableColumnWithIdentifier:@"piece"] setDataCell:[NSImageCell new]];
    [[whiteMoves tableColumnWithIdentifier:@"piece"] setDataCell:[NSImageCell new]];

    [self resetGame];
}


#pragma mark IBActions

- (IBAction)showMoveHint:(id)sender
{
    [board setHint:[self findMove]];
}

- (IBAction)toggleHighlightMoves:(id)sender
{
    highlightMoves = highlightMoves ? NO : YES;
    [board setHighlightMoves:highlightMoves];
}


#pragma mark Actions

/** AI move */
- (id)findMove
{
    [progressIndicator startAnimation:self];

    id move = nil;
    if (level < 4) {
        move = [alphaBeta moveFromSearchWithPly:level];
    } else {
        int ply = level * 10.0;
        NSTimeInterval interval = (NSTimeInterval)(ply * ply / 1000.0);
        move = [alphaBeta moveFromSearchWithInterval:interval];
    }

    [progressIndicator stopAnimation:self];    
    return move;
}

- (void)updateViews
{
    [board setState:[[self state] array] moves:[alphaBeta movesAvailable]];
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
    BOOL north = this == blackMoves;
    
    /* Should really have a dictionary with the images for each slot. */
    id map = [NSDictionary dictionaryWithObjectsAndKeys:
        @"0", @"Empty",
        @"1", @"NorthDiamond",
        @"2", @"NorthTriangle",
        @"3", @"NorthSquare",
        @"4", @"NorthCircle",
        @"5", @"SouthCircle",
        @"6", @"SouthSquare",
        @"7", @"SouthTriangle",
        @"8", @"SouthDiamond",
        @"9", @"Dirty",
        nil];

    id cells;
    BOOL img = NO;
    id state = [alphaBeta currentState];
    switch ([this columnWithIdentifier:[column identifier]]) {
        case 0:
            img = YES;
            cells = north ? [state northPieces] : [state southPieces];
            break;
        case 1:
            cells = north ? [state northMovesLeft] : [state southMovesLeft];
            break;
        default:
            [NSException raise:@"impossible"
                        format:@"I was passed a column I don't know about"];
    }
    id cell = [cells objectAtIndex:row];
    if (img) {
        int idx = [[map objectForKey:cell] intValue];
        return [pieces objectAtIndex:idx];
    }
    return cell;
}



@end
