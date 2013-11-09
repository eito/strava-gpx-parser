//
//  GPXTrackpoint.h
//  strava-gpx-parser
//
//  Created by Eric Ito on 11/8/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GPXTrackpoint : NSObject

/*
 <trkpt lat="34.1708710" lon="-116.8297050">
 <ele>1908.6</ele>
 <time>2013-11-02T15:34:47Z</time>
 </trkpt>
 */

@property (nonatomic, strong, readonly) CLLocation *location;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double elevation;
@property (nonatomic, strong) NSDate *time;

@end
