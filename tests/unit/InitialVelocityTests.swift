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
    let velocity: CGFloat = 50
    animate(from: 0, to: 100, withVelocity: velocity)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      if (animation.responds(to: #selector(getter: CASpringAnimation.initialVelocity))) {
        XCTAssertEqual(animation.initialVelocity, 0.5,
                       "from: \(animation.fromValue!), "
                        + "to: \(animation.toValue!), "
                        + "withVelocity: \(velocity)")
      }
    }
  }

  func testVelocityAmplitudeMatchesDisplacementWithNegativeDisplacement() {
    let velocity: CGFloat = -50
    animate(from: 100, to: 0, withVelocity: velocity)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      if (animation.responds(to: #selector(getter: CASpringAnimation.initialVelocity))) {
        XCTAssertEqual(animation.initialVelocity, 0.5,
                       "from: \(animation.fromValue!), "
                        + "to: \(animation.toValue!), "
                        + "withVelocity: \(velocity)")
      }
    }
  }

  func testVelocityTowardsDestinationIsPositiveWithPositiveDisplacement() {
    let velocity: CGFloat = 100
    animate(from: 0, to: 100, withVelocity: velocity)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      if (animation.responds(to: #selector(getter: CASpringAnimation.initialVelocity))) {
        XCTAssertGreaterThan(animation.initialVelocity, 0,
                             "from: \(animation.fromValue!), "
                              + "to: \(animation.toValue!), "
                              + "withVelocity: \(velocity)")
      }
    }
  }

  func testVelocityAwayFromDestinationIsNegativeWithPositiveDisplacement() {
    let velocity: CGFloat = -100
    animate(from: 0, to: 100, withVelocity: velocity)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      if (animation.responds(to: #selector(getter: CASpringAnimation.initialVelocity))) {
        XCTAssertLessThan(animation.initialVelocity, 0,
                          "from: \(animation.fromValue!), "
                            + "to: \(animation.toValue!), "
                            + "withVelocity: \(velocity)")
      }
    }
  }

  func testVelocityTowardsDestinationIsPositiveWithNegativeDisplacement() {
    let velocity: CGFloat = -100
    animate(from: 100, to: 0, withVelocity: velocity)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      if (animation.responds(to: #selector(getter: CASpringAnimation.initialVelocity))) {
        XCTAssertGreaterThan(animation.initialVelocity, 0,
                             "from: \(animation.fromValue!), "
                              + "to: \(animation.toValue!), "
                              + "withVelocity: \(velocity)")
      }
    }
  }

  func testVelocityAwayFromDestinationIsNegativeWithNegativeDisplacement() {
    let velocity: CGFloat = 100
    animate(from: 100, to: 0, withVelocity: velocity)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      if (animation.responds(to: #selector(getter: CASpringAnimation.settlingDuration))) {
        XCTAssertLessThan(animation.initialVelocity, 0,
                          "from: \(animation.fromValue!), "
                            + "to: \(animation.toValue!), "
                            + "withVelocity: \(velocity)")
      }
    }
  }

  func testVelocityInfluencesDuration() {
    let velocity: CGFloat = 50
    animate(from: 0, to: 100, withVelocity: velocity)

    XCTAssertEqual(addedAnimations.count, 3)
    addedAnimations.flatMap { $0 as? CASpringAnimation }.forEach { animation in
      if (animation.responds(to: #selector(getter: CASpringAnimation.settlingDuration))) {
        XCTAssertEqual(animation.duration, animation.settlingDuration,
                       "from: \(animation.fromValue!), "
                        + "to: \(animation.toValue!), "
                        + "withVelocity: \(velocity)")
      }
    }
  }

  private func animate(from: CGFloat, to: CGFloat, withVelocity velocity: CGFloat) {
    let springCurve = MDMSpringTimingCurve(mass: 1, tension: 1, friction: 1,
                                           initialVelocity: velocity)
    let traits = MDMAnimationTraits(delay: 0, duration: 0.7, timingCurve: springCurve)
    animator.animate(with: traits, between: [from, to],
                     layer: CALayer(), keyPath: .opacity)
    animator.animate(with: traits, between: [CGPoint(x: from, y: from),
                                            CGPoint(x: to, y: to)],
                     layer: CALayer(), keyPath: .position)
    animator.animate(with: traits, between: [CGSize(width: from, height: from),
                                            CGSize(width: to, height: to)],
                     layer: CALayer(), keyPath: .init(rawValue: "bounds.size"))
  }
}

