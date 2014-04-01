//
// RRViewController.h
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

#import <UIKit/UIKit.h>
#import "RRViewControllerDataSource.h"
#import "RRViewControllerDelegate.h"

@interface RRViewController : UIViewController

@property (nonatomic, weak) id <RRViewControllerDataSource> dataSource;
@property (nonatomic, weak) id <RRViewControllerDelegate> delegate;

// Change property to turn on/off auto text sizing
// You should implement longestWordWithFont: method of ReadingViewControllerDataSource
@property (nonatomic) BOOL autoTextSize;

// Control reading process
- (void)startReading;
- (void)pauseReading;

// Use positive or negative values to change reading speed and font
- (void)changeSpeed:(int)speedModification;
- (void)changeFont:(int)fontModification;

@end