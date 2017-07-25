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

#if TARGET_IPHONE_SIMULATOR
UIKIT_EXTERN float UIAnimationDragCoefficient(void); // UIKit private drag coefficient.
#endif

static CGFloat simulatorAnimationDragCoefficient(void) {
#if TARGET_IPHONE_SIMULATOR
  return UIAnimationDragCoefficient();
#else
  return 1.0;
#endif
}

static CAMediaTimingFunction* timingFunctionWithControlPoints(CGFloat controlPoints[4]);
static NSArray* coerceUIKitValuesToCoreAnimationValues(NSArray *values);
static CABasicAnimation *animationFromTiming(MDMMotionTiming timing, CGFloat timeScaleFactor);
static void makeAnimationAdditive(CABasicAnimation *animation);

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
  values = coerceUIKitValuesToCoreAnimationValues(values);

  if (timing.duration == 0 || timing.curve.type == MDMMotionCurveTypeInstant) {
    [layer setValue:[values lastObject] forKeyPath:keyPath];
    if (completion) {
      completion();
    }
    return;
  }

  CGFloat timeScaleFactor = simulatorAnimationDragCoefficient() * _timeScaleFactor;
  CABasicAnimation *animation = animationFromTiming(timing, timeScaleFactor);

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
        makeAnimationAdditive(animation);
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

static CAMediaTimingFunction* timingFunctionWithControlPoints(CGFloat controlPoints[4]) {
  return [CAMediaTimingFunction functionWithControlPoints:(float)controlPoints[0]
                                                         :(float)controlPoints[1]
                                                         :(float)controlPoints[2]
                                                         :(float)controlPoints[3]];
}

static NSArray* coerceUIKitValuesToCoreAnimationValues(NSArray *values) {
  if ([[values firstObject] isKindOfClass:[UIColor class]]) {
    NSMutableArray *convertedArray = [NSMutableArray arrayWithCapacity:values.count];
    for (UIColor *color in values) {
      [convertedArray addObject:(id)color.CGColor];
    }
    values = convertedArray;

  } else if ([[values firstObject] isKindOfClass:[UIBezierPath class]]) {
    NSMutableArray *convertedArray = [NSMutableArray arrayWithCapacity:values.count];
    for (UIBezierPath *bezierPath in values) {
      [convertedArray addObject:(id)bezierPath.CGPath];
    }
    values = convertedArray;
  }
  return values;
}

static CABasicAnimation *animationFromTiming(MDMMotionTiming timing, CGFloat timeScaleFactor) {
  CABasicAnimation *animation;
  switch (timing.curve.type) {
    case MDMMotionCurveTypeInstant:
      animation = nil;
      break;

    case MDMMotionCurveTypeDefault:
    case MDMMotionCurveTypeBezier:
      animation = [CABasicAnimation animation];
      animation.timingFunction = timingFunctionWithControlPoints(timing.curve.data);
      animation.duration = timing.duration * timeScaleFactor;
      break;

    case MDMMotionCurveTypeSpring: {
      CASpringAnimation *spring = [CASpringAnimation animation];
      spring.mass = timing.curve.data[MDMSpringMotionCurveDataIndexMass];
      spring.stiffness = timing.curve.data[MDMSpringMotionCurveDataIndexTension];
      spring.damping = timing.curve.data[MDMSpringMotionCurveDataIndexFriction];
      if ([spring respondsToSelector:@selector(settlingDuration)]) {
        spring.duration = spring.settlingDuration;
      } else {
        spring.duration = timing.duration;
      }
      animation = spring;
      break;
    }
  }
  return animation;
}

static void makeAnimationAdditive(CABasicAnimation *animation) {
  static NSSet *sizeKeyPaths = nil;
  static NSSet *positionKeyPaths = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sizeKeyPaths = [NSSet setWithArray:@[@"bounds.size"]];

    positionKeyPaths = [NSSet setWithArray:@[@"position",
                                             @"anchorPoint"]];
  });

  if ([animation.toValue isKindOfClass:[NSNumber class]]) {
    CGFloat currentValue = (CGFloat)[animation.fromValue doubleValue];
    CGFloat delta = currentValue - (CGFloat)[animation.toValue doubleValue];
    animation.fromValue = @(delta);
    animation.toValue = @0;
    animation.additive = true;

  } else if ([sizeKeyPaths containsObject:animation.keyPath]) {
    CGSize currentValue = [animation.fromValue CGSizeValue];
    CGSize destinationValue = [animation.toValue CGSizeValue];
    CGSize delta = CGSizeMake(currentValue.width - destinationValue.width,
                              currentValue.height - destinationValue.height);
    animation.fromValue = [NSValue valueWithCGSize:delta];
    animation.toValue = [NSValue valueWithCGSize:CGSizeZero];
    animation.additive = true;

  } else if ([positionKeyPaths containsObject:animation.keyPath]) {
    CGPoint currentValue = [animation.fromValue CGPointValue];
    CGPoint destinationValue = [animation.toValue CGPointValue];
    CGPoint delta = CGPointMake(currentValue.x - destinationValue.x,
                                currentValue.y - destinationValue.y);
    animation.fromValue = [NSValue valueWithCGPoint:delta];
    animation.toValue = [NSValue valueWithCGPoint:CGPointZero];
    animation.additive = true;
  }
}
