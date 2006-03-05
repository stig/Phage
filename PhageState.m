//
//  PhageState.m
//  Phage
//
//  Created by Stig Brautaset on 29/01/2006.
//  Copyright 2006 Stig Brautaset. All rights reserved.
//

#import "PhageState.h"


@implementation PhageState

- (id)init
{
    if (self = [super init]) {
        board[7][7] = BLACK * DIAMOND;
        board[6][5] = BLACK * TRIANGLE;
        board[5][3] = BLACK * SQUARE;
        board[4][1] = BLACK * CIRCLE;

        board[0][0] = WHITE * DIAMOND;
        board[1][2] = WHITE * TRIANGLE;
        board[2][5] = WHITE * SQUARE;
        board[3][6] = WHITE * CIRCLE;
        
        int i;
        for (i = 0; i < 4; i++) {
            moves[0][i] = moves[1][i] = 7;
        }
    }
    return self;
}

- (NSString *)string
{
    NSMutableString *st = [[NSMutableString new] autorelease];
    
    int i, j;
    for (i = 0; i < 8; i++) {
        for (j = 0; j < 8; j++) {
            NSString *s = @".";
            switch(abs(board[i][j])) {
                case DIAMOND:  s = @"d"; break;
                case TRIANGLE: s = @"t"; break;
                case SQUARE:   s = @"s"; break;
                case CIRCLE:   s = @"c"; break;
            }
            [st appendString: board[i][j] > 0 ? [s uppercaseString] : s];
        }
        [st appendFormat:@" "];
    }
    [st appendFormat:@"77777777"];
    return st;
}

@end
