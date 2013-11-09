//
//  GPXTrack.h
//  strava-gpx-parser
//
//  Created by Eric Ito on 11/8/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPXTrackSegment;

@interface GPXTrack : NSObject

@property (nonatomic, copy) NSString*   name;
@property (nonatomic, copy, readonly) NSArray*    segments;

-(void)addTrackSegment:(GPXTrackSegment*)trkseg;
@end
