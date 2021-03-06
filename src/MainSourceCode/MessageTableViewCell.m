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
        bubbleView.textView = [[UITextView alloc] initWithFrame:CGRectZero];
        
        bubbleView.textView.editable = NO;
        bubbleView.textView.dataDetectorTypes = UIDataDetectorTypeAll;
        
        bubbleView.profileImage = [[UIImageView alloc] initWithFrame:CGRectZero];
       
        [bubbleView addSubview:bubbleView.textView];
        [bubbleView addSubview:bubbleView.profileImage];
        
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
//        senderName = NSLocalizedString(@"You", nil);
        senderName = [message.sender uppercaseString];
        point.x = self.bounds.size.width - message.bubbleSize.width;
        label.textAlignment = NSTextAlignmentRight; //Compatibility
    }
    else {
        bubbleType = BubbleTypeLefthand;
        senderName = [message.sender uppercaseString];
        label.textAlignment = NSTextAlignmentLeft; //Compatibility
    }

    // Resize the bubble view and tell it to display the message text
//    NSLog(@"Inserting Text %@ with the Sender %@ and Date %@", message.textChat, message.sender, message.dateAdded);
    CGRect rect;
    rect.origin = point;
    rect.size = [SpeechBubbleView sizeForText:message.textChat];
    CGRect bubbleRect = rect;

//    bubbleRect.size.height = 85;
    
//    bubbleView.frame = bubbleRect;

    
//    bubbleView.backgroundColor = [UIColor redColor];


    NSString *tmpStr = [message.textChat stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
    
    [bubbleView setText:tmpStr bubbleType:bubbleType];
    
    if (bubbleType == BubbleTypeLefthand) {
        bubbleView.frame = CGRectMake(0, 0, bubbleRect.size.width - 30, bubbleRect.size.height);
        bubbleView.profileImage.frame = CGRectMake(0, rect.size.height - 35, 30, 30) ;
        bubbleView.textView.frame = rect;
        bubbleView.profileImage.image = [UIImage imageNamed:@"ic_profile_normal"];
    }
    else if (bubbleType == BubbleTypeRighthand) {
        bubbleView.frame = CGRectMake(bubbleRect.origin.x - 30, bubbleRect.origin.y, bubbleRect.size.width, bubbleRect.size.height);
        bubbleView.profileImage.frame = CGRectMake(bubbleRect.size.width, rect.size.height - 35, 30, 30) ;
//        bubbleView.textView.frame = rect;
        bubbleView.textView.frame = CGRectMake(rect.origin.x - 30, rect.origin.y, bubbleRect.size.width - 30 , rect.size.height);
        bubbleView.profileImage.image = [UIImage imageNamed:@"User"];
    }

    // Format the message date
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDoesRelativeDateFormatting:YES];
    }
    
//    NSString *dateString = [formatter stringFromDate:message.dateAdded];

    // Set the sender's name and date on the label
    NSString *pointString = [NSString stringWithFormat:@"Point 90"];
    label.text = [NSString stringWithFormat:@"%@ %@", senderName, pointString];

//    label.text = [NSString stringWithFormat:@"%@ @ %@", senderName, dateString];
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
