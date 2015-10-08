#import "MessageTableViewCell.h"
#import "TapTalkChatMessage.h"
#import "SpeechBubbleView.h"

static UIColor *color = nil;
static NSDateFormatter *formatter = nil;

@implementation MessageTableViewCell

+ (void)initialize {
    if (self == [MessageTableViewCell class]) {
        color = [[UIColor colorWithRed:219 / 255.0 green:226 / 255.0 blue:237 / 255.0 alpha:1.0] retain];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        // Create the speech bubble view
        bubbleView = [[SpeechBubbleView alloc] initWithFrame:CGRectZero];
        bubbleView.backgroundColor = color;
        bubbleView.opaque = YES;
        bubbleView.clearsContextBeforeDrawing = NO;
        bubbleView.contentMode = UIViewContentModeRedraw;
        bubbleView.autoresizingMask = 0;
        [self.contentView addSubview:bubbleView];

        // Create the label
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = color;
        label.opaque = YES;
        label.clearsContextBeforeDrawing = NO;
        label.contentMode = UIViewContentModeRedraw;
        label.autoresizingMask = 0;
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor colorWithRed:64 / 255.0 green:64 / 255.0 blue:64 / 255.0 alpha:1.0];
        [self.contentView addSubview:label];
    }
    return self;
}

- (void)dealloc {
    [bubbleView release];
    [label release];
//    [formatter release];
    [super dealloc];
}

- (void)layoutSubviews {
    // This is a little trick to set the background color of a table view cell.
    [super layoutSubviews];
    self.backgroundColor = color;
}


// Remember TapTalkChatMessage:message is NOT key/value pair - it's an object with getter and setters and the date is actually NSDate 
- (void)insertMessage:(TapTalkChatMessage *)message forBusiness:(NSString *)bizName {
    CGPoint point = CGPointZero;

    // We display messages that are sent by the user on the right-hand side of
    // the screen. Incoming messages are displayed on the left-hand side.
    NSString *senderName;
    BubbleType bubbleType;
    //TODO
    message.bubbleSize = [SpeechBubbleView sizeForText:message.textChat];
    if ([message businessNameIfMessageSentByBusiness].length > 0) {
        bubbleType = BubbleTypeCenter;
        senderName = NSLocalizedString([message businessNameIfMessageSentByBusiness], nil);
        //TODO
        
        
        point.x = (self.bounds.size.width/3) - 10;
        label.textAlignment = NSTextAlignmentCenter; //Compatibility
    }
    else if ([message isSentByUser]) {
        bubbleType = BubbleTypeRighthand;
        senderName = NSLocalizedString(@"You", nil);
        point.x = self.bounds.size.width - message.bubbleSize.width;
        label.textAlignment = NSTextAlignmentRight; //Compatibility
    }
    else {
        bubbleType = BubbleTypeLefthand;
        senderName = message.sender;
        label.textAlignment = NSTextAlignmentLeft; //Compatibility
    }

    // Resize the bubble view and tell it to display the message text
//    NSLog(@"Inserting Text %@ with the Sender %@ and Date %@", message.textChat, message.sender, message.dateAdded);
    CGRect rect;
    rect.origin = point;
    rect.size = [SpeechBubbleView sizeForText:message.textChat];
    bubbleView.frame = rect;
    NSString *tmpStr = [message.textChat stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
    [bubbleView setText:tmpStr bubbleType:bubbleType];

    // Format the message date
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    }
    NSString *dateString = [formatter stringFromDate:message.dateAdded];

    // Set the sender's name and date on the label
    label.text = [NSString stringWithFormat:@"%@ @ %@", senderName, dateString];
    [label sizeToFit];

//    label.frame = CGRectMake(8, message.bubbleSize.height, self.contentView.bounds.size.width - 16, 16);
    if (bubbleType == BubbleTypeCenter) {
        label.frame = CGRectMake(40, message.bubbleSize.height-8, self.contentView.bounds.size.width - 16, 16);
    } else {
        label.frame = CGRectMake(5, message.bubbleSize.height-8, self.contentView.bounds.size.width - 16, 16);
    }
    
        
//    NSLog(@"chat massages %@ was rect.size.width was: %f, message.bubbleSize was: %f", tmpStr, rect.size.width, message.bubbleSize.width);
}

@end
