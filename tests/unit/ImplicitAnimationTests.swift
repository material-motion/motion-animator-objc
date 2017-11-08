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

class ImplicitAnimationTests: XCTestCase {
  var animator: MotionAnimator!
  var timing: MotionTiming!
  var view: UIView!
  var addedAnimations: [CAAnimation]!

  var originalImplementation: IMP?
  override func setUp() {
    super.setUp()

    animator = MotionAnimator()
    animator.additive = false

    timing = MotionTiming(delay: 0,
                          duration: 0.7,
                          curve: .init(type: .bezier, data: (0, 0, 1, 1)),
                          repetition: .init(type: .none, amount: 0, autoreverses: false))

    let window = UIWindow()
    window.makeKeyAndVisible()
    view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)

    addedAnimations = []
    animator.addCoreAnimationTracer { (_, animation) in
      self.addedAnimations.append(animation)
    }

    originalImplementation =
      class_getMethodImplementation(UIView.self, #selector(UIView.action(for:forKey:)))
  }

  override func tearDown() {
    let implementation =
        class_getMethodImplementation(UIView.self, #selector(UIView.action(for:forKey:)))
    XCTAssertEqual(originalImplementation, implementation)

    animator = nil
    view = nil
    addedAnimations = nil

    super.tearDown()
  }

  func testNoActionAddsNoAnimations() {
    animator.animate(with: timing) {
      // No-op
    }

    XCTAssertEqual(addedAnimations.count, 0)
  }

  func testOneActionAddsOneAnimation() {
    animator.animate(with: timing) {
      self.view.alpha = 0
    }

    XCTAssertEqual(addedAnimations.count, 1)
    let animation = addedAnimations.first as! CABasicAnimation
    XCTAssertEqual(animation.keyPath, AnimatableKeyPath.opacity.rawValue)
    XCTAssertEqual(animation.fromValue as! CGFloat, 1)
    XCTAssertEqual(animation.toValue as! CGFloat, 0)
    XCTAssertEqual(animation.duration, timing.duration)

    let addedCurve = MotionCurve(fromTimingFunction: animation.timingFunction!)
    XCTAssertEqual(addedCurve.type, timing.curve.type)
    XCTAssertEqual(addedCurve.data.0, timing.curve.data.0)
    XCTAssertEqual(addedCurve.data.1, timing.curve.data.1)
    XCTAssertEqual(addedCurve.data.2, timing.curve.data.2)
    XCTAssertEqual(addedCurve.data.3, timing.curve.data.3)
  }

  func testTwoActionsAddsTwoAnimations() {
    animator.animate(with: timing) {
      self.view.alpha = 0
      self.view.center = .init(x: 50, y: 50)
    }

    XCTAssertEqual(addedAnimations.count, 2)

    do {
      let animation = addedAnimations.first as! CABasicAnimation
      XCTAssertFalse(animation.isAdditive)
      XCTAssertEqual(animation.keyPath, AnimatableKeyPath.opacity.rawValue)
      XCTAssertEqual(animation.fromValue as! CGFloat, 1)
      XCTAssertEqual(animation.toValue as! CGFloat, 0)
      XCTAssertEqual(animation.duration, timing.duration)

      let addedCurve = MotionCurve(fromTimingFunction: animation.timingFunction!)
      XCTAssertEqual(addedCurve.type, timing.curve.type)
      XCTAssertEqual(addedCurve.data.0, timing.curve.data.0)
      XCTAssertEqual(addedCurve.data.1, timing.curve.data.1)
      XCTAssertEqual(addedCurve.data.2, timing.curve.data.2)
      XCTAssertEqual(addedCurve.data.3, timing.curve.data.3)
    }
    do {
      let animation = addedAnimations[1] as! CABasicAnimation
      XCTAssertFalse(animation.isAdditive)
      XCTAssertEqual(animation.keyPath, AnimatableKeyPath.position.rawValue)
      XCTAssertEqual(animation.fromValue as! CGPoint, .init(x: 0, y: 0))
      XCTAssertEqual(animation.toValue as! CGPoint, .init(x: 50, y: 50))
      XCTAssertEqual(animation.duration, timing.duration)

      let addedCurve = MotionCurve(fromTimingFunction: animation.timingFunction!)
      XCTAssertEqual(addedCurve.type, timing.curve.type)
      XCTAssertEqual(addedCurve.data.0, timing.curve.data.0)
      XCTAssertEqual(addedCurve.data.1, timing.curve.data.1)
      XCTAssertEqual(addedCurve.data.2, timing.curve.data.2)
      XCTAssertEqual(addedCurve.data.3, timing.curve.data.3)
    }
  }

  func testFrameActionAddsTwoAnimations() {
    animator.animate(with: timing) {
      self.view.frame = .init(x: 0, y: 0, width: 100, height: 100)
    }

    XCTAssertEqual(addedAnimations.count, 2)

    do {
      let animation = addedAnimations
          .flatMap { $0 as? CABasicAnimation }
          .first(where: { $0.keyPath == AnimatableKeyPath.position.rawValue})!
      XCTAssertFalse(animation.isAdditive)
      XCTAssertEqual(animation.fromValue as! CGPoint, .init(x: 0, y: 0))
      XCTAssertEqual(animation.toValue as! CGPoint, .init(x: 50, y: 50))
      XCTAssertEqual(animation.duration, timing.duration)

      let addedCurve = MotionCurve(fromTimingFunction: animation.timingFunction!)
      XCTAssertEqual(addedCurve.type, timing.curve.type)
      XCTAssertEqual(addedCurve.data.0, timing.curve.data.0)
      XCTAssertEqual(addedCurve.data.1, timing.curve.data.1)
      XCTAssertEqual(addedCurve.data.2, timing.curve.data.2)
      XCTAssertEqual(addedCurve.data.3, timing.curve.data.3)
    }
    do {
      let animation = addedAnimations
        .flatMap { $0 as? CABasicAnimation }
        .first(where: { $0.keyPath == "bounds"})!
      XCTAssertFalse(animation.isAdditive)
      XCTAssertEqual(animation.fromValue as! CGRect, .init(x: 0, y: 0, width: 0, height: 0))
      XCTAssertEqual(animation.toValue as! CGRect, .init(x: 0, y: 0, width: 100, height: 100))
      XCTAssertEqual(animation.duration, timing.duration)

      let addedCurve = MotionCurve(fromTimingFunction: animation.timingFunction!)
      XCTAssertEqual(addedCurve.type, timing.curve.type)
      XCTAssertEqual(addedCurve.data.0, timing.curve.data.0)
      XCTAssertEqual(addedCurve.data.1, timing.curve.data.1)
      XCTAssertEqual(addedCurve.data.2, timing.curve.data.2)
      XCTAssertEqual(addedCurve.data.3, timing.curve.data.3)
    }
  }

  func testOneActionAddsNoAnimationWhenActionsDisable() {
    CATransaction.begin()
    CATransaction.setDisableActions(true)

    animator.animate(with: timing) {
      self.view.alpha = 0
    }

    CATransaction.commit()

    XCTAssertEqual(addedAnimations.count, 0)
    XCTAssertEqual(view.alpha, 0)
  }
}
