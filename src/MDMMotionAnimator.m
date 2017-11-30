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

  void (^commitToModelLayer)(void) = ^{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [layer setValue:[values lastObject] forKeyPath:keyPath];
    [CATransaction commit];
  };

  void (^exitEarly)(void) = ^{
    commitToModelLayer();

    if (completion) {
      completion();
    }
  };

  CGFloat timeScaleFactor = [self computedTimeScaleFactor];
  if (timeScaleFactor == 0) {
    exitEarly();
    return;
  }

  CABasicAnimation *animation = MDMAnimationFromTiming(timing, timeScaleFactor);

  if (animation == nil) {
    exitEarly();
    return;
  }

  animation.keyPath = keyPath;
  animation.toValue = [values lastObject];

  animation.additive = self.additive && MDMCanAnimationBeAdditive(keyPath, animation.toValue);

  // Now that we know whether the animation will be additive, we can calculate the from value.
  id fromValue;
  if (self.beginFromCurrentState) {
    // Additive animations always read from the model layer's value so that the new displacement
    // reflects the change in destination and momentum appears to be conserved across multiple
    // animations.
    //
    // Non-additive animations should try to read from the presentation layer's current value
    // because we'll be interrupting whatever animation previously existed and immediately moving
    // toward the new destination.
    BOOL wantsPresentationValue = !animation.additive;

    if (wantsPresentationValue && [layer presentationLayer]) {
      fromValue = [[layer presentationLayer] valueForKeyPath:keyPath];
    } else {
      fromValue = [layer valueForKeyPath:keyPath];
    }
  } else {
    fromValue = [values firstObject];
  }

  animation.fromValue = fromValue;

  if ([animation.fromValue isEqual:animation.toValue]) {
    exitEarly();
    return;
  }

  MDMConfigureAnimation(animation, timing);

  if (timing.delay != 0) {
    animation.beginTime = ([layer convertTime:CACurrentMediaTime() fromLayer:nil]
                           + timing.delay * timeScaleFactor);
    animation.fillMode = kCAFillModeBackwards;
  }

  NSString *key = _additive ? nil : keyPath;
  [_registrar addAnimation:animation toLayer:layer forKey:key completion:completion];

  commitToModelLayer();

  for (void (^tracer)(CALayer *, CAAnimation *) in _tracers) {
    tracer(layer, animation);
  }
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

- (void)removeAllAnimations {
  [_registrar removeAllAnimations];
}

- (void)stopAllAnimations {
  [_registrar commitCurrentAnimationValuesToAllLayers];
  [_registrar removeAllAnimations];
}

#pragma mark - Private

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

@end
