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

#import "PhageMove.h"

@implementation PhageMove

- (id)initFromR:(int)r c:(int)c toR:(int)tr c:(int)tc
{
    self = [super init];
    if (self) {
        srcRow = r;
        srcCol = c;
        dstRow = tr;
        dstCol = tc;
    }
    return self;
}
- (id)init
{
    return [self initFromR:0 c:0 toR:0 c:0];
}

+ (id)moveFromR:(int)r c:(int)c toR:(int)tr c:(int)tc
{
    return [[self alloc] initFromR:r c:c toR:tr c:tc];
}


- (unsigned)srcRow { return srcRow; }
- (unsigned)srcCol { return srcCol; }
- (unsigned)dstRow { return dstRow; }
- (unsigned)dstCol { return dstCol; }

- (NSString *)description {
    return [NSString stringWithFormat:@"[%u,%u] to [%u,%u]", srcRow, srcCol, dstRow, dstCol];
}

@end
