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

#import "CalendarChipMotionSpec.h"

static id<MDMTimingCurve> StandardTimingCurve(void) {
  return [CAMediaTimingFunction functionWithControlPoints:0.4f :0.0f :0.2f :1.0f];
}

static id<MDMTimingCurve> LinearTimingCurve(void) {
  return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
}

@interface CalendarChipExpansionTiming: NSObject <CalendarChipTiming>
@end

@implementation CalendarChipExpansionTiming

- (MDMAnimationTraits *)chipWidth {
  return [[MDMAnimationTraits alloc] initWithDelay:0.000 duration:0.285 timingCurve:StandardTimingCurve()];
}

- (MDMAnimationTraits *)chipHeight {
  return [[MDMAnimationTraits alloc] initWithDelay:0.015 duration:0.360 timingCurve:StandardTimingCurve()];
}

- (MDMAnimationTraits *)chipY {
  return [[MDMAnimationTraits alloc] initWithDelay:0.015 duration:0.360 timingCurve:StandardTimingCurve()];
}

- (MDMAnimationTraits *)chipContentOpacity {
  return [[MDMAnimationTraits alloc] initWithDelay:0.000 duration:0.075 timingCurve:LinearTimingCurve()];
}

- (MDMAnimationTraits *)headerContentOpacity {
  return [[MDMAnimationTraits alloc] initWithDelay:0.075 duration:0.150 timingCurve:LinearTimingCurve()];
}

- (MDMAnimationTraits *)navigationBarY {
  return [[MDMAnimationTraits alloc] initWithDelay:0.015 duration:0.360 timingCurve:StandardTimingCurve()];
}

@end

@interface CalendarChipCollapseTiming: NSObject <CalendarChipTiming>
@end

@implementation CalendarChipCollapseTiming

- (MDMAnimationTraits *)chipWidth {
  return [[MDMAnimationTraits alloc] initWithDelay:0.045 duration:0.330 timingCurve:StandardTimingCurve()];
}

- (MDMAnimationTraits *)chipHeight {
  return [[MDMAnimationTraits alloc] initWithDelay:0.000 duration:0.330 timingCurve:StandardTimingCurve()];
}

- (MDMAnimationTraits *)chipY {
  return [[MDMAnimationTraits alloc] initWithDelay:0.015 duration:0.330 timingCurve:StandardTimingCurve()];
}

- (MDMAnimationTraits *)chipContentOpacity {
  return [[MDMAnimationTraits alloc] initWithDelay:0.150 duration:0.150 timingCurve:LinearTimingCurve()];
}

- (MDMAnimationTraits *)headerContentOpacity {
  return [[MDMAnimationTraits alloc] initWithDelay:0.000 duration:0.075 timingCurve:LinearTimingCurve()];
}

@end

@implementation CalendarChipMotionSpec

+ (id<CalendarChipTiming>)expansion {
  return [[CalendarChipExpansionTiming alloc] init];
}

+ (id<CalendarChipTiming>)collapse {
  return [[CalendarChipCollapseTiming alloc] init];
}

@end

