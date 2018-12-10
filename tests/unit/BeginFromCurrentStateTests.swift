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
  var traits: MDMAnimationTraits!
  var view: UIView!
  var addedAnimations: [CAAnimation]!

  override func setUp() {
    super.setUp()

    animator = MotionAnimator()

    animator.beginFromCurrentState = true

    traits = MDMAnimationTraits(duration: 1)

    let window = getTestHarnessKeyWindow()
    view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)

    addedAnimations = []
    animator.addCoreAnimationTracer { (_, animation) in
      self.addedAnimations.append(animation)
    }

    // Connect our layers to the render server.
    CATransaction.flush()
  }

  override func tearDown() {
    animator = nil
    traits = nil
    view = nil
    addedAnimations = nil

    super.tearDown()
  }

  func testExplicitlyAnimatesFromModelValue() {
    let initialValue = view.layer.opacity

    animator.additive = false

    animator.animate(with: traits, between: [0, 0.5],
                     layer: view.layer, keyPath: .opacity)

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

    animator.animate(with: traits) {
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

    animator.animate(with: traits, between: [0, 0.5],
                     layer: view.layer, keyPath: .opacity)
    RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.01))

    XCTAssertNotNil(view.layer.presentation(), "No presentation layer found.")
    guard let presentation = view.layer.presentation() else {
      return
    }
    let initialValue = presentation.opacity

    animator.animate(with: traits, between: [0, 0.2],
                     layer: view.layer, keyPath: .opacity)

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

    animator.animate(with: traits, between: [0, 0.5],
                     layer: view.layer, keyPath: .opacity)

    RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.01))

    XCTAssertNotNil(view.layer.presentation(), "No presentation layer found.")
    guard let presentation = view.layer.presentation() else {
      return
    }
    let initialValue = presentation.opacity

    animator.animate(with: traits) {
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

  func testViewAnimatesFromPresentationLayer() {
    animator.beginFromCurrentState = true
    animator.additive = false

    animator.animate(with: traits) {
      self.view.alpha = 0.5
    }

    RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.01))

    let initialValue = view.layer.presentation()!.opacity

    animator.animate(with: traits) {
      self.view.alpha = 1.0
    }

    XCTAssertEqual(addedAnimations.count, 2)

    if addedAnimations.count == 2 {
      let animation = addedAnimations.last as! CABasicAnimation
      XCTAssertFalse(animation.isAdditive)
      XCTAssertEqual(animation.keyPath, AnimatableKeyPath.opacity.rawValue)
      XCTAssertEqual(animation.fromValue as! Float, initialValue)
      XCTAssertEqualWithAccuracy(animation.toValue as! CGFloat, 1.0, accuracy: 0.0001)
    }
  }
}
