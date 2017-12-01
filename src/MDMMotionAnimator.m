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

  BOOL beginFromCurrentState = self.beginFromCurrentState;

  [self addAnimation:animation
             toLayer:layer
         withKeyPath:keyPath
              timing:timing
     timeScaleFactor:timeScaleFactor
         destination:[values lastObject]
        initialValue:^(BOOL wantsPresentationValue) {
          if (beginFromCurrentState) {
            if (wantsPresentationValue && [layer presentationLayer]) {
              return [[layer presentationLayer] valueForKeyPath:keyPath];
            } else {
              return [layer valueForKeyPath:keyPath];
            }
          } else {
            return [values firstObject];
          }

        } completion:completion];

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

  void (^exitEarly)(void) = ^{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    animations();
    [CATransaction commit];

    if (completion) {
      completion();
    }
  };

  CGFloat timeScaleFactor = [self computedTimeScaleFactor];
  if (timeScaleFactor == 0) {
    exitEarly();
    return; // No need to animate anything.
  }

  // We'll reuse this animation template for each action.
  CABasicAnimation *animationTemplate = MDMAnimationFromTiming(timing, timeScaleFactor);
  if (animationTemplate == nil) {
    exitEarly();
    return;
  }

  [CATransaction begin];
  [CATransaction setCompletionBlock:completion];

  for (MDMImplicitAction *action in actions) {
    CABasicAnimation *animation = [animationTemplate copy];

    [self addAnimation:animation
               toLayer:action.layer
           withKeyPath:action.keyPath
                timing:timing
       timeScaleFactor:timeScaleFactor
           destination:[action.layer valueForKeyPath:action.keyPath]
          initialValue:^(BOOL wantsPresentationValue) {
               if (wantsPresentationValue && action.hadPresentationLayer) {
                 return action.initialPresentationValue;
               } else {
                 // Additive animations always animate from the initial model layer value.
                 return action.initialModelValue;
               }
             } completion:nil];

    for (void (^tracer)(CALayer *, CAAnimation *) in _tracers) {
      tracer(action.layer, animation);
    }
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

- (void)addAnimation:(CABasicAnimation *)animation
             toLayer:(CALayer *)layer
         withKeyPath:(NSString *)keyPath
              timing:(MDMMotionTiming)timing
     timeScaleFactor:(CGFloat)timeScaleFactor
         destination:(id)destination
        initialValue:(id(^)(BOOL wantsPresentationValue))initialValueBlock
          completion:(void(^)(void))completion {
  // Must configure the keyPath and toValue before we can identify whether the animation supports
  // being additive.
  animation.keyPath = keyPath;
  animation.toValue = destination;
  animation.additive = self.additive && MDMCanAnimationBeAdditive(keyPath, animation.toValue);

  // Additive animations always read from the model layer's value so that the new displacement
  // reflects the change in destination and momentum appears to be conserved across multiple
  // animations.
  //
  // Non-additive animations should try to read from the presentation layer's current value
  // because we'll be interrupting whatever animation previously existed and immediately moving
  // toward the new destination.
  BOOL wantsPresentationValue = self.beginFromCurrentState && !animation.additive;
  animation.fromValue = initialValueBlock(wantsPresentationValue);

  NSString *key = animation.additive ? nil : keyPath;

  MDMConfigureAnimation(animation, timing);

  if (timing.delay != 0) {
    animation.beginTime = ([layer convertTime:CACurrentMediaTime() fromLayer:nil]
                           + timing.delay * timeScaleFactor);
    animation.fillMode = kCAFillModeBackwards;
  }

  [_registrar addAnimation:animation toLayer:layer forKey:key completion:completion];
}

@end
