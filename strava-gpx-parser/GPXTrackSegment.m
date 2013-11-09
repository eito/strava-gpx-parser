//
//  GPXTrackSegment.m
//  strava-gpx-parser
//
//  Created by Eric Ito on 11/8/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import "GPXTrackSegment.h"


@implementation GPXTrackSegment {
    NSMutableArray* _trackpoints;
}

-(id)init {
    self = [super init];
    if (self) {
        _trackpoints = [@[] mutableCopy];
    }
    return self;
}

-(void)addTrackpoint:(GPXTrackpoint *)trackpoint {
    [_trackpoints addObject:trackpoint];
}

-(NSArray *)trackpoints {
    return _trackpoints;
}

@end
