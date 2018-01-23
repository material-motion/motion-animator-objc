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

#import <XCTest/XCTest.h>
#import "MotionAnimator.h"

@interface MotionAnimatorTests : XCTestCase
@end

@implementation MotionAnimatorTests

- (void)testNoDurationSetsValueInstantly {
  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];

  CALayer *layer = [[CALayer alloc] init];

  MDMAnimationTraits *traits = [[MDMAnimationTraits alloc] initWithDuration:0];

  layer.opacity = 0.5;

  [animator animateWithTraits:traits between:@[ @0, @1 ] layer:layer keyPath:@"opacity"];

  XCTAssertEqual(layer.opacity, 1);
}

- (void)testNoDurationCallsCompletionHandler {
  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];

  CALayer *layer = [[CALayer alloc] init];

  MDMAnimationTraits *traits = [[MDMAnimationTraits alloc] initWithDuration:0];

  layer.opacity = 0.5;

  __block BOOL didInvokeCompletion = false;
  [animator animateWithTraits:traits between:@[ @0, @1 ]
                        layer:layer keyPath:@"opacity"
                   completion:^(BOOL didComplete) {
    didInvokeCompletion = true;
  }];

  XCTAssertEqual(layer.opacity, 1);
  XCTAssertTrue(didInvokeCompletion);
}

- (void)testReversingSetsTheFirstValue {
  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];
  animator.shouldReverseValues = true;

  CALayer *layer = [[CALayer alloc] init];

  MDMAnimationTraits *traits = [[MDMAnimationTraits alloc] initWithDuration:0];

  layer.opacity = 0.5;

  [animator animateWithTraits:traits between:@[ @0, @1 ] layer:layer keyPath:@"cornerRadius"];

  XCTAssertEqual(layer.cornerRadius, 0);
}

- (void)testCubicBezierAnimationFloatValue {
  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];

  NSString *keyPath = @"cornerRadius";

  CALayer *layer = [[CALayer alloc] init];

  // Setting to some bogus value because it will be ignored with the default animator settings.
  layer.cornerRadius = 0.5;

  CAMediaTimingFunction *timingFunction =
      [CAMediaTimingFunction functionWithControlPoints:0.1 :0.2 :0.3 :0.4];
  MDMAnimationTraits *traits = [[MDMAnimationTraits alloc] initWithDelay:0.5
                                                                duration:1
                                                             timingCurve:timingFunction];

  __block BOOL didAddAnimation = false;
  [animator addCoreAnimationTracer:^(CALayer *layer, CAAnimation *animation) {
    XCTAssert([animation isKindOfClass:[CABasicAnimation class]]);
    CABasicAnimation *basicAnimation = (CABasicAnimation *)animation;

    XCTAssertEqual(basicAnimation.keyPath, keyPath);

    XCTAssertEqual(basicAnimation.duration, traits.duration);
    XCTAssertGreaterThan(basicAnimation.beginTime, 0);

    XCTAssertTrue(basicAnimation.additive);
    XCTAssertEqual([basicAnimation.fromValue doubleValue], -1);
    XCTAssertEqual([basicAnimation.toValue doubleValue], 0);

    float point1[2];
    float point2[2];
    [basicAnimation.timingFunction getControlPointAtIndex:1 values:point1];
    [basicAnimation.timingFunction getControlPointAtIndex:2 values:point2];
    XCTAssertEqualWithAccuracy(timingFunction.mdm_point1.x, point1[0], 0.00001);
    XCTAssertEqualWithAccuracy(timingFunction.mdm_point1.y, point1[1], 0.00001);
    XCTAssertEqualWithAccuracy(timingFunction.mdm_point2.x, point2[0], 0.00001);
    XCTAssertEqualWithAccuracy(timingFunction.mdm_point2.y, point2[1], 0.00001);

    didAddAnimation = true;
  }];

  [animator animateWithTraits:traits between:@[ @0, @1 ] layer:layer keyPath:keyPath];

  XCTAssertEqual(layer.cornerRadius, 1);
  XCTAssertTrue(didAddAnimation);
}

- (void)testSpringAnimationFloatValue {
  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];

  NSString *keyPath = @"cornerRadius";

  CALayer *layer = [[CALayer alloc] init];

  // Setting to some bogus value because it will be ignored with the default animator settings.
  layer.cornerRadius = 0.5;

  MDMSpringTimingCurve *springCurve =
      [[MDMSpringTimingCurve alloc] initWithMass:0.1 tension:0.2 friction:0.3];
  MDMAnimationTraits *traits = [[MDMAnimationTraits alloc] initWithDelay:0.5
                                                                duration:1
                                                             timingCurve:springCurve];

  __block BOOL didAddAnimation = false;
  [animator addCoreAnimationTracer:^(CALayer *layer, CAAnimation *animation) {
    XCTAssert([animation isKindOfClass:[CASpringAnimation class]]);
    CASpringAnimation *springAnimation = (CASpringAnimation *)animation;

    XCTAssertEqual(springAnimation.keyPath, keyPath);

    if ([springAnimation respondsToSelector:@selector(settlingDuration)]) {
      XCTAssertEqual(springAnimation.duration, springAnimation.settlingDuration);
    } else {
      XCTAssertEqual(springAnimation.duration, traits.duration);
    }
    XCTAssertGreaterThan(springAnimation.beginTime, 0);

    XCTAssertTrue(springAnimation.additive);
    XCTAssertEqual([springAnimation.fromValue doubleValue], -1);
    XCTAssertEqual([springAnimation.toValue doubleValue], 0);

    XCTAssertEqualWithAccuracy(springCurve.mass, springAnimation.mass, 0.00001);
    XCTAssertEqualWithAccuracy(springCurve.tension, springAnimation.stiffness, 0.00001);
    XCTAssertEqualWithAccuracy(springCurve.friction, springAnimation.damping, 0.00001);

    didAddAnimation = true;
  }];

  [animator animateWithTraits:traits between:@[ @0, @1 ] layer:layer keyPath:keyPath];

  XCTAssertEqual(layer.cornerRadius, 1);
  XCTAssertTrue(didAddAnimation);
}

#pragma mark - Legacy API

- (void)testAnimationWithTimingNilCompletion {
  // Given
  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];

  CALayer *layer = [[CALayer alloc] init];
  MDMMotionTiming timing = (MDMMotionTiming) {
    .duration = 0.250, .curve = MDMMotionCurveMakeBezier(0.42f, 0.00f, 0.58f, 1.00f)
  };

  // When
  [animator animateWithTiming:timing
                   animations:^{
                     layer.opacity = 0.7;
                   }
                   completion:nil];

  // Then
  XCTAssertEqualWithAccuracy(layer.opacity, 0.7, 0.0001);
}

- (void)testAnimationWithTimingToLayerWithValuesKeyPathNilCompletion {
  // Given
  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];

  CALayer *layer = [[CALayer alloc] init];
  CALayer *anotherLayer = [[CALayer alloc] init];
  MDMMotionTiming timing = (MDMMotionTiming) {
    .duration = 0.250, .curve = MDMMotionCurveMakeBezier(0.42f, 0.00f, 0.58f, 1.00f)
  };

  // When
  [animator animateWithTiming:timing
                       toLayer:anotherLayer
                    withValues:@[@(0), @(1)]
                      keyPath:@"opacity"
                   completion:nil];

  // Then
  XCTAssertEqualWithAccuracy(layer.opacity, 1, 0.0001);
}

@end
