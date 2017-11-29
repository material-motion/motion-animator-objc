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

class BeginFromCurrentStateTests: XCTestCase {
  var animator: MotionAnimator!
  var timing: MotionTiming!
  var view: UIView!

  override func setUp() {
    super.setUp()

    animator = MotionAnimator()

    animator.beginFromCurrentState = true

    timing = MotionTiming(delay: 0,
                          duration: 1,
                          curve: MotionCurveMakeBezier(p1x: 0, p1y: 0, p2x: 0, p2y: 0),
                          repetition: .init(type: .none, amount: 0, autoreverses: false))

    let window = UIWindow()
    window.makeKeyAndVisible()
    view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)

    // Connect our layers to the render server.
    CATransaction.flush()
  }

  override func tearDown() {
    animator = nil
    timing = nil
    view = nil

    super.tearDown()
  }

  func testExplicitlyAnimatesFromModelValue() {
    let initialValue = view.layer.opacity

    animator.additive = false

    animator.animate(with: timing, to: view.layer, withValues: [0, 0.5], keyPath: .opacity)

    XCTAssertNotNil(view.layer.animationKeys(),
                    "Expected an animation to be added, but none were found.")
    guard let animationKeys = view.layer.animationKeys() else {
      return
    }
    XCTAssertEqual(animationKeys.count, 1,
                   "Expected only one animation to be added, but the following were found: "
                    + "\(animationKeys).")
    guard let key = animationKeys.first,
        let animation = view.layer.animation(forKey: key) as? CABasicAnimation else {
      return
    }

    XCTAssertTrue(animation.fromValue is Float,
                  "The animation's from value was not a number type: "
                    + String(describing: animation.fromValue))
    guard let fromValue = animation.fromValue as? Float else {
      return
    }

    XCTAssertEqualWithAccuracy(fromValue, initialValue, accuracy: 0.0001,
                               "Expected the animation to start from \(initialValue), "
                                + "but it did not.")

    XCTAssertEqualWithAccuracy(view.layer.opacity, 0.5, accuracy: 0.0001,
                               "The layer's opacity was not set to the animation's final value.")
  }

  func testImplicitlyAnimatesFromModelValue() {
    let initialValue = view.layer.opacity

    animator.additive = false

    animator.animate(with: timing) {
      self.view.alpha = 0.5
    }

    XCTAssertNotNil(view.layer.animationKeys(),
                    "Expected an animation to be added, but none were found.")
    guard let animationKeys = view.layer.animationKeys() else {
      return
    }
    XCTAssertEqual(animationKeys.count, 1,
                   "Expected only one animation to be added, but the following were found: "
                    + "\(animationKeys).")
    guard let key = animationKeys.first,
      let animation = view.layer.animation(forKey: key) as? CABasicAnimation else {
        return
    }

    XCTAssertTrue(animation.fromValue is Float,
                  "The animation's from value was not a number type: "
                    + String(describing: animation.fromValue))
    guard let fromValue = animation.fromValue as? Float else {
      return
    }

    XCTAssertEqualWithAccuracy(fromValue, initialValue, accuracy: 0.0001,
                               "Expected the animation to start from \(initialValue), "
                                + "but it did not.")

    XCTAssertEqualWithAccuracy(view.layer.opacity, 0.5, accuracy: 0.0001,
                               "The layer's opacity was not set to the animation's final value.")
  }

  func testExplicitlyAnimatesFromPresentationValue() {
    animator.additive = false

    animator.animate(with: timing, to: view.layer, withValues: [0, 0.5], keyPath: .opacity)
    RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.01))

    XCTAssertNotNil(view.layer.presentation(), "No presentation layer found.")
    guard let presentation = view.layer.presentation() else {
      return
    }
    let initialValue = presentation.opacity

    animator.animate(with: timing, to: view.layer, withValues: [0, 0.2], keyPath: .opacity)

    XCTAssertNotNil(view.layer.animationKeys(),
                    "Expected an animation to be added, but none were found.")
    guard let animationKeys = view.layer.animationKeys() else {
      return
    }
    XCTAssertEqual(animationKeys.count, 1,
                   "Expected only one animation to be added, but the following were found: "
                    + "\(animationKeys).")
    guard let key = animationKeys.first,
      let animation = view.layer.animation(forKey: key) as? CABasicAnimation else {
        return
    }

    XCTAssertTrue(animation.fromValue is Float,
                  "The animation's from value was not a number type: "
                    + String(describing: animation.fromValue))
    guard let fromValue = animation.fromValue as? Float else {
      return
    }

    XCTAssertEqualWithAccuracy(fromValue, initialValue, accuracy: 0.0001,
                               "Expected the animation to start from \(initialValue), "
                                + "but it did not.")

    XCTAssertEqualWithAccuracy(view.layer.opacity, 0.2, accuracy: 0.0001,
                               "The layer's opacity was not set to the animation's final value.")
  }

  func testImplicitlyAnimatesFromPresentationValue() {
    animator.additive = false

    animator.animate(with: timing, to: view.layer, withValues: [0, 0.5], keyPath: .opacity)

    RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.01))

    XCTAssertNotNil(view.layer.presentation(), "No presentation layer found.")
    guard let presentation = view.layer.presentation() else {
      return
    }
    let initialValue = presentation.opacity

    animator.animate(with: timing) {
      self.view.alpha = 0.2
    }

    XCTAssertNotNil(view.layer.animationKeys(),
                    "Expected an animation to be added, but none were found.")
    guard let animationKeys = view.layer.animationKeys() else {
      return
    }
    XCTAssertEqual(animationKeys.count, 1,
                   "Expected only one animation to be added, but the following were found: "
                    + "\(animationKeys).")
    guard let key = animationKeys.first,
      let animation = view.layer.animation(forKey: key) as? CABasicAnimation else {
        return
    }

    XCTAssertTrue(animation.fromValue is Float,
                  "The animation's from value was not a number type: "
                    + String(describing: animation.fromValue))
    guard let fromValue = animation.fromValue as? Float else {
      return
    }

    XCTAssertEqualWithAccuracy(fromValue, initialValue, accuracy: 0.0001,
                               "Expected the animation to start from \(initialValue), "
                                + "but it did not.")

    XCTAssertEqualWithAccuracy(view.layer.opacity, 0.2, accuracy: 0.0001,
                               "The layer's opacity was not set to the animation's final value.")
  }
}
