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

#import "PhageState.h"

@implementation PhageState

- (id)init
{
    self = [super init];
    if (self) {
    
        player = @"South";
        
        /* drop the pieces in their initial locations */
        board[7][0] = @"SouthDiamond";
        board[6][2] = @"SouthTriangle";
        board[5][4] = @"SouthSquare";
        board[4][6] = @"SouthCircle";

        board[3][1] = @"NorthCircle";
        board[2][3] = @"NorthSquare";
        board[1][5] = @"NorthTriangle";
        board[0][7] = @"NorthDiamond";
        
        /* set how many moves can be done by each player */
        movesLeft = [NSMutableDictionary new];
        for (int i = 0; i < 8; i++)
            for (int j = 0; j < 8; j++)
                if (board[i][j])
                    [movesLeft setObject:@"7" forKey:board[i][j]];
        
    }

    return self;
}

- (int)movesLeftForIndex:(int)x
{
    id piece;
    switch (x) {
        case 1: piece = @"NorthDiamond";    break;
        case 2: piece = @"NorthTriangle";   break;
        case 3: piece = @"NorthSquare";     break;
        case 4: piece = @"NorthCircle";     break;
        case 5: piece = @"SouthCircle";     break;
        case 6: piece = @"SouthSquare";     break;
        case 7: piece = @"SouthTriangle";   break;
        case 8: piece = @"SouthDiamond";    break;
        default:
            [NSException raise:@"unsupported input"
                        format:@"unsupported input (%d)", x];
    }
    
    return [[movesLeft objectForKey:piece] intValue];
}

+ (id)moveFromR:(int)sr c:(int)sc toR:(int)r c:(int)c
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt:sr], @"srcRow",
        [NSNumber numberWithInt:sc], @"srcCol",
        [NSNumber numberWithInt:r], @"dstRow",
        [NSNumber numberWithInt:c], @"dstCol",
        nil];
}

- (NSArray *)moveFromRow:(int)r col:(int)c inDirection:(int)dir
{
    id p = board[r][c];
    id moves = [NSMutableArray array];

    if ([[movesLeft objectForKey:p] intValue] < 1)
        return moves;
    
    int dr = r, dc = c;
    for (int i = 1; i < 8; i++) {
        switch (dir) {
            case N:     dr--;       break;
            case NE:    dr--; dc++; break;
            case E:           dc++; break;
            case SE:    dr++; dc++; break;
            case S:     dr++;       break;
            case SW:    dr++; dc--; break;
            case W:           dc--; break;
            case NW:    dr--; dc--; break;
        }
        
        if (dr > 7 || dr < 0 || dc > 7 || dc < 0 || board[dr][dc])
            break;
        
        [moves addObject:[PhageState moveFromR:r c:c toR:dr c:dc]];
    }
    return moves;
}

- (double)currentFitness
{
    unsigned me = [[self movesAvailable] count];

    [self togglePlayer];
    unsigned you = [[self movesAvailable] count];

    [self togglePlayer];
    return (double)me - you;
}

- (void)togglePlayer
{
    player = [player isEqual:@"South"] ? @"North" : @"South";
}

- (double)endStateScore
{
    if ([[self movesAvailable] count])
        [NSException raise:@"not an end state" format:@"still legal moves"];

    return [self currentFitness];
}

- (BOOL)legalDirection:(int)d forPiece:(NSString*)p
{
    if ([p hasSuffix:@"Triangle"] && !( d == E || d == W || ([p hasPrefix:@"North"] && d == S) || ([p hasPrefix:@"South"] && d == N))) {
        return 0;

    } else if ([p hasSuffix:@"Square"] && d != NE && d != SE && d != SW && d != NW ) {
        return 0;
    
    } else if ([p hasSuffix:@"Diamond"] && d != N && d != E && d != S && d != W ) {
        return 0;
    
    }
    return 1;
}

- (NSArray *)movesAvailable
{
    id moves = [NSMutableArray array];
    for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
            id p = board[r][c];

            if (!p || ![p hasPrefix:player])
                continue;

            for (int d = N; d < DIRECTIONS; d++) {
                if (![self legalDirection:d forPiece:p])
                    continue;
                [moves addObjectsFromArray:[self moveFromRow:r col:c inDirection:d]];
            }
        }
    }
    
    return moves;
}

- (void)transformWithMove:(id)move
{
    int r = [[move valueForKey:@"srcRow"] intValue];
    int c = [[move valueForKey:@"srcCol"] intValue];
    int tr = [[move valueForKey:@"dstRow"] intValue];
    int tc = [[move valueForKey:@"dstCol"] intValue];

    id p = board[r][c];
    board[r][c] = @"Dirty";
    board[tr][tc] = p;

    [movesLeft setObject:[NSNumber numberWithInt:[[movesLeft objectForKey:p] intValue]-1]
                  forKey:p];

    [self togglePlayer];
}

- (void)undoTransformWithMove:(id)move
{
    int r = [[move valueForKey:@"srcRow"] intValue];
    int c = [[move valueForKey:@"srcCol"] intValue];
    int tr = [[move valueForKey:@"dstRow"] intValue];
    int tc = [[move valueForKey:@"dstCol"] intValue];

    id p = board[tr][tc];
    board[tr][tc] = nil;
    board[r][c] = p;

    [movesLeft setObject:[NSNumber numberWithInt:[[movesLeft objectForKey:p] intValue]+1]
                  forKey:p];

    [self togglePlayer];
}

- (int)player
{
    return [player isEqual: @"South"] ? 1 : 2;
}

- (NSArray *)array
{
    id a = [NSMutableArray array];
    for (int i = 0; i < 8; i++) {
        id b = [NSMutableArray array];
        for (int j = 0; j < 8; j++) {
            if (!board[i][j])
                [b addObject:[NSNull null]];
            else 
                [b addObject:board[i][j]];
        }
        [a addObject:b];
    }
    return a;
}

- (NSString *)description
{
    return [[self array] description];
}


- (NSArray *)northPieces
{
    return [@"NorthDiamond NorthTriangle NorthSquare NorthCircle"
        componentsSeparatedByString:@" "];
}

- (NSArray *)southPieces
{
    return [@"SouthCircle SouthSquare SouthTriangle SouthDiamond"
        componentsSeparatedByString:@" "];
}

- (NSArray *)northMovesLeft
{
    return [movesLeft objectsForKeys:[self northPieces]
                      notFoundMarker:[NSNull null]];
}

- (NSArray *)southMovesLeft
{
    return [movesLeft objectsForKeys:[self southPieces]
                      notFoundMarker:[NSNull null]];
}


@end
