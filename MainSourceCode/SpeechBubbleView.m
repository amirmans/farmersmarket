#import "SpeechBubbleView.h"

static UIFont *font = nil;
static NSMutableParagraphStyle *paragraphStyle = nil;
static NSDictionary *attributes = nil;


static UIImage *lefthandImage = nil;
static UIImage *righthandImage = nil;
static UIImage *centerImage = nil;

const CGFloat VertPadding = 4;       // additional padding around the edges
const CGFloat HorzPadding = 4;

const CGFloat TextLeftMargin = 17;   // insets for the text
const CGFloat TextRightMargin = 15;
const CGFloat TextTopMargin = 10;
const CGFloat TextBottomMargin = 11;


const CGFloat MinBubbleWidth = 50;   // minimum width of the bubble
const CGFloat MinBubbleHeight = 40;  // minimum height of the bubble

const CGFloat WrapWidth = 200;       // maximum width of text in the bubble

@interface SpeechBubbleView() {
    
}

+(CGSize)text:(NSString*)myText sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size;

@end


@implementation SpeechBubbleView

+ (void)initialize {
    if (self == [SpeechBubbleView class]) {
        font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        attributes = @{NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle};

    }
}

+(CGSize)text:(NSString*)myText sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          font, NSFontAttributeName,
                                          NSParagraphStyleAttributeName, paragraphStyle,
                                          nil];
    
    CGRect frame = [myText boundingRectWithSize:size
                                        options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                     attributes:attributesDictionary
                                        context:nil];
    
    return frame.size;
}


+ (CGSize)sizeForText:(NSString *)text {
    CGSize textSize = [SpeechBubbleView text:text sizeWithFont:font
                             constrainedToSize:CGSizeMake(WrapWidth, 9999)
                    ];
    
    CGSize bubbleSize;
    bubbleSize.width = textSize.width + TextLeftMargin + TextRightMargin;
    bubbleSize.height = textSize.height + TextTopMargin + TextBottomMargin;

    if (bubbleSize.width < MinBubbleWidth)
        bubbleSize.width = MinBubbleWidth;

    if (bubbleSize.height < MinBubbleHeight)
        bubbleSize.height = MinBubbleHeight;

    bubbleSize.width += HorzPadding * 2;
    bubbleSize.height += VertPadding * 2;

    return bubbleSize;
}

- (void)drawRect:(CGRect)rect {
    [self.backgroundColor setFill];
    UIRectFill(rect);

    CGRect bubbleRect = CGRectInset(self.bounds, VertPadding, HorzPadding);

    CGRect textRect;
    textRect.origin.y = bubbleRect.origin.y + TextTopMargin;
    textRect.size.width = bubbleRect.size.width - TextLeftMargin - TextRightMargin;
    textRect.size.height = bubbleRect.size.height - TextTopMargin - TextBottomMargin;

    if (bubbleType == BubbleTypeLefthand) {
        
        if (lefthandImage == nil) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *path = [bundle pathForResource:@"BubbleLefthand" ofType:@"png"];
            lefthandImage = [[UIImage imageWithContentsOfFile:path]
                stretchableImageWithLeftCapWidth:20 topCapHeight:19];
        }
        
        [lefthandImage drawInRect:bubbleRect];
        textRect.origin.x = bubbleRect.origin.x + TextLeftMargin;
    }
    else if (bubbleType == BubbleTypeRighthand) {
        
        if (righthandImage == nil) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *path = [bundle pathForResource:@"BubbleRighthand" ofType:@"png"];
            righthandImage = [[UIImage imageWithContentsOfFile:path]
                stretchableImageWithLeftCapWidth:20 topCapHeight:19];
        }
        [righthandImage drawInRect:bubbleRect];

        textRect.origin.x = bubbleRect.origin.x + TextRightMargin;
    }
    else {
        if (centerImage == nil) {
            NSBundle *bundle = [NSBundle mainBundle];
            NSString *path = [bundle pathForResource:@"BubbleCenter" ofType:@"png"];
            centerImage = [[UIImage imageWithContentsOfFile:path]
                                   stretchableImageWithLeftCapWidth:20 topCapHeight:19];
        }
        [centerImage drawInRect:bubbleRect];
        
        textRect.origin.x = bubbleRect.origin.x+TextLeftMargin;
    }
    
    [text drawInRect:textRect withAttributes:attributes];
}

- (void)setText:(NSString *)newText bubbleType:(BubbleType)newBubbleType {
    text = [newText copy];
    bubbleType = newBubbleType;
    [self setNeedsDisplay];
}

//- (void)dealloc
//{
//	[text release];
//	[super dealloc];
//}

@end
