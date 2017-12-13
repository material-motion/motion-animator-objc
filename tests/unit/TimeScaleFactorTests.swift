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

class TimeScaleFactorTests: XCTestCase {

  let traits = MDMAnimationTraits(duration: 1)
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
    animator.animate(with: traits, between: [0, 1], layer: layer, keyPath: .rotation)

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.last!
    XCTAssertEqual(animation.duration, 1)
  }

  func testExplicitTimeScaleFactorChangesDuration() {
    animator.timeScaleFactor = 0.5

    animator.animate(with: traits, between: [0, 1], layer: layer, keyPath: .rotation)

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.last!
    XCTAssertEqual(animation.duration, traits.duration * 0.5)
  }

  func testTransactionTimeScaleFactorChangesDuration() {
    CATransaction.begin()
    CATransaction.mdm_setTimeScaleFactor(0.5)

    animator.animate(with: traits, between: [0, 1], layer: layer, keyPath: .rotation)
    CATransaction.commit()

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.last!
    XCTAssertEqual(animation.duration, traits.duration * 0.5)
  }

  func testTransactionTimeScaleFactorOverridesAnimatorTimeScaleFactor() {
    animator.timeScaleFactor = 2

    CATransaction.begin()
    CATransaction.mdm_setTimeScaleFactor(0.5)

    animator.animate(with: traits, between: [0, 1], layer: layer, keyPath: .rotation)

    CATransaction.commit()

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.last!
    XCTAssertEqual(animation.duration, traits.duration * 0.5)
  }

  func testNilTransactionTimeScaleFactorUsesAnimatorTimeScaleFactor() {
    animator.timeScaleFactor = 2

    CATransaction.begin()
    CATransaction.mdm_setTimeScaleFactor(0.5)
    CATransaction.mdm_setTimeScaleFactor(nil)

    animator.animate(with: traits, between: [0, 1], layer: layer, keyPath: .rotation)

    CATransaction.commit()

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.last!
    XCTAssertEqual(animation.duration, traits.duration * 2)
  }
}
