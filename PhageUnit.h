//
//  PhageUnit.h
//  Phage
//
//  Created by Stig Brautaset on 02/03/2007.
//  Copyright 2007 Stig Brautaset. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <AlphaBeta/AlphaBeta.h>
#import <PhageState.h>


@interface PhageUnit : SenTestCase {
    PhageState *state;
    SBAlphaBeta *ab;
}

@end
