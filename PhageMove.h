//
//  PhageMove.h
//  Phage
//
//  Created by Stig Brautaset on 29/01/2006.
//  Copyright 2006 Stig Brautaset. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PhageMove : NSObject {
    unsigned row, col;
    int dRow, dCol;
}

-(unsigned)row;
-(unsigned)col;
-(int)dRow;
-(int)dCol;
@end
