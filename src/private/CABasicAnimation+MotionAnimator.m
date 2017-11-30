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

#pragma mark - Private

static BOOL IsNumberValue(id someValue) {
  return [someValue isKindOfClass:[NSNumber class]];
}

static BOOL IsCGPointType(id someValue) {
  if ([someValue isKindOfClass:[NSValue class]]) {
    NSValue *asValue = (NSValue *)someValue;
    const char *objCType = @encode(CGPoint);
    return strncmp(asValue.objCType, objCType, strlen(objCType)) == 0;
  }
  return NO;
}

static BOOL IsCGSizeType(id someValue) {
  if ([someValue isKindOfClass:[NSValue class]]) {
    NSValue *asValue = (NSValue *)someValue;
    const char *objCType = @encode(CGSize);
    return strncmp(asValue.objCType, objCType, strlen(objCType)) == 0;
  }
  return NO;
}

static BOOL IsAnimationKeyPathAlwaysNonAdditive(NSString *keyPath) {
  static NSSet *nonAdditiveKeyPaths = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    nonAdditiveKeyPaths = [NSSet setWithArray:@[@"backgroundColor", @"opacity"]];
  });

  return [nonAdditiveKeyPaths containsObject:keyPath];
}

#pragma mark - Public

CABasicAnimation *MDMAnimationFromTiming(MDMMotionTiming timing, CGFloat timeScaleFactor) {
  CABasicAnimation *animation;
  switch (timing.curve.type) {
    case MDMMotionCurveTypeInstant:
      animation = nil;
      break;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    case MDMMotionCurveTypeDefault:
#pragma clang diagnostic pop
    case MDMMotionCurveTypeBezier:
      animation = [CABasicAnimation animation];
      animation.timingFunction = MDMTimingFunctionWithControlPoints(timing.curve.data);
      animation.duration = timing.duration * timeScaleFactor;

      if (animation.duration == 0) {
        return nil;
      }
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
      spring.duration = timing.duration;

      animation = spring;
      break;
    }
  }
  return animation;
}

BOOL MDMCanAnimationBeAdditive(NSString *keyPath, id toValue) {
  if (IsAnimationKeyPathAlwaysNonAdditive(keyPath)) {
    return NO;
  }
  return IsNumberValue(toValue) || IsCGSizeType(toValue) || IsCGPointType(toValue);
}

void MDMConfigureAnimation(CABasicAnimation *animation, MDMMotionTiming timing) {
  if (!animation.additive && timing.curve.type != MDMMotionCurveTypeSpring) {
    return; // Nothing to do here.
  }

  if (IsNumberValue(animation.toValue)) {
    // Non-additive animations animate along a direct path between fromValue and toValue, regardless
    // of the model layer. Additive animations, on the other hand, animate towards the layer's model
    // value by applying this formula:
    //
    //     presentationLayer.value = modelLayer.value + additiveAnim1.value ... additiveAnimN.value
    //
    // This formula is what allows additive animations to give the appearance of conservation of
    // momentum when multiple additive animations are added to the same key path.
    //
    // To transform a non-additive animation into an additive animation, use the following formula:
    //
    //     additiveAnimation.from = -(animation.to - animation.from)
    //     additiveAnimation.to   = 0
    //
    // For example, if we're animating from 50 to 100, our additive animation's from value will
    // equal -(100 - 50) = -50. Because the accumulator is animating to 0 and our model layer is
    // set to the destination value, our animation will give the appearance of animating from 50 to
    // 100:
    //
    //  | model value | accumulator | presentation value |
    //  |-------------|-------------|--------------------|
    //  |         100 |         -50 |                 50 |
    //  |         100 |         -25 |                 75 |
    //  |         100 |         -10 |                 90 |
    //  |         100 |          -5 |                 95 |
    //  |         100 |           0 |                100 |

    CGFloat from = (CGFloat)[animation.fromValue doubleValue];
    CGFloat to = (CGFloat)[animation.toValue doubleValue];
    CGFloat displacement = to - from;
    CGFloat additiveDisplacement = -displacement;

    if (animation.additive) {
      animation.fromValue = @(additiveDisplacement);
      animation.toValue = @0;
    }

#pragma clang diagnostic push
    // CASpringAnimation is a private API on iOS 8 - we're able to make use of it because we're
    // linking against the public API on iOS 9+.
#pragma clang diagnostic ignored "-Wpartial-availability"
    if ([animation isKindOfClass:[CASpringAnimation class]]) {
      CASpringAnimation *springAnimation = (CASpringAnimation *)animation;
#pragma clang diagnostic pop

      CGFloat absoluteInitialVelocity = timing.curve.data[MDMSpringMotionCurveDataIndexInitialVelocity];

      // Our timing's initialVelocity is in points per second, but Core Animation expects initial
      // velocity to be in terms of displacement per second.
      //
      // From the UIView animateWithDuration header docs:
      //
      // "initialVelocity is a unit coordinate system, where 1 is defined as traveling the total
      //  animation distance in a second. So if you're changing an object's position by 200pt in
      //  this animation, and you want the animation to behave as if the object was moving at
      //  100pt/s before the animation started, you'd pass 0.5. You'll typically want to pass 0 for
      //  the velocity."
      //
      // It's also important to know that an initial velocity > 0 indicates movement towards the
      // destination, while an initial velocity < 0 indicates movement away from the destination.
      //
      // With this in mind, consider Core Animation's initialVelocity as having two bits of
      // information:
      //
      // - Its sign. Positive is towards the destination. Negative is away.
      // - Its amplitude, where amplitude * displacement = absolute initial velocity
      //
      // For example: If our absolute initial velocity is +200/s, and our displacement is -100, then
      // Core Animation's initialVelocity is -2, with the (-) indicating that we're moving away from
      // the destination and the 2 indicating we're moving twice the displacement over a second.
      // Similarly, if our absolute initial velocity is -200/s, and our displacement is still -100
      // points, then Core Animation's initialVelocity is 2; only the sign has changed.
      //
      // We want to know amplitude, so we do some basic arithmetic to turn:
      //
      //     amplitude * displacement = absolute initial velocity
      //
      // into:
      //
      //     amplitude = absolute initial velocity / displacement
      //
      // As for our sign, if absoluteInitialVelocity matches the direction of displacement, then our
      // sign will be positive. Otherwise, our sign will be negative, as expected by Core Animation.

      if (fabs(displacement) > 0.00001) {
        springAnimation.initialVelocity = absoluteInitialVelocity / displacement;
      }
    }

  } else if (IsCGSizeType(animation.toValue)) {
    CGSize from = [animation.fromValue CGSizeValue];
    CGSize to = [animation.toValue CGSizeValue];
    CGSize additiveDisplacement = CGSizeMake(from.width - to.width, from.height - to.height);

    if (animation.additive) {
      animation.fromValue = [NSValue valueWithCGSize:additiveDisplacement];
      animation.toValue = [NSValue valueWithCGSize:CGSizeZero];
    }

#pragma clang diagnostic push
    // CASpringAnimation is a private API on iOS 8 - we're able to make use of it because we're
    // linking against the public API on iOS 9+.
#pragma clang diagnostic ignored "-Wpartial-availability"
    if ([animation isKindOfClass:[CASpringAnimation class]]) {
      CASpringAnimation *springAnimation = (CASpringAnimation *)animation;
#pragma clang diagnostic pop
      // Core Animation's velocity system is single dimensional, so we pick the dominant direction
      // of movement and normalize accordingly.
      CGFloat biggestDelta;
      if (fabs(additiveDisplacement.width) > fabs(additiveDisplacement.height)) {
        biggestDelta = additiveDisplacement.width;
      } else {
        biggestDelta = additiveDisplacement.height;
      }
      CGFloat displacement = -biggestDelta;
      CGFloat absoluteInitialVelocity =
          timing.curve.data[MDMSpringMotionCurveDataIndexInitialVelocity];
      if (fabs(displacement) > 0.00001) {
        springAnimation.initialVelocity = absoluteInitialVelocity / displacement;
      }
    }

  } else if (IsCGPointType(animation.toValue)) {
    CGPoint from = [animation.fromValue CGPointValue];
    CGPoint to = [animation.toValue CGPointValue];
    CGPoint additiveDisplacement = CGPointMake(from.x - to.x, from.y - to.y);

    if (animation.additive) {
      animation.fromValue = [NSValue valueWithCGPoint:additiveDisplacement];
      animation.toValue = [NSValue valueWithCGPoint:CGPointZero];
    }

#pragma clang diagnostic push
    // CASpringAnimation is a private API on iOS 8 - we're able to make use of it because we're
    // linking against the public API on iOS 9+.
#pragma clang diagnostic ignored "-Wpartial-availability"
    if ([animation isKindOfClass:[CASpringAnimation class]]) {
      CASpringAnimation *springAnimation = (CASpringAnimation *)animation;
#pragma clang diagnostic pop
      // Core Animation's velocity system is single dimensional, so we pick the dominant direction
      // of movement and normalize accordingly.
      CGFloat biggestDelta;
      if (fabs(additiveDisplacement.x) > fabs(additiveDisplacement.y)) {
        biggestDelta = additiveDisplacement.x;
      } else {
        biggestDelta = additiveDisplacement.y;
      }
      CGFloat displacement = -biggestDelta;
      CGFloat absoluteInitialVelocity =
          timing.curve.data[MDMSpringMotionCurveDataIndexInitialVelocity];
      if (fabs(displacement) > 0.00001) {
        springAnimation.initialVelocity = absoluteInitialVelocity / displacement;
      }
    }
  }

  // Update the animation's duration to match the proposed settling duration.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpartial-availability"
  if ([animation isKindOfClass:[CASpringAnimation class]]) {
    CASpringAnimation *springAnimation = (CASpringAnimation *)animation;
#pragma clang diagnostic pop

    // This API is only available on iOS 9+
    if ([springAnimation respondsToSelector:@selector(settlingDuration)]) {
      animation.duration = springAnimation.settlingDuration;
    }
  }
}
