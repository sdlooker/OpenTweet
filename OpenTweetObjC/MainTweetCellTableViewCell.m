//
//  MainTweetCellTableViewCell.m
//  OpenTweet
//
//  Created by Shane Looker on 1/16/17.
//  Copyright © 2017 OpenTable, Inc. All rights reserved.
//

#import "MainTweetCellTableViewCell.h"

@interface MainTweetCellTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *dateString;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UITextView *contentField;
@property (nonatomic) long identifier;
@property (nonatomic) long replyTo;
//@property (nonatomic) CGFloat contentHeight;

@end

@implementation MainTweetCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupFromDict:(NSDictionary*)cellData {
    self.author.text = cellData[@"author"];

    NSISO8601DateFormatter *formatter = [[NSISO8601DateFormatter alloc] init];
    NSDate *aDate = [formatter dateFromString:cellData[@"date"]];
    
    NSDateFormatter *outFormatter = [[NSDateFormatter alloc] init];
    [outFormatter setDateStyle:NSDateFormatterShortStyle];
    [outFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.dateString.text = [outFormatter stringFromDate:aDate];
    

    // Now to do the dance of the content height. An ancient dance of
    // manipulation that makes no sense to the unititiated.
    // Note: contentField is the UITextField to hold the actual content
    
    // Get the size of the current raw field (or its last value)
    CGSize contentSize = self.contentField.contentSize;
    // Save off the width so we don't change it and screw up calculations when the cell is reused
    CGFloat contentWidth = self.contentField.bounds.size.width;
    // And finally figure out how far from the bottom of the contentField to the cell bottom, which came from the storyboard
    // or has been preserved for us. We need to do this to keep heights correct and consistent.
    CGFloat bottomBorder = self.bounds.size.height - (self.contentField.frame.origin.y + self.contentField.frame.size.height);
    
    [self.contentField setText:cellData[@"content"]];   // Well that was easy, wasn't it?
    // And now find out what the correct minimal size for the text is.
    CGSize newSize = [self.contentField sizeThatFits:CGSizeMake(contentWidth, MAXFLOAT)];
    // We are going to build a new frame for the content so all the content will show
    CGRect newFrame = self.contentField.frame;
    newFrame.size.height = newSize.height;  // update only the height
    newSize.height += bottomBorder;         // Keep the bottom border height consistent
    // Calculate what the change in total cell height is going to be based on the new
    // content height and the old content height.
    CGFloat deltaContent = ceilf(newSize.height - self.contentField.bounds.size.height);
    self.contentField.frame = newFrame;     // And update the contentField size in the cell
    
    // Now take the current cell bounds, apply the deltaContent size we just computed above, adn slap that back into
    // make a variable height cell.
    CGRect cellRect = self.bounds;
    cellRect.size.height += deltaContent;
    self.bounds = cellRect;
    
    
 //  NSTimeZone *ltz = [NSTimeZone localTimeZone];
 //  self.dateString.text = [NSISO8601DateFormatter stringFromDate:aDate timeZone:ltz formatOptions:NSISO8601DateFormatWithYear | NSISO8601DateFormatWithMonth | NSISO8601DateFormatWithDay | NSISO8601DateFormatWithTime | NSISO8601DateFormatWithDashSeparatorInDate |NSISO8601DateFormatWithSpaceBetweenDateAndTime | NSISO8601DateFormatWithColonSeparatorInTime | NSISO8601DateFormatWithTime];
    
    NSString *avatarUrl = cellData[@"avatar"];
    if (avatarUrl) {
        // This should be setup on a background thread (more reasonably in a block) to prevent stalls, then have the cell
        // updated on the main thread.
        self.avatarImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrl]]];
    }
}

- (CGFloat)contentHeight {
    return self.bounds.size.height;
}

@end
