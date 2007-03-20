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
#import "PhageMove.h"

@implementation PhageState

- (id)init
{
    self = [super init];
    if (self) {
    
        player = White;
        
        /* clear the board */
        for (int r = 0; r < 8; r++)
            for (int c = 0; c < 8; c++)
                board[r][c] = Empty;
        
        /* drop the pieces in their initial locations */
        board[7][0] = White | Diamond;
        board[6][2] = White | Triangle;
        board[5][4] = White | Square;
        board[4][6] = White | Circle;

        board[3][1] = Black | Circle;
        board[2][3] = Black | Square;
        board[1][5] = Black | Triangle;
        board[0][7] = Black | Diamond;
        
        /* set how many moves can be done by each player */
        for (int i = 0; i < Dirty; i++)
            remainingMoves[i] = 7;
        
        
    }
    return self;
}

- (int)movesLeftForIndex:(int)x
{
    int piece;
    /* 
    map[ Black | Circle ] = 1;
    map[ Black | Diamond ] = 2;
    map[ Black | Square ] = 3;
    map[ Black | Triangle ] = 4;
    map[ White | Circle ] = 5;
    map[ White | Diamond ] = 6;
    map[ White | Square ] = 7;
    map[ White | Triangle ] = 8;
    */
    switch (x) {
        case 1: piece = Black | Diamond;     break;
        case 2: piece = Black | Triangle;    break;
        case 3: piece = Black | Square;     break;
        case 4: piece = Black | Circle;   break;
        case 5: piece = White | Circle;     break;
        case 6: piece = White | Square;    break;
        case 7: piece = White | Triangle;     break;
        case 8: piece = White | Diamond;   break;
        default: [NSException raise:@"unsupported input" format:@"unsupported input (%d)", x];
    }
    
    return remainingMoves[piece];
}

- (NSArray *)moveFromRow:(int)r col:(int)c inDirection:(int)dir
{
    int p = board[r][c];
    id moves = [NSMutableArray array];

    if (!remainingMoves[p])
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
        
        if (dr > 7 || dr < 0 || dc > 7 || dc < 0 || board[dr][dc] != Empty)
            break;
        
        [moves addObject:[PhageMove moveFromR:(int)r c:(int)c toR:(int)dr c:(int)dc]];
    }
    return moves;
}

- (double)currentFitness
{
    unsigned me = [[self movesAvailable] count];

    player = player == White ? Black : White;
    unsigned you = [[self movesAvailable] count];

    player = player == White ? Black : White;
    return (float)me - you;
}

- (int)winner
{
    if ([[self movesAvailable] count])
        [NSException raise:@"not an end state" format:@"still legal moves"];

    float fitness = [self currentFitness];
    if (fitness == 0.0)
        return 0;

    if (fitness < 0)
        return player == White ? 2 : 1;
        
    [NSException raise:@"impossible" format:@"huh? what trickery is this?"];
    return -1;
}

- (NSArray *)movesAvailable
{
    id moves = [NSMutableArray array];
    for (int r = 0; r < 8; r++) {
        for (int c = 0; c < 8; c++) {
            int p = board[r][c];

            /* Skip this slot if it is empty,
               has been occupied before,
               or is occupied by the wrong player */
            if ((p == Empty) || (p & Dirty) || !(p & player))
                continue;

            for (int d = N; d < DIRECTIONS; d++) {
            
                if (p & Triangle && !( d == E || d == W || ((p & Black) && d == S) || ((p & White) && d == N))) {
                    continue;

                } else if ((p & Square) && d != NE && d != SE && d != SW && d != NW ) {
                    continue;
                
                } else if ((p & Diamond) && d != N && d != E && d != S && d != W ) {
                    continue;
                
                }
                [moves addObjectsFromArray:[self moveFromRow:r col:c inDirection:d]];
            }
        }
    }
    
    return moves;
}

- (void)transformWithMove:(id)move
{
    unsigned r = [move srcRow];
    unsigned c = [move srcCol];

    int p = board[r][c];
    board[r][c] = Dirty;
    board[ [move dstRow] ][ [move dstCol] ] = p;

    remainingMoves[p]--;

    player = player == White ? Black : White;
}

- (void)undoTransformWithMove:(id)move
{
    unsigned r = [move dstRow];
    unsigned c = [move dstCol];

    int p = board[r][c];
    board[r][c] = Empty;
    board[ [move srcRow] ][ [move srcCol] ] = p;

    remainingMoves[p]++;

    player = player == White ? Black : White;
}

- (int)player
{
    return player == White ? 1 : 2;
}

- (NSArray *)array
{
    id a = [NSMutableArray array];
    for (int i = 0; i < 8; i++) {
        id b = [NSMutableArray array];
        for (int j = 0; j < 8; j++)
            [b addObject:[NSNumber numberWithInt:board[i][j]]];
        [a addObject:b];
    }
    return a;
}

- (NSString *)description
{
    return [[self array] description];
}

@end
