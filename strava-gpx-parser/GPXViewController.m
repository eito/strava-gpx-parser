//
//  GPXViewController.m
//  strava-gpx-parser
//
//  Created by Eric Ito on 11/8/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import "GPXViewController.h"
#import "GPXTrack.h"
#import "GPXTrackpoint.h"
#import "GPXTrackSegment.h"

@interface GPXViewController ()<NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSURL*            gpxURL;
@property (nonatomic, strong) NSInputStream*    inputStream;
@property (nonatomic, strong) NSXMLParser*      gpxParser;
@property (nonatomic, strong) NSMutableArray*   tracks;
@property (nonatomic, strong) UITableView*      tableView;
@end

@implementation GPXViewController {
    GPXTrack*           _currentTrack;
    GPXTrackpoint*      _currentTrackpoint;
    GPXTrackSegment*    _currentSegment;
    
    NSString*           _currentElementName;
    NSDateFormatter*    _dateFormatter;
}

- (id)initWithGPXURL:(NSURL*)gpxURL {
    self = [super init];
    if (self) {
        self.gpxURL = gpxURL;
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tracks = [@[] mutableCopy];
        self.title = [gpxURL lastPathComponent];
        [self.view addSubview:self.tableView];
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        //2013-11-02T15:34:49Z
        //@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"
        [_dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        
        //
        // kickoff parser in background
        dispatch_async(EAIGetBGQueue, ^{
            self.inputStream = [[NSInputStream alloc] initWithURL:self.gpxURL];
            [self.inputStream open];
            self.gpxParser = [[NSXMLParser alloc] initWithStream:self.inputStream];
            self.gpxParser.delegate = self;
            [self.gpxParser parse];
        });
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark NSXMLParserDelegate

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //
    // ending a new track
    if ([elementName isEqualToString:@"trk"]) {
        [self.tracks addObject:_currentTrack];
        _currentTrack = nil;
    }
    //
    // ending a new name
    else if ([elementName isEqualToString:@"name"]) {
        
    }
    //
    // ending a new segment
    else if ([elementName isEqualToString:@"trkseg"]) {
        [_currentTrack addTrackSegment:_currentSegment];
        _currentSegment = nil;
    }
    //
    // ending a new trackpoint
    else if ([elementName isEqualToString:@"trkpt"]) {
        [_currentSegment addTrackpoint:_currentTrackpoint];
        _currentTrackpoint = nil;
    }
    
    _currentElementName = nil;
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    //
    // starting a new track
    if ([elementName isEqualToString:@"trk"]) {
        _currentTrack = [[GPXTrack alloc] init];
    }
    //
    // starting a new name
    else if ([elementName isEqualToString:@"name"]) {
        
    }
    //
    // starting a new segment
    else if ([elementName isEqualToString:@"trkseg"]) {
        _currentSegment = [[GPXTrackSegment alloc] init];
    }
    //
    // starting a new trackpoint
    else if ([elementName isEqualToString:@"trkpt"]) {
        _currentTrackpoint = [[GPXTrackpoint alloc] init];
        double lat = [attributeDict[@"lat"] doubleValue];
        double lng = [attributeDict[@"lon"] doubleValue];
        _currentTrackpoint.latitude = lat;
        _currentTrackpoint.longitude = lng;
    }
    else if ([elementName isEqualToString:@"ele"]) {
        // not needed
    }
    else if ([elementName isEqualToString:@"time"]) {
        // not needed
    }
    
    _currentElementName = elementName;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if ([_currentElementName isEqualToString:@"ele"]) {
        _currentTrackpoint.elevation = [string doubleValue];
    }
    else if ([_currentElementName isEqualToString:@"time"]) {
        //
        // we need to get an NSDate from this string
        // 2013-11-02T15:34:49Z
        _currentTrackpoint.time = [_dateFormatter dateFromString:string];
    }
    else if ([_currentElementName isEqualToString:@"name"]) {
        _currentTrack.name = string;
    }
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Parser Error: %@", parseError);
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    [self.inputStream close];
    dispatch_async(EAIGetMainQueue, ^{
        [self.tableView reloadData];
    });

}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tracks.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *gpxcellid = @"gpxcellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:gpxcellid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:gpxcellid];
    }
    
    GPXTrack *track = self.tracks[indexPath.section];
    GPXTrackSegment *segment = [track segments][0];
    GPXTrackpoint *tp = segment.trackpoints[indexPath.row];
    GPXTrackpoint *lastTrackpoint = nil;
    
    if (indexPath.row > 0) {
        lastTrackpoint = segment.trackpoints[indexPath.row - 1];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Lat: %f Lng: %f", tp.latitude, tp.longitude];
    double distance = [lastTrackpoint.location distanceFromLocation:tp.location];
    double seconds = 0;
    if (lastTrackpoint) {
        seconds = [tp.time timeIntervalSince1970] - [lastTrackpoint.time timeIntervalSince1970];
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.2fm   Secs: %.2fs   Elev: %.2fm", distance, seconds, tp.elevation];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    GPXTrack *track = self.tracks[section];
    GPXTrackSegment *segment = [track segments][0];
    return segment.trackpoints.count;
}
@end
