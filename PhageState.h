//
//  PhageState.h
//  Phage
//
//  Created by Stig Brautaset on 29/01/2006.
//  Copyright 2006 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AlphaBeta/AlphaBetaState.h>

enum {
     BLACK = -1,
     EMPTY,
     WHITE
};

enum {
    DIAMOND = 1,
    TRIANGLE,
    SQUARE,
    CIRCLE
};

@interface PhageState : NSObject <AlphaBetaStateWithUndo> {
    int board[8][8];
    int moves[2][4];
    int turn;
}

- (NSString *)string;
@end
