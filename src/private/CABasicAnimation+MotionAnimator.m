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

#import "CABasicAnimation+MotionAnimator.h"

#import "CAMediaTimingFunction+MotionAnimator.h"

#import <UIKit/UIKit.h>

CABasicAnimation *MDMAnimationFromTiming(MDMMotionTiming timing) {
  CABasicAnimation *animation;
  switch (timing.curve.type) {
    case MDMMotionCurveTypeInstant:
      animation = nil;
      break;

    case MDMMotionCurveTypeDefault:
    case MDMMotionCurveTypeBezier:
      animation = [CABasicAnimation animation];
      animation.timingFunction = MDMTimingFunctionWithControlPoints(timing.curve.data);
      animation.duration = timing.duration;
      break;

    case MDMMotionCurveTypeSpring: {
#pragma clang diagnostic push
      // CASpringAnimation is a private API on iOS 8 - we're able to make use of it because we're
      // linking against the public API on iOS 9+.
#pragma clang diagnostic ignored "-Wpartial-availability"
      CASpringAnimation *spring = [CASpringAnimation animation];
#pragma clang diagnostic pop
      spring.mass = timing.curve.data[MDMSpringMotionCurveDataIndexMass];
      spring.stiffness = timing.curve.data[MDMSpringMotionCurveDataIndexTension];
      spring.damping = timing.curve.data[MDMSpringMotionCurveDataIndexFriction];

      // This API is only available on iOS 9+
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

void MDMMakeAnimationAdditive(CABasicAnimation *animation) {
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
