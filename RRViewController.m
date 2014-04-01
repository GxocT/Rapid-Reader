//
// RRViewController.m
// Rapid Reader
//
// Copyright (c) 2014 Yuri Petukhov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RRViewController.h"
#import "RRTargetView.h"

#define MIN_FONT_SIZE 16
#define MAX_FONT_SIZE 100
#define DEFAULT_FONT_SIZE 24

#define MIN_SPEED 60

@interface RRViewController ()

@property (nonatomic) NSUInteger wordsPerMinute;

// Font settings
@property (nonatomic) UIFont *font;
@property (nonatomic) CGFloat fontSize;

@property (nonatomic) UIColor *mainFontColor;
@property (nonatomic) UIColor *mainLetterColor;

@property (nonatomic, weak) NSTimer *wordTimer;

@property (nonatomic) NSString *textToShow;

// View with target to draw text
@property (weak, nonatomic) IBOutlet RRTargetView *targetView;

@end

@implementation RRViewController

@synthesize autoTextSize = _autoTextSize;
@synthesize wordsPerMinute = _wordsPerMinute;
@synthesize fontSize = _fontSize;

#pragma mark - Init methods
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"RRViewController" owner:self options:nil] objectAtIndex:0];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"RRViewController" owner:self options:nil] objectAtIndex:0];
    }
    return self;
}

#pragma mark - View Controller Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Read user settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.wordsPerMinute = [[defaults valueForKey:@"WORDS_PER_MINUTE"] integerValue];
    self.fontSize = [[defaults valueForKey:@"FONT_SIZE"] floatValue];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.dataSource) {
        self.textToShow = [self.dataSource currentWord];
    }
    
    if (self.autoTextSize) {
        [self setFontSize:[self recomendedFontSize]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self pauseReading];
}

#pragma mark - Start/Pause reading
- (void)startReading
{
    if (self.dataSource && !self.wordTimer) {
        self.wordTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f / self.wordsPerMinute target:self selector:@selector(selectNextWord) userInfo:nil repeats:YES];
    }
}

- (void)selectNextWord
{
    self.textToShow = [self.dataSource nextWord];
}

- (void)pauseReading
{
    if (self.wordTimer) {
        [self.wordTimer invalidate];
    }
}

#pragma mark - Changing font and speed parametrs
- (void)changeSpeed:(int)speedModification
{
    self.wordsPerMinute += speedModification;
}

- (void)changeFont:(int)fontModification
{
    self.fontSize += fontModification;
}

#pragma mark - Making, painting and positioning label
- (void)positionAndPaintText
{
    if ([self.textToShow length]) {
        NSUInteger accentLetterPosition = [self calculateAccentLetterForWord:self.textToShow];
        
        CGFloat accentLetterCenter = [self centerAtPosition:accentLetterPosition forText:self.textToShow];
        
        CGSize textSize = [self sizeOfText:self.textToShow withFont:self.font];
        
        UILabel *textLabel = [UILabel new];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        
        NSAttributedString *paintedString = [self paintAccentLetter:accentLetterPosition inWord:self.textToShow withFont:self.font];
        [textLabel setAttributedText:paintedString];
        
        CGRect labelFrame = CGRectMake(0, 0, textSize.width, textSize.height);
        [textLabel setFrame:labelFrame];
        
        CGPoint accentPoint = CGPointMake(accentLetterCenter, textSize.height / 2);
        [self.targetView positionLabel:textLabel withAccentPoint:accentPoint];
    }
}

- (NSAttributedString *)paintAccentLetter:(NSUInteger)accentLetterPosition inWord:(NSString *)word withFont:(UIFont *)font
{
    NSDictionary *mainTextAttributes = @{NSForegroundColorAttributeName : self.mainFontColor,
                                         NSFontAttributeName : font,
                                         NSLigatureAttributeName : @(0)};
    
    NSDictionary *mainLetterAttributes = @{NSForegroundColorAttributeName : self.mainLetterColor,
                                           NSFontAttributeName : font,
                                           NSLigatureAttributeName : @(0)};
    
    NSRange range = NSMakeRange(accentLetterPosition, 1);
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:word attributes:mainTextAttributes];
    [attributedString setAttributes:mainLetterAttributes range:range];
    
    return attributedString;
}

#pragma mark - Font and word calculations
- (NSUInteger)calculateAccentLetterForWord:(NSString *)word
{
    return (([word length] + 6) / 4) - 1;
}

- (CGFloat)recomendedFontSize
{
    // Calculate recommended font size using length of the longest word
    if ([self.dataSource respondsToSelector:@selector(longestWordWithFont:)]) {
        NSString *longestWord = [self.dataSource longestWordWithFont:self.font];
        
        UIFont *localFont;
        NSUInteger accentLetterPosition = [self calculateAccentLetterForWord:longestWord];
        CGFloat maxFrameWidth = self.targetView.frame.size.width;
        
        for (int fontSize = MAX_FONT_SIZE; fontSize >= MIN_FONT_SIZE; fontSize -= 4) {
            localFont = [UIFont systemFontOfSize:fontSize];

            CGFloat accentLetterCenter = [self centerAtPosition:accentLetterPosition forText:self.textToShow];
            CGSize textSize = [self sizeOfText:self.textToShow withFont:self.font];
            
            if ((((maxFrameWidth * self.targetView.horizontalAccentPosition) > accentLetterCenter) &&
                 ((maxFrameWidth * (1 - self.targetView.horizontalAccentPosition)) > (textSize.width - accentLetterCenter))) ||
                fontSize <= MIN_FONT_SIZE) {
                // Label size is correct;
                return fontSize;
            }
        }
    }
    return DEFAULT_FONT_SIZE;
}

- (CGSize)sizeOfText:(NSString *)text withFont:(UIFont *)font
{
    if ([text respondsToSelector:@selector(sizeWithAttributes:)]) {
        return [self.textToShow sizeWithAttributes:@{NSFontAttributeName : self.font}];
    } else {
        return [self.textToShow sizeWithFont:self.font];
    }
}

- (CGFloat)centerAtPosition:(int)position forText:(NSString *)text
{
    CGFloat accentLetterCenter;
    // Counting accent letter center position
    for (int i = 0; i <= position; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *nextLetter = [self.textToShow substringWithRange:range];
        if (i == position) {
            if ([text respondsToSelector:@selector(sizeWithAttributes:)]) {
                accentLetterCenter += [nextLetter sizeWithAttributes:@{NSFontAttributeName : self.font}].width / 2;
            } else {
                accentLetterCenter += [nextLetter sizeWithFont:self.font].width / 2;
            }
        } else {
            if ([text respondsToSelector:@selector(sizeWithAttributes:)]) {
                accentLetterCenter += [nextLetter sizeWithAttributes:@{NSFontAttributeName : self.font}].width;
            } else {
                accentLetterCenter += [nextLetter sizeWithFont:self.font].width;
            }
        }
    }
    return accentLetterCenter;
}

#pragma mark - Screen rotation
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.autoTextSize) {
        [self setFontSize:[self recomendedFontSize]];
    }
}

#pragma mark - Overriden setter and getters

- (void)setFontSize:(CGFloat)fontSize
{
    if (fontSize == 0) {
        fontSize = DEFAULT_FONT_SIZE;
    }
    
    if (fontSize < MIN_FONT_SIZE || fontSize > MAX_FONT_SIZE) {
        return;
    }
    
    _fontSize = fontSize;
    
    // Save to user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(fontSize) forKey:@"FONT_SIZE"];
    [defaults synchronize];
    
    if ([self.delegate respondsToSelector:@selector(reportFontSize:)]) {
        [self.delegate reportFontSize:fontSize];
    }
    
    // Set font to nil, to get new one with changed size;
    _font = nil;
    
    // Change label with new font size immediately
    [self positionAndPaintText];
}

- (UIFont *)font
{
    if (!_font) {
        _font = [UIFont systemFontOfSize:self.fontSize];
    }
    return _font;
}

- (UIColor *)mainFontColor
{
    if (!_mainFontColor) {
        _mainFontColor = [UIColor blackColor];
    }
    return _mainFontColor;
}

- (UIColor *)mainLetterColor
{
    if (!_mainLetterColor) {
        _mainLetterColor = [UIColor redColor];
    }
    return _mainLetterColor;
}

- (void)setWordsPerMinute:(NSUInteger)wordsPerMinute
{
    if (wordsPerMinute == 0) {
        wordsPerMinute = MIN_SPEED;
    }
    if (wordsPerMinute < MIN_SPEED) {
        return;
    }
    
    _wordsPerMinute = wordsPerMinute;
    
    // Save to user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@(wordsPerMinute) forKey:@"WORDS_PER_MINUTE"];
    [defaults synchronize];
    
    if ([self.delegate respondsToSelector:@selector(reportReadingSpeed:)]) {
        [self.delegate reportReadingSpeed:wordsPerMinute];
    }
}

- (void)setTextToShow:(NSString *)textToShow
{
    _textToShow = textToShow;
    [self positionAndPaintText];
}

- (void)setAutoTextSize:(BOOL)autoTextSize
{
    _autoTextSize = autoTextSize;
    // Save to user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:autoTextSize forKey:@"AUTO_TEXT_SIZE"];
    [defaults synchronize];
}

- (BOOL)autoTextSize
{
    if (!_autoTextSize) {
        _autoTextSize = [[NSUserDefaults standardUserDefaults] boolForKey:@"AUTO_TEXT_SIZE"];
    }
    return _autoTextSize;
}

@end
