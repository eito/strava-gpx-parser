//
//  ViewController.m
//  strava-gpx-parser
//
//  Created by Eric Ito on 11/8/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import "ViewController.h"
#import "GPXViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tv;
@property (nonatomic, strong) NSMutableArray *gpxs;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Strava GPX Parser";
    
    self.tv = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tv.delegate = self;
    self.tv.dataSource = self;
    [self.view addSubview:self.tv];
    
    self.gpxs = [@[] mutableCopy];
    
    dispatch_async( EAIGetBGQueue, ^{
        //
        // enumerate all GPX files in Documents directory of application
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dirPath = paths[0];
        NSArray *filepaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
        for (NSString *path in filepaths) {
            if ([path hasSuffix:@".gpx"]) {
                NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", dirPath, path]];
                [self.gpxs addObject:url];
            }
        }
        
        //
        // sort our paths
        [self.gpxs sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSURL *url1 = (NSURL*)obj1;
            NSURL *url2 = (NSURL*)obj2;
            return [[url1 absoluteString] compare:[url2 absoluteString]] == NSOrderedAscending;
        }];
 
        //
        // call back on main thread
        dispatch_async(EAIGetMainQueue, ^{
            [self.tv reloadData];
        });
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"ID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSURL *gpxURL = self.gpxs[indexPath.row];
    cell.textLabel.text = [gpxURL lastPathComponent];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.gpxs.count;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *gpxURL = self.gpxs[indexPath.row];
    GPXViewController *gpxVC = [[GPXViewController alloc] initWithGPXURL:gpxURL];
    [self.navigationController pushViewController:gpxVC animated:YES];
}

@end
