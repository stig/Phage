//
//  PhageStateUnit.m
//  Phage
//
//  Created by Stig Brautaset on 29/01/2006.
//  Copyright 2006 Stig Brautaset. All rights reserved.
//

#import "PhageStateUnit.h"

@implementation PhageStateUnit


- (void)setUp
{
    s = [[PhageState alloc] init];
}

- (void)tearDown
{
    [s release];
}

- (void)testMove
{
    PhageMove *m;
    
    STAssertNotNil(m = [PhageMove newWithRow:3 col:7 deltaRow:3 deltaCol:-1], nil);
    STAssertEquals([m col], (unsigned)7, nil);
    STAssertEquals([m row], (unsigned)3, nil);
    
//    STAssertThrows([PhageMove newWithCol:9], @"failed to throw exception for invalid move");
//    STAssertThrows([PhageMove newWithCol:-1], @"failed to throw exception for invalid move");
}


@end
