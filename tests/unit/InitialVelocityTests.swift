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
    animate(from: 0, to: 100, withVelocity: 50)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      XCTAssertEqual(animation.initialVelocity, 0.5)
    }
  }

  func testVelocityAmplitudeMatchesDisplacementWithNegativeDisplacement() {
    animate(from: 100, to: 0, withVelocity: -50)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      XCTAssertEqual(animation.initialVelocity, 0.5)
    }
  }

  func testVelocityTowardsDestinationIsPositiveWithPositiveDisplacement() {
    animate(from: 0, to: 100, withVelocity: 100)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      XCTAssertGreaterThan(animation.initialVelocity, 0)
    }
  }

  func testVelocityAwayFromDestinationIsNegativeWithPositiveDisplacement() {
    animate(from: 0, to: 100, withVelocity: -100)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      XCTAssertLessThan(animation.initialVelocity, 0)
    }
  }

  func testVelocityTowardsDestinationIsPositiveWithNegativeDisplacement() {
    animate(from: 100, to: 0, withVelocity: -100)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      XCTAssertGreaterThan(animation.initialVelocity, 0)
    }
  }

  func testVelocityAwayFromDestinationIsNegativeWithNegativeDisplacement() {
    animate(from: 100, to: 0, withVelocity: 100)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      XCTAssertLessThan(animation.initialVelocity, 0)
    }
  }

  private func animate(from: CGFloat, to: CGFloat, withVelocity velocity: CGFloat) {
    let timing = MotionTiming(delay: 0,
                              duration: 0.7,
                              curve: .init(type: .spring, data: (1, 1, 1, velocity)),
                              repetition: .init(type: .none, amount: 0, autoreverses: false))
    animator.animate(with: timing, to: CALayer(), withValues: [from, to],
                     keyPath: .opacity)
    animator.animate(with: timing, to: CALayer(), withValues: [CGPoint(x: from, y: from),
                                                               CGPoint(x: to, y: to)],
                     keyPath: .position)
    animator.animate(with: timing, to: CALayer(), withValues: [CGSize(width: from, height: from),
                                                               CGSize(width: to, height: to)],
                     keyPath: .init(rawValue: "bounds.size"))
  }
}

