//
// RRTargetView.m
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

#import "RRTargetView.h"

@interface RRTargetView()

@property (nonatomic) UILabel *textLabel;
@property (nonatomic) CGPoint accentPoint;
@property (nonatomic) CGFloat targetLineWidth;

@end

@implementation RRTargetView

- (void)positionLabel:(UILabel *)label withAccentPoint:(CGPoint)point
{
    if (self.textLabel) {
        [self.textLabel removeFromSuperview];
    }
    self.textLabel = label;
    self.accentPoint = point;
    
    // Position label in target
    CGRect labelFrame = label.frame;
    labelFrame.origin.x = self.bounds.size.width * self.horizontalAccentPosition - point.x;
    labelFrame.origin.y = self.bounds.size.height / 2 - point.y;
    label.frame = labelFrame;
    
    [self addSubview:label];
}

- (void)drawRect:(CGRect)rect
{
    // Draw target in view
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, self.targetLineWidth);
    
    // Draw horizontal lines
    CGContextMoveToPoint(context, 0, self.targetLineWidth);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.targetLineWidth);
    
    CGContextMoveToPoint(context, 0, self.bounds.size.height - self.targetLineWidth);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height - self.targetLineWidth);
    
    // Draw vertical (accent) lines
    CGContextMoveToPoint(context, self.bounds.size.width * self.horizontalAccentPosition, self.targetLineWidth);
    CGContextAddLineToPoint(context, self.bounds.size.width * self.horizontalAccentPosition, self.bounds.size.height * 0.15);

    CGContextMoveToPoint(context, self.bounds.size.width * self.horizontalAccentPosition, self.bounds.size.height - self.targetLineWidth);
    CGContextAddLineToPoint(context, self.bounds.size.width * self.horizontalAccentPosition, self.bounds.size.height * 0.85);
    
    CGContextStrokePath(context);
    
    [self positionLabel:self.textLabel withAccentPoint:self.accentPoint];
}

- (CGFloat)horizontalAccentPosition
{
    if (!_horizontalAccentPosition) {
        _horizontalAccentPosition = 1.0 / 3;
    }
    return _horizontalAccentPosition;
}

- (CGFloat)targetLineWidth
{
    if (!_targetLineWidth) {
        _targetLineWidth = 2.0;
    }
    return _targetLineWidth;
}

@end
