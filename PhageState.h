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

#import <AlphaBeta/AlphaBeta.h>

/* directions to move in */
enum { N = 0, NE, E, SE, S, SW, W, NW, DIRECTIONS };

enum {
    Empty = 0,

    Circle = 1,
    Diamond = 2,
    Square = 4,
    Triangle = 8,

    Black = 16,
    White = 32,
    Dirty = 64,
};

@interface PhageState : NSObject <SBMutableAlphaBetaState> {
@public
    int player;
    int board[8][8];
    int remainingMoves[Dirty];
}

- (int)movesLeftForIndex:(int)x;
+ (id)moveFromR:(int)sr c:(int)sc toR:(int)r c:(int)c;

@end
