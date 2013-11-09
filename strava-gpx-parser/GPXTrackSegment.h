//
//  GPXTrackSegment.h
//  strava-gpx-parser
//
//  Created by Eric Ito on 11/8/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPXTrackpoint;

@interface GPXTrackSegment : NSObject

@property (nonatomic, copy) NSArray *trackpoints;

- (void)addTrackpoint:(GPXTrackpoint*)trackpoint;

@end
