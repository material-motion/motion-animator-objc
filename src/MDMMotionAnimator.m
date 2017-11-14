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

#import "CATransaction+MotionAnimator.h"
#import "private/CABasicAnimation+MotionAnimator.h"
#import "private/MDMAnimationRegistrar.h"
#import "private/MDMUIKitValueCoercion.h"
#import "private/MDMBlockAnimations.h"
#import "private/MDMDragCoefficient.h"

@implementation MDMMotionAnimator {
  NSMutableArray *_tracers;
  MDMAnimationRegistrar *_registrar;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _registrar = [[MDMAnimationRegistrar alloc] init];
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

  CGFloat timeScaleFactor = [self computedTimeScaleFactor];
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
      MDMConfigureAnimation(animation, self.additive, timing);

      if (timing.delay != 0) {
        animation.beginTime = ([layer convertTime:CACurrentMediaTime() fromLayer:nil]
                               + timing.delay * timeScaleFactor);
        animation.fillMode = kCAFillModeBackwards;
      }

      NSString *key = _additive ? nil : keyPath;
      [_registrar addAnimation:animation toLayer:layer forKey:key completion:completion];

      for (void (^tracer)(CALayer *, CAAnimation *) in _tracers) {
        tracer(layer, animation);
      }
    }
  }

  [CATransaction begin];
  [CATransaction setDisableActions:YES];
  [layer setValue:[values lastObject] forKeyPath:keyPath];
  [CATransaction commit];
}

- (void)animateWithTiming:(MDMMotionTiming)timing animations:(void (^)(void))animations {
  [self animateWithTiming:timing animations:animations completion:nil];
}

- (void)animateWithTiming:(MDMMotionTiming)timing
               animations:(void (^)(void))animations
               completion:(void(^)(void))completion {
  NSArray<MDMImplicitAction *> *actions = MDMAnimateImplicitly(animations);

  [CATransaction begin];
  [CATransaction setCompletionBlock:completion];

  for (MDMImplicitAction *action in actions) {
    id currentValue = [action.layer valueForKeyPath:action.keyPath];
    [self animateWithTiming:timing
                    toLayer:action.layer
                 withValues:@[action.initialValue, currentValue]
                    keyPath:action.keyPath];
  }

  [CATransaction commit];
}

- (void)addCoreAnimationTracer:(void (^)(CALayer *, CAAnimation *))tracer {
  if (!_tracers) {
    _tracers = [NSMutableArray array];
  }
  [_tracers addObject:[tracer copy]];
}

- (CGFloat)computedTimeScaleFactor {
  CGFloat timeScaleFactor;
  id transactionTimeScaleFactor = [CATransaction mdm_timeScaleFactor];
  if (transactionTimeScaleFactor != nil) {
#if CGFLOAT_IS_DOUBLE
    timeScaleFactor = [transactionTimeScaleFactor doubleValue];
#else
    timeScaleFactor = [transactionTimeScaleFactor floatValue];
#endif
  } else {
    timeScaleFactor = _timeScaleFactor;
  }

  return MDMSimulatorAnimationDragCoefficient() * timeScaleFactor;
}

- (void)removeAllAnimations {
  [_registrar removeAllAnimations];
}

- (void)stopAllAnimations {
  [_registrar commitCurrentAnimationValuesToAllLayers];
  [_registrar removeAllAnimations];
}

@end
