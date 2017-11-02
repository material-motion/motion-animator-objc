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

#import "MDMMotionAnimator.h"

#import <UIKit/UIKit.h>

#import "private/CABasicAnimation+MotionAnimator.h"
#import "private/MDMUIKitValueCoercion.h"
#import "private/MDMDragCoefficient.h"

@implementation MDMMotionAnimator {
  NSMutableArray *_tracers;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _timeScaleFactor = 1;
    _additive = true;
  }
  return self;
}

- (void)animateWithTiming:(MDMMotionTiming)timing
                  toLayer:(CALayer *)layer
               withValues:(NSArray *)values
                  keyPath:(MDMAnimatableKeyPath)keyPath {
  [self animateWithTiming:timing toLayer:layer withValues:values keyPath:keyPath completion:nil];
}

- (void)animateWithTiming:(MDMMotionTiming)timing
                  toLayer:(CALayer *)layer
               withValues:(NSArray *)values
                  keyPath:(MDMAnimatableKeyPath)keyPath
               completion:(void(^)(void))completion {
  NSAssert([values count] == 2, @"The values array must contain exactly two values.");

  if (_shouldReverseValues) {
    values = [[values reverseObjectEnumerator] allObjects];
  }
  values = MDMCoerceUIKitValuesToCoreAnimationValues(values);

  if (timing.duration == 0 || timing.curve.type == MDMMotionCurveTypeInstant) {
    [layer setValue:[values lastObject] forKeyPath:keyPath];
    if (completion) {
      completion();
    }
    return;
  }

  CGFloat timeScaleFactor = MDMSimulatorAnimationDragCoefficient() * _timeScaleFactor;
  CABasicAnimation *animation = MDMAnimationFromTiming(timing, timeScaleFactor);

  if (animation) {
    animation.keyPath = keyPath;

    id initialValue;
    if (_beginFromCurrentState) {
      if ([layer presentationLayer]) {
        initialValue = [[layer presentationLayer] valueForKeyPath:keyPath];
      } else {
        initialValue = [layer valueForKeyPath:keyPath];
      }
    } else {
      initialValue = [values firstObject];
    }

    animation.fromValue = initialValue;
    animation.toValue = [values lastObject];

    if (![animation.fromValue isEqual:animation.toValue]) {
      if (self.additive) {
        MDMMakeAnimationAdditive(animation);
      }

      if (timing.delay != 0) {
        animation.beginTime = ([layer convertTime:CACurrentMediaTime() fromLayer:nil]
                               + timing.delay * timeScaleFactor);
        animation.fillMode = kCAFillModeBackwards;
      }

      if (completion) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:completion];
      }

      // When we use a nil key, Core Animation will ensure that the animation is added with a
      // unique key - this enables our additive animations to stack upon one another.
      [layer addAnimation:animation forKey:nil];

      for (void (^tracer)(CALayer *, CAAnimation *) in _tracers) {
        tracer(layer, animation);
      }

      if (completion) {
        [CATransaction commit];
      }
    }
  }

  [layer setValue:[values lastObject] forKeyPath:keyPath];
}

- (void)addCoreAnimationTracer:(void (^)(CALayer *, CAAnimation *))tracer {
  if (!_tracers) {
    _tracers = [NSMutableArray array];
  }
  [_tracers addObject:[tracer copy]];
}

@end

