/*
 Copyright 2017-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "CalendarCardExpansionExample.h"

#import "CalendarChipMotionSpec.h"

#import "MotionAnimator.h"

// This example demonstrates how to use a motion timing specification to build a complex
// bi-directional animation using the MDMMotionAnimator object. MDMMotionAnimator is designed for
// building fine-tuned explicit animations. Unlike UIView's implicit animation API, which can be
// used to cause cascading animations on a variety of properties, MDMMotionAnimator will always add
// exactly one animation per key path to the layer. This means you don't get as much for "free", but
// you do gain more control over the timing and motion of the animation.

@implementation CalendarCardExpansionExampleViewController {
  // In a real-world scenario we'd likely create a separate view to manage all of these subviews so
  // that our view controller doesn't balloon in complexity.
  UIView *_chipView;
  UIView *_collapsedContent;
  UIView *_expandedContent;
  UIView *_shapeView;
  BOOL _expanded;
}

- (void)didTap {
  _expanded = !_expanded;

  CalendarChipTiming timing = (_expanded
                               ? CalendarChipMotionSpec.expansion
                               : CalendarChipMotionSpec.collapse);

  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];
  animator.shouldReverseValues = !_expanded;
  animator.beginFromCurrentState = YES;

  [animator animateWithTiming:timing.navigationBarY animations:^{
    [self.navigationController setNavigationBarHidden:_expanded animated:YES];
  }];

  CGRect chipFrame = [self frameForChip];
  CGRect headerFrame = [self frameForHeader];

  // Animate the chip itself.
  [animator animateWithTiming:timing.chipHeight
                      toLayer:_chipView.layer
                   withValues:@[ @(chipFrame.size.height), @(headerFrame.size.height) ]
                      keyPath:MDMKeyPathHeight];
  [animator animateWithTiming:timing.chipWidth
                      toLayer:_chipView.layer
                   withValues:@[ @(chipFrame.size.width), @(headerFrame.size.width) ]
                      keyPath:MDMKeyPathWidth];
  [animator animateWithTiming:timing.chipWidth
                      toLayer:_chipView.layer
                   withValues:@[ @(CGRectGetMidX(chipFrame)), @(CGRectGetMidX(headerFrame)) ]
                      keyPath:MDMKeyPathX];
  [animator animateWithTiming:timing.chipY
                      toLayer:_chipView.layer
                   withValues:@[ @(CGRectGetMidY(chipFrame)), @(CGRectGetMidY(headerFrame)) ]
                      keyPath:MDMKeyPathY];
  [animator animateWithTiming:timing.chipHeight
                      toLayer:_chipView.layer
                   withValues:@[ @([self chipCornerRadius]), @0 ]
                      keyPath:MDMKeyPathCornerRadius];

  // Cross-fade the chip's contents.
  [animator animateWithTiming:timing.chipContentOpacity
                      toLayer:_collapsedContent.layer
                   withValues:@[ @1, @0 ]
                      keyPath:MDMKeyPathOpacity];
  [animator animateWithTiming:timing.headerContentOpacity
                      toLayer:_expandedContent.layer
                   withValues:@[ @0, @1 ]
                      keyPath:MDMKeyPathOpacity];

  // Keeps the expandec content aligned to the bottom of the card by taking into consideration the
  // extra height.
  CGFloat excessTopMargin = chipFrame.size.height - headerFrame.size.height;
  [animator animateWithTiming:timing.chipHeight
                      toLayer:_expandedContent.layer
                   withValues:@[ @(CGRectGetMidY([self expandedContentFrame]) + excessTopMargin),
                                 @(CGRectGetMidY([self expandedContentFrame])) ]
                      keyPath:MDMKeyPathY];

  // Keeps the collapsed content aligned to its position on screen by taking into consideration the
  // excess left margin.
  CGFloat excessLeftMargin = chipFrame.origin.x - headerFrame.origin.x;
  [animator animateWithTiming:timing.chipWidth
                      toLayer:_collapsedContent.layer
                   withValues:@[ @(CGRectGetMidX([self collapsedContentFrame])),
                                 @(CGRectGetMidX([self collapsedContentFrame]) + excessLeftMargin) ]
                      keyPath:MDMKeyPathX];

  // Keeps the shape anchored to the bottom right of the chip.
  CGRect shapeFrameInChip = [self shapeFrameInRect:chipFrame];
  CGRect shapeFrameInHeader = [self shapeFrameInRect:headerFrame];
  [animator animateWithTiming:timing.chipWidth
                      toLayer:_shapeView.layer
                   withValues:@[ @(CGRectGetMidX(shapeFrameInChip)), @(CGRectGetMidX(shapeFrameInHeader)) ]
                      keyPath:MDMKeyPathX];
  [animator animateWithTiming:timing.chipHeight
                      toLayer:_shapeView.layer
                   withValues:@[ @(CGRectGetMidY(shapeFrameInChip)), @(CGRectGetMidY(shapeFrameInHeader)) ]
                      keyPath:MDMKeyPathY];
}

#pragma mark - View creation and initial layout

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor whiteColor];

  _chipView = [[UIView alloc] initWithFrame:[self frameForChip]];
  _chipView.layer.cornerRadius = [self chipCornerRadius];
  _chipView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _chipView.backgroundColor = [UIColor colorWithRed:((CGFloat)0x03 / (CGFloat)255.0f)
                                              green:((CGFloat)0xC0 / (CGFloat)255.0f)
                                               blue:((CGFloat)0x7E / (CGFloat)255.0f)
                                              alpha:1];
  _chipView.clipsToBounds = true;

  UILabel *smallTitleLabel = [[UILabel alloc] initWithFrame:CGRectInset(_chipView.bounds, 8, 8)];
  smallTitleLabel.text = @"Fondue challenge";
  smallTitleLabel.textColor = [UIColor whiteColor];
  smallTitleLabel.font = [UIFont boldSystemFontOfSize:16];
  smallTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _collapsedContent = smallTitleLabel;
  [_chipView addSubview:_collapsedContent];

  UILabel *largeTitleLabel = [[UILabel alloc] initWithFrame:[self expandedContentFrame]];
  largeTitleLabel.text = @"Fondue challenge";
  largeTitleLabel.textColor = [UIColor whiteColor];
  largeTitleLabel.font = [UIFont boldSystemFontOfSize:24];
  largeTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _expandedContent = largeTitleLabel;
  [_chipView addSubview:_expandedContent];

  _shapeView = [[UIView alloc] initWithFrame:[self shapeFrameInRect:_chipView.bounds]];
  _shapeView.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin
                                 | UIViewAutoresizingFlexibleLeftMargin);
  _shapeView.backgroundColor = [UIColor whiteColor];
  _shapeView.layer.cornerRadius = _shapeView.bounds.size.width / 2;
  _shapeView.backgroundColor = [UIColor colorWithRed:((CGFloat)0x39 / (CGFloat)255.0f)
                                               green:((CGFloat)0x88 / (CGFloat)255.0f)
                                                blue:((CGFloat)0xE5 / (CGFloat)255.0f)
                                               alpha:1];
  [_chipView addSubview:_shapeView];
  [self.view addSubview:_chipView];

  UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(didTap)];
  [self.view addGestureRecognizer:tap];
}

#pragma mark - View metrics

- (CGFloat)chipCornerRadius {
  return 2;
}

- (CGRect)frameForChip {
  return CGRectMake(128, 192, self.view.bounds.size.width - 32 - 128, 48);
}

- (CGRect)frameForHeader {
  return CGRectMake(0, 0, self.view.bounds.size.width, 160);
}

- (CGRect)shapeFrameInRect:(CGRect)rect {
  return CGRectMake(rect.size.width - 40, rect.size.height - 32, 48, 48);
}

- (CGRect)collapsedContentFrame {
  CGRect rect = [self frameForChip];
  rect.origin = CGPointZero;
  return CGRectInset(rect, 8, 8);
}

- (CGRect)expandedContentFrame {
  CGRect rect = [self frameForHeader];
  rect.origin = CGPointZero;
  return CGRectOffset(CGRectInset(rect, 32, 32), 0, 32);
}

#pragma mark - View controller metrics

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

#pragma mark - Catalog by convention

+ (NSArray<NSString *> *)catalogBreadcrumbs {
  return @[ @"Calendar card expansion" ];
}

@end
