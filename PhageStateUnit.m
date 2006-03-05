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
    
    STAssertNotNil(m = [PhageMove newWithCol:3 andRow:7], nil);
    STAssertEquals([m col], (unsigned)3, nil);
    STAssertEquals([m row], (unsigned)7, nil);
    
    STAssertThrows([PhageMove newWithCol:9], @"failed to throw exception for invalid move");
    STAssertThrows([PhageMove newWithCol:-1], @"failed to throw exception for invalid move");
}


@end
