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

#import <MotionAnimator/MotionAnimator.h>

@implementation CalendarCardExpansionExampleViewController {
  UIView *_chipView;
  UIView *_collapsedContent;
  UIView *_expandedContent;
  UIView *_shapeView;
  BOOL _expanded;
}

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

- (void)didTap {
  _expanded = !_expanded;

  CalendarChipTiming timing = _expanded ? CalendarChipSpec.expansion : CalendarChipSpec.collapse;

  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];
  animator.shouldReverseValues = !_expanded;

  if (_expanded) {
    [self.navigationController setNavigationBarHidden:_expanded animated:true];

  } else {
    [UIView animateWithDuration:timing.navigationBarY.duration
                          delay:timing.navigationBarY.delay
                        options:0
                     animations:^{
                       [self.navigationController setNavigationBarHidden:_expanded animated:false];
                     } completion:nil];
  }

  CGRect chipFrame = [self frameForChip];
  CGRect headerFrame = [self frameForHeader];
  [animator animateWithTiming:timing.chipHeight
                      toLayer:_chipView.layer
                   withValues:@[ @(chipFrame.size.height), @(headerFrame.size.height) ]
                      keyPath:@"bounds.size.height"];
  [animator animateWithTiming:timing.chipWidth
                      toLayer:_chipView.layer
                   withValues:@[ @(chipFrame.size.width), @(headerFrame.size.width) ]
                      keyPath:@"bounds.size.width"];
  [animator animateWithTiming:timing.chipWidth
                      toLayer:_chipView.layer
                   withValues:@[ @(CGRectGetMidX(chipFrame)), @(CGRectGetMidX(headerFrame)) ]
                      keyPath:@"position.x"];
  [animator animateWithTiming:timing.chipY
                      toLayer:_chipView.layer
                   withValues:@[ @(CGRectGetMidY(chipFrame)), @(CGRectGetMidY(headerFrame)) ]
                      keyPath:@"position.y"];
  [animator animateWithTiming:timing.chipHeight
                      toLayer:_chipView.layer
                   withValues:@[ @([self chipCornerRadius]), @0 ]
                      keyPath:@"cornerRadius"];

  [animator animateWithTiming:timing.chipContentOpacity
                      toLayer:_collapsedContent.layer
                   withValues:@[ @1, @0 ]
                      keyPath:@"opacity"];
  [animator animateWithTiming:timing.headerContentOpacity
                      toLayer:_expandedContent.layer
                   withValues:@[ @0, @1 ]
                      keyPath:@"opacity"];

  // Keeps the expandec content aligned to the bottom of the card by taking into consideration the
  // extra height.
  [animator animateWithTiming:timing.chipHeight
                      toLayer:_expandedContent.layer
                   withValues:@[ @(CGRectGetMidY([self expandedContentFrame])
                                 + (chipFrame.size.height - headerFrame.size.height)),
                                 @(CGRectGetMidY([self expandedContentFrame])) ]
                      keyPath:@"position.y"];

  // Keeps the collapsed content aligned to its position on screen by taking into consideration the
  // excess left margin.
  [animator animateWithTiming:timing.chipWidth
                      toLayer:_collapsedContent.layer
                   withValues:@[ @(CGRectGetMidX([self collapsedContentFrame])),
                                 @(CGRectGetMidX([self collapsedContentFrame])
                                 + (chipFrame.origin.x - headerFrame.origin.x)) ]
                      keyPath:@"position.x"];

  CGRect shapeFrameInChip = [self shapeFrameInRect:chipFrame];
  CGRect shapeFrameInHeader = [self shapeFrameInRect:headerFrame];
  [animator animateWithTiming:timing.chipWidth
                      toLayer:_shapeView.layer
                   withValues:@[ @(CGRectGetMidX(shapeFrameInChip)), @(CGRectGetMidX(shapeFrameInHeader)) ]
                      keyPath:@"position.x"];
  [animator animateWithTiming:timing.chipHeight
                      toLayer:_shapeView.layer
                   withValues:@[ @(CGRectGetMidY(shapeFrameInChip)), @(CGRectGetMidY(shapeFrameInHeader)) ]
                      keyPath:@"position.y"];
}

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

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

+ (NSArray<NSString *> *)catalogBreadcrumbs {
  return @[ @"Calendar card expansion" ];
}

@end
