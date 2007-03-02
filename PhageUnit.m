//
//  PhageUnit.m
//  Phage
//
//  Created by Stig Brautaset on 02/03/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import "PhageUnit.h"


@implementation PhageUnit


- (void)testPhageState
{
    id state = [PhageState new];
    STAssertEquals([state player], (int)1, nil);
    STAssertEqualsWithAccuracy([state currentFitness], (float)0.0, 0.0, nil);

    id moves = [state movesAvailable];
    STAssertEquals([moves count], (unsigned)61, @"expected number of moves");

    /* test that first move is what we expect */
    id move = [moves objectAtIndex:0];
    STAssertEquals([move srcRow], (unsigned)4, nil);
    STAssertEquals([move srcCol], (unsigned)6, nil);
    STAssertEquals([move dstRow], (unsigned)3, nil);
    STAssertEquals([move dstCol], (unsigned)6, nil);

    STAssertNotNil([state applyMove:move], @"applying move gives us state back");
    STAssertEquals([state player], (int)2, nil);
    STAssertEqualsWithAccuracy([state currentFitness], (float)9.0, 0.00001, nil);

    /* dirty, dirty test (make go away) */
    STAssertEquals(((PhageState*)state)->board[4][6], (int)Dirty, nil);
    STAssertEquals(((PhageState*)state)->board[3][6], (int)(White | Circle), nil);

    moves = [state movesAvailable];
    STAssertEquals([moves count], (unsigned)59, @"expected number of moves for black");

    STAssertNotNil([state undoMove:move], @"undoing move gives us state back");
    STAssertEquals([state player], (int)1, nil);

    /* dirty, dirty test (make go away) */
    STAssertEquals(((PhageState*)state)->board[4][6], (int)(White | Circle), nil);
    STAssertEquals(((PhageState*)state)->board[3][6], (int)Empty, nil);

    moves = [state movesAvailable];
    STAssertEquals([moves count], (unsigned)61, @"expected number of moves again");

    [state release];
}

@end
