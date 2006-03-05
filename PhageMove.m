//
//  PhageMove.m
//  Phage
//
//  Created by Stig Brautaset on 29/01/2006.
//  Copyright 2006 Stig Brautaset. All rights reserved.
//

#import "PhageMove.h"


@implementation PhageMove

-(id)init
{
    return [self initWithRow:0 col:0 deltaRow:0 deltaCol:0];
}

-(id)initWithRow:(unsigned)r col:(unsigned)c deltaRow:(int)dr deltaCol:(int)dc
{
    if (self = [super init]) {
        row = r;
        col = c;
        dRow = dr;
        dCol = dc;
    }
    return self;
}

+(id)newWithRow:(unsigned)r col:(unsigned)c deltaRow:(int)dr deltaCol:(int)dc
{
    return [[PhageMove alloc] initWithRow:r col:c deltaRow:dr deltaCol:dc];
}

-(unsigned)row
{
    return row;
}

-(unsigned)col
{
    return col;
}

-(int)dRow
{
    return dRow;
}

-(int)dCol
{
    return dCol;
}

@end
