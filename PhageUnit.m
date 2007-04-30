//
//  PhageUnit.m
//  Phage
//
//  Created by Stig Brautaset on 02/03/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "PhageUnit.h"

@implementation PhageUnit


- (void)setUp
{
    state = [PhageState new];
}

- (void)tearDown
{
    [state release];
    [ab release];
}

- (void)testPhageState
{
    STAssertEqualsWithAccuracy([state currentFitness], (double)0.0, 0.0, nil);

    id moves = [state movesAvailable];
    STAssertEquals([moves count], (unsigned)61, @"expected number of moves");

    /* test that first move is what we expect */
    id move = [moves objectAtIndex:0];
    STAssertEquals([[move valueForKey:@"srcRow"] intValue], 4, nil);
    STAssertEquals([[move valueForKey:@"srcCol"] intValue], 6, nil);
    STAssertEquals([[move valueForKey:@"dstRow"] intValue], 3, nil);
    STAssertEquals([[move valueForKey:@"dstCol"] intValue], 6, nil);

    [state transformWithMove:move];
    STAssertEqualsWithAccuracy([state currentFitness], (double)9.0, 0.00001, nil);

    /* dirty, dirty test (make go away) */
    STAssertEquals(state->board[4][6], (int)Dirty, nil);
    STAssertEquals(state->board[3][6], (int)(White | Circle), nil);
    
    moves = [state movesAvailable];
    STAssertEquals([moves count], (unsigned)59, @"expected number of moves for black");

    [state undoTransformWithMove:move];

    /* dirty, dirty test (make go away) */
    STAssertEquals(state->board[4][6], (int)(White | Circle), nil);
    STAssertEquals(state->board[3][6], (int)Empty, nil);

    moves = [state movesAvailable];
    STAssertEquals([moves count], (unsigned)61, @"expected number of moves again");
}


- (void)testDraw
{
    for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
            if (state->board[i][j] == Empty)
                state->board[i][j] = Dirty;
        }
    }
    STAssertEquals([state endStateScore], (double)0.0, nil);
    
    /* Verify draw state */
    ab = [SBAlphaBeta newWithState:state];
    STAssertEquals([ab winner], (unsigned)0, nil);
}

- (void)testLose
{
    [self testDraw];
    ab = [SBAlphaBeta newWithState:state];

    STAssertEquals([ab playerTurn], (unsigned)1, nil);
    state->board[0][6] = Empty;
    STAssertEquals([state endStateScore], (double)-1.0, nil);
    STAssertEquals([ab winner], (unsigned)2, nil);
}

- (void)testWin
{
    [self testDraw];
    ab = [SBAlphaBeta newWithState:state];

    STAssertEquals([ab playerTurn], (unsigned)1, nil);
    state->board[5][6] = Empty;
    state->board[6][6] = Empty;
    [ab applyMoveFromSearchWithInterval:0.3];
    STAssertEquals([state endStateScore], (double)-1.0, nil);
    STAssertEquals([ab winner], (unsigned)1, nil);
}

@end
