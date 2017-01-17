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
@property (weak, nonatomic) IBOutlet UILabel *dateString;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UITextView *contentField;
@property (weak, nonatomic) IBOutlet UIView *backgroundHilight;
@property (weak, nonatomic) IBOutlet UIView *hilightColoring;
@property (nonatomic) long identifier;
@property (nonatomic) long replyTo;
@property (nonatomic) BOOL alreadySetup;

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

- (void)prepareForReuse {
    self.dateString.text = @"";
    self.author.text = @"";
    [self.contentField setText:@""];
    self.avatarImage.image = nil;
    self.identifier = 0;
    self.replyTo = 0;
    self.backgroundHilight.hidden = YES;
    self.hilightColoring.hidden = YES;
    self.alreadySetup = NO;
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
    
    // Save off the width so we don't change it and screw up calculations when the cell is reused
    CGFloat contentWidth = self.contentField.bounds.size.width;
    // And finally figure out how far from the bottom of the contentField to the cell bottom, which came from the storyboard
    // or has been preserved for us. We need to do this to keep heights correct and consistent.
    CGFloat bottomBorder = self.bounds.size.height - (self.contentField.frame.origin.y + self.contentField.frame.size.height);
    
    NSMutableAttributedString *attribContent = [[NSMutableAttributedString alloc]
                                                initWithString:cellData[@"content"]
                                                attributes:@{NSFontAttributeName:self.contentField.font}];
           //     NSForegroundColorAttributeName:self.contentField.textColor}]; // IF we had a textColor defined use this. But nil is bad
    [self.contentField setText:cellData[@"content"]];   // Well that was easy, wasn't it?
    // Except I want to find all the @name formats and format them. I'd rather use an NSFormatter but that will take longer
    NSArray *rangeRuns = [self runsOfNames:cellData[@"content"]];
    if (rangeRuns.count > 0) {
        self.contentField.attributedText = [self setupNameRuns:rangeRuns forString:attribContent];
    }
    
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
    
    
    NSString *avatarUrl = cellData[@"avatar"];
    if (avatarUrl) {
        // This should be setup on a background thread (more reasonably in a block) to prevent stalls, then have the cell
        // updated on the main thread.
        self.avatarImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrl]]];
    }
    
    self.alreadySetup = YES;
}

- (BOOL)previouslySetup {
    return self.alreadySetup;
}

- (CGFloat)contentHeight {
    return self.bounds.size.height;
}

- (void)dimCell {
    self.alpha = 0.3f;
    self.hilightColoring.hidden = YES;
    self.backgroundHilight.hidden = YES;
}

- (void)hilightCell {
    self.alpha = 1.0f;
    self.hilightColoring.hidden = NO;
    self.backgroundHilight.hidden = NO;
}

- (void)normalizeCell {
    self.alpha = 1.0f;
    self.hilightColoring.hidden = YES;
    self.backgroundHilight.hidden = YES;
}

- (NSArray*)runsOfNames:(NSString*)theContent {
    NSMutableArray *runsArray = [NSMutableArray arrayWithCapacity:10];  // Default to 10 slots, probably will never have that many
    // Build the search sets. Our first character is always @.
    // We will then scan until we find the firest character in the exclusion set, which is the inverted set of alphanumerics, @, and _
    NSCharacterSet *atSet = [NSCharacterSet characterSetWithCharactersInString:@"@"];
    NSMutableCharacterSet *nameExclusionSet = [NSMutableCharacterSet alphanumericCharacterSet];
    [nameExclusionSet addCharactersInString:@"@_"]; // Not sure what other characters belong in this set. Need name spec for real product
    [nameExclusionSet invert];
    
    NSRange searchRange = NSMakeRange(0, theContent.length);    // Search the whole string
    while (searchRange.length > 1) {                            // And search until our range is too short for a name
        NSRange atRange = [theContent rangeOfCharacterFromSet:atSet options:NSLiteralSearch range:searchRange];
        if (atRange.location == NSNotFound) {
            break;  // Didn't find any left in the string, bail out
        }
        NSRange nameSearchRange = NSMakeRange(atRange.location+1, theContent.length - atRange.location - 1);
        NSRange nameRange = [theContent rangeOfCharacterFromSet:nameExclusionSet options:NSLiteralSearch range:nameSearchRange];
        if ((nameRange.location == NSNotFound) || (nameRange.location > searchRange.location+1)) {
            // Found  a string. Now extract the length
            if (nameRange.location == NSNotFound) {
                // The name went ot the end of the string
                nameRange.location = theContent.length; // Fake the end point to make the next line easier
            }
            // OK, I have a valid range now that will be hightlighted later, from the start of atRange until the first non-name character
            NSRange targetRange = NSMakeRange(atRange.location, nameRange.location - atRange.location);
            [runsArray addObject:NSStringFromRange(targetRange)];
            // Fix up the search range now to jump over what we just marked
            searchRange.location = targetRange.location + targetRange.length;
            searchRange.length = (theContent.length - searchRange.location);
        } else {
            // We didn't find the @ or have enough space for a legit name. leave the search
            break;
        }
    }
    return runsArray;
}

- (NSAttributedString*)setupNameRuns:(NSArray*)rangeRuns forString:(NSMutableAttributedString*)theString {
    
    NSDictionary *colorTextDict = @{NSForegroundColorAttributeName:[UIColor colorWithRed:32.0f/255.0f green:128.0f/255.0f blue:64.0f/255.0f alpha:1.0f]};
                                                                
    for (NSString* rangeString in rangeRuns) {
        [theString addAttributes:colorTextDict range:NSRangeFromString(rangeString)];
    }
    return theString;
}

@end
