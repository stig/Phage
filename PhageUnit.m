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
    STAssertEquals(((PhageState*)state)->board[4][6], (int)Dirty, nil);
    STAssertEquals(((PhageState*)state)->board[3][6], (int)(White | Circle), nil);
    
    moves = [state movesAvailable];
    STAssertEquals([moves count], (unsigned)59, @"expected number of moves for black");

    [state undoTransformWithMove:move];

    /* dirty, dirty test (make go away) */
    STAssertEquals(((PhageState*)state)->board[4][6], (int)(White | Circle), nil);
    STAssertEquals(((PhageState*)state)->board[3][6], (int)Empty, nil);

    moves = [state movesAvailable];
    STAssertEquals([moves count], (unsigned)61, @"expected number of moves again");

    [state release];
}

@end
