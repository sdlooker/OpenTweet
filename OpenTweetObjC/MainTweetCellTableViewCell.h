//
//  MainTweetCellTableViewCell.h
//  OpenTweet
//
//  Created by Shane Looker on 1/16/17.
//  Copyright © 2017 OpenTable, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTweetCellTableViewCell : UITableViewCell
- (void)setupFromDict:(NSDictionary*)cellData;
- (BOOL)previouslySetup;
- (CGFloat)contentHeight;

- (void)dimCell;
- (void)hilightCell;
- (void)normalizeCell;
@end
