//
//  TimelineViewController.h
//  OpenTweetObjC
//
//  Created by Shane Looker on 1/16/17.
//  Copyright © 2017 OpenTable, Inc. All rights reserved.
//

#import "MainTweetCellTableViewCell.h"
#import "TimelineViewController.h"

@interface TimelineViewController ()
@property (strong, nonatomic) NSArray *timelineTweets;
@property (strong, nonatomic) NSMutableDictionary *heightLookups;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *pathString = [[NSBundle mainBundle] resourcePath];
    NSData *theTweetData = [[NSData alloc] initWithContentsOfFile:[pathString stringByAppendingPathComponent:@"timeline.json"]];
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:theTweetData options:0 error:&error];
    
    NSLog(@"%@", jsonDict);
    self.timelineTweets = jsonDict[@"timeline"];
    
    self.heightLookups = [NSMutableDictionary dictionaryWithCapacity:self.timelineTweets.count];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.tableView reloadData];
}

#pragma mark - TableView Data Source
- (NSInteger) numberOfSectionsInTableView:(UITableView*)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return self.timelineTweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainTweetCellTableViewCell *aCell = (MainTweetCellTableViewCell*) [tableView dequeueReusableCellWithIdentifier:@"mainTweetCell"];
    if ([aCell previouslySetup] == NO) {
        [aCell setupFromDict:self.timelineTweets[indexPath.row]];
    }
    self.heightLookups[@(indexPath.row)] = @([aCell contentHeight]);
    return aCell;
}

#pragma mark - TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"estimateHeight %d", (int)indexPath.row);

    return 68.0f;   // Just a guestimate for placeholding. May just remove this method.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Since heightForRowAtIndexPath is called after the cell has been created and set up, we can ask for the
    // actual height of the cell.
    return [self.heightLookups[@(indexPath.row)] floatValue];
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *cellArray = [tableView visibleCells];

    MainTweetCellTableViewCell *aCell = (MainTweetCellTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    if (aCell.selected) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        for (MainTweetCellTableViewCell *workCell in cellArray) {
            [workCell normalizeCell];
        }
        return nil;
    } else {
        // Cell wasn't selected before. Dim all the other cells
        NSArray *cellArray = [tableView visibleCells];
        for (MainTweetCellTableViewCell *workCell in cellArray) {
            if (workCell != aCell) {
                [workCell dimCell];
            } else {
                [workCell hilightCell];
            }
        }
    }
    return indexPath;
}

- (void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath*)indexPath {
    NSLog(@"deselected");
}

@end
