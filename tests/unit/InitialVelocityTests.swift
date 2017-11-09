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

import XCTest
#if IS_BAZEL_BUILD
import _MotionAnimator
#else
import MotionAnimator
#endif

@available(iOS 9.0, *)
class InitialVelocityTests: XCTestCase {

  var animator: MotionAnimator!
  var addedAnimations: [CAAnimation]!
  override func setUp() {
    super.setUp()

    animator = MotionAnimator()
    addedAnimations = []
    animator.addCoreAnimationTracer { (_, animation) in
      self.addedAnimations.append(animation)
    }
  }

  override func tearDown() {
    animator = nil
    addedAnimations = nil

    super.tearDown()
  }

  func testVelocityAmplitudeMatchesDisplacementWithPositiveDisplacement() {
    let timing = MotionTiming(delay: 0,
                              duration: 0.7,
                              curve: .init(type: .spring, data: (1, 1, 1, 50)),
                              repetition: .init(type: .none, amount: 0, autoreverses: false))
    animator.animate(with: timing, to: CALayer(), withValues: [0, 100], keyPath: .opacity)

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.first as! CASpringAnimation
    XCTAssertEqual(animation.initialVelocity, 0.5)
  }

  func testVelocityAmplitudeMatchesDisplacementWithNegativeDisplacement() {
    let timing = MotionTiming(delay: 0,
                              duration: 0.7,
                              curve: .init(type: .spring, data: (1, 1, 1, -50)),
                              repetition: .init(type: .none, amount: 0, autoreverses: false))
    animator.animate(with: timing, to: CALayer(), withValues: [100, 0], keyPath: .opacity)

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.first as! CASpringAnimation
    XCTAssertEqual(animation.initialVelocity, 0.5)
  }

  func testVelocityTowardsDestinationIsPositiveWithPositiveDisplacement() {
    let timing = MotionTiming(delay: 0,
                          duration: 0.7,
                          curve: .init(type: .spring, data: (1, 1, 1, 100)),
                          repetition: .init(type: .none, amount: 0, autoreverses: false))
    animator.animate(with: timing, to: CALayer(), withValues: [0, 100], keyPath: .opacity)

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.first as! CASpringAnimation
    XCTAssertGreaterThan(animation.initialVelocity, 0)
  }

  func testVelocityAwayFromDestinationIsNegativeWithPositiveDisplacement() {
    let timing = MotionTiming(delay: 0,
                              duration: 0.7,
                              curve: .init(type: .spring, data: (1, 1, 1, -100)),
                              repetition: .init(type: .none, amount: 0, autoreverses: false))
    animator.animate(with: timing, to: CALayer(), withValues: [0, 100], keyPath: .opacity)

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.first as! CASpringAnimation
    XCTAssertLessThan(animation.initialVelocity, 0)
  }

  func testVelocityTowardsDestinationIsPositiveWithNegativeDisplacement() {
    let timing = MotionTiming(delay: 0,
                              duration: 0.7,
                              curve: .init(type: .spring, data: (1, 1, 1, -100)),
                              repetition: .init(type: .none, amount: 0, autoreverses: false))
    animator.animate(with: timing, to: CALayer(), withValues: [100, 0], keyPath: .opacity)

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.first as! CASpringAnimation
    XCTAssertGreaterThan(animation.initialVelocity, 0)
  }

  func testVelocityAwayFromDestinationIsNegativeWithNegativeDisplacement() {
    let timing = MotionTiming(delay: 0,
                              duration: 0.7,
                              curve: .init(type: .spring, data: (1, 1, 1, 100)),
                              repetition: .init(type: .none, amount: 0, autoreverses: false))
    animator.animate(with: timing, to: CALayer(), withValues: [100, 0], keyPath: .opacity)

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.first as! CASpringAnimation
    XCTAssertLessThan(animation.initialVelocity, 0)
  }
}

