//
//  GPXTrack.m
//  strava-gpx-parser
//
//  Created by Eric Ito on 11/8/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import "GPXTrack.h"

@implementation GPXTrack {
    NSMutableArray* _segments;
}

-(id)init {
    self = [super init];
    if (self) {
        _segments = [@[] mutableCopy];
    }
    return self;
}

-(void)addTrackSegment:(GPXTrackSegment *)trkseg {
    [_segments addObject:trkseg];
}

- (NSArray*)segments {
    return _segments;
}

@end
