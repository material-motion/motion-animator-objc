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
import MotionAnimator

class TimeScaleFactorTests: XCTestCase {

  let timing = MotionTiming(delay: 0,
                            duration: 1,
                            curve: .init(type: .bezier, data: (0, 0, 0, 0)),
                            repetition: .init(type: .none, amount: 0, autoreverses: false))
  var layer: CALayer!
  var addedAnimations: [CAAnimation]!
  var animator: MotionAnimator!

  override func setUp() {
    super.setUp()

    addedAnimations = []
    animator = MotionAnimator()
    animator.addCoreAnimationTracer { (_, animation) in
      self.addedAnimations.append(animation)
    }

    layer = CALayer()
  }

  override func tearDown() {
    layer = nil
    addedAnimations = nil
    animator = nil

    super.tearDown()
  }

  func testDefaultTimeScaleFactorDoesNotModifyDuration() {
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .rotation)

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.last!
    XCTAssertEqual(animation.duration, 1)
  }

  func testExplicitTimeScaleFactorChangesDuration() {
    animator.timeScaleFactor = 0.5

    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .rotation)

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.last!
    XCTAssertEqual(animation.duration, timing.duration * 0.5)
  }

  func testTransactionTimeScaleFactorChangesDuration() {
    CATransaction.begin()
    CATransaction.mdm_setTimeScaleFactor(0.5)

    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .rotation)
    CATransaction.commit()

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.last!
    XCTAssertEqual(animation.duration, timing.duration * 0.5)
  }

  func testTransactionTimeScaleFactorOverridesAnimatorTimeScaleFactor() {
    animator.timeScaleFactor = 2

    CATransaction.begin()
    CATransaction.mdm_setTimeScaleFactor(0.5)

    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .rotation)

    CATransaction.commit()

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.last!
    XCTAssertEqual(animation.duration, timing.duration * 0.5)
  }

  func testNilTransactionTimeScaleFactorUsesAnimatorTimeScaleFactor() {
    animator.timeScaleFactor = 2

    CATransaction.begin()
    CATransaction.mdm_setTimeScaleFactor(0.5)
    CATransaction.mdm_setTimeScaleFactor(nil)

    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .rotation)

    CATransaction.commit()

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.last!
    XCTAssertEqual(animation.duration, timing.duration * 2)
  }
}
