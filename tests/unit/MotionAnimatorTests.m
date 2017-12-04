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

  MDMMotionTiming timing = {
    .duration = 0,
  };

  layer.opacity = 0.5;

  [animator animateWithTiming:timing toLayer:layer withValues:@[ @0, @1 ] keyPath:@"opacity"];

  XCTAssertEqual(layer.opacity, 1);
}

- (void)testNoDurationCallsCompletionHandler {
  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];

  CALayer *layer = [[CALayer alloc] init];

  MDMMotionTiming timing = {
    .duration = 0,
  };

  layer.opacity = 0.5;

  __block BOOL didInvokeCompletion = false;
  [animator animateWithTiming:timing toLayer:layer withValues:@[ @0, @1 ] keyPath:@"opacity" completion:^{
    didInvokeCompletion = true;
  }];

  XCTAssertEqual(layer.opacity, 1);
  XCTAssertTrue(didInvokeCompletion);
}

- (void)testReversingSetsTheFirstValue {
  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];
  animator.shouldReverseValues = true;

  CALayer *layer = [[CALayer alloc] init];

  MDMMotionTiming timing = {
    .duration = 0,
  };

  layer.opacity = 0.5;

  [animator animateWithTiming:timing toLayer:layer withValues:@[ @0, @1 ] keyPath:@"cornerRadius"];

  XCTAssertEqual(layer.cornerRadius, 0);
}

- (void)testCubicBezierAnimationFloatValue {
  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];

  NSString *keyPath = @"cornerRadius";

  CALayer *layer = [[CALayer alloc] init];

  // Setting to some bogus value because it will be ignored with the default animator settings.
  layer.cornerRadius = 0.5;

  MDMMotionTiming timing = {
    .delay = 0.5,
    .duration = 1,
    .curve = MDMMotionCurveMakeBezier(0.1, 0.2, 0.3, 0.4),
  };

  __block BOOL didAddAnimation = false;
  [animator addCoreAnimationTracer:^(CALayer *layer, CAAnimation *animation) {
    XCTAssert([animation isKindOfClass:[CABasicAnimation class]]);
    CABasicAnimation *basicAnimation = (CABasicAnimation *)animation;

    XCTAssertEqual(basicAnimation.keyPath, keyPath);

    XCTAssertEqual(basicAnimation.duration, timing.duration);
    XCTAssertGreaterThan(basicAnimation.beginTime, 0);

    XCTAssertTrue(basicAnimation.additive);
    XCTAssertEqual([basicAnimation.fromValue doubleValue], -1);
    XCTAssertEqual([basicAnimation.toValue doubleValue], 0);

    float point1[2];
    float point2[2];
    [basicAnimation.timingFunction getControlPointAtIndex:1 values:point1];
    [basicAnimation.timingFunction getControlPointAtIndex:2 values:point2];
    XCTAssertEqualWithAccuracy(timing.curve.data[0], point1[0], 0.00001);
    XCTAssertEqualWithAccuracy(timing.curve.data[1], point1[1], 0.00001);
    XCTAssertEqualWithAccuracy(timing.curve.data[2], point2[0], 0.00001);
    XCTAssertEqualWithAccuracy(timing.curve.data[3], point2[1], 0.00001);

    didAddAnimation = true;
  }];

  [animator animateWithTiming:timing toLayer:layer withValues:@[ @0, @1 ] keyPath:keyPath];

  XCTAssertEqual(layer.cornerRadius, 1);
  XCTAssertTrue(didAddAnimation);
}

- (void)testSpringAnimationFloatValue {
  MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];

  NSString *keyPath = @"cornerRadius";

  CALayer *layer = [[CALayer alloc] init];

  // Setting to some bogus value because it will be ignored with the default animator settings.
  layer.cornerRadius = 0.5;

  MDMMotionTiming timing = {
    .delay = 0.5,
    .duration = 1,
    .curve = MDMMotionCurveMakeSpring(0.1, 0.2, 0.3),
  };

  __block BOOL didAddAnimation = false;
  [animator addCoreAnimationTracer:^(CALayer *layer, CAAnimation *animation) {
    XCTAssert([animation isKindOfClass:[CASpringAnimation class]]);
    CASpringAnimation *springAnimation = (CASpringAnimation *)animation;

    XCTAssertEqual(springAnimation.keyPath, keyPath);

    if ([springAnimation respondsToSelector:@selector(settlingDuration)]) {
      XCTAssertEqual(springAnimation.duration, springAnimation.settlingDuration);
    } else {
      XCTAssertEqual(springAnimation.duration, timing.duration);
    }
    XCTAssertGreaterThan(springAnimation.beginTime, 0);

    XCTAssertTrue(springAnimation.additive);
    XCTAssertEqual([springAnimation.fromValue doubleValue], -1);
    XCTAssertEqual([springAnimation.toValue doubleValue], 0);

    XCTAssertEqualWithAccuracy(timing.curve.data[0], springAnimation.mass, 0.00001);
    XCTAssertEqualWithAccuracy(timing.curve.data[1], springAnimation.stiffness, 0.00001);
    XCTAssertEqualWithAccuracy(timing.curve.data[2], springAnimation.damping, 0.00001);

    didAddAnimation = true;
  }];

  [animator animateWithTiming:timing toLayer:layer withValues:@[ @0, @1 ] keyPath:keyPath];

  XCTAssertEqual(layer.cornerRadius, 1);
  XCTAssertTrue(didAddAnimation);
}

@end
