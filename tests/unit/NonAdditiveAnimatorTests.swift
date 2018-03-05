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

class NonAdditiveAnimationTests: XCTestCase {
  var animator: MotionAnimator!
  var traits: MDMAnimationTraits!
  var view: UIView!

  override func setUp() {
    super.setUp()

    animator = MotionAnimator()

    animator.additive = false

    traits = MDMAnimationTraits(duration: 1)

    let window = getTestHarnessKeyWindow()
    view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)

    // Connect our layers to the render server.
    CATransaction.flush()
  }

  override func tearDown() {
    animator = nil
    traits = nil
    view = nil

    super.tearDown()
  }

  func testNumericKeyPathsDontAnimateAdditively() {
    animator.animate(with: traits, between: [1, 0], layer: view.layer, keyPath: .cornerRadius)

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

    XCTAssertFalse(animation.isAdditive, "Animation is additive when it shouldn't be.")
  }

  func testSizeKeyPathsDontAnimateAdditively() {
    animator.animate(with: traits, between: [CGSize(width: 0, height: 0),
                                            CGSize(width: 1, height: 2)],
                     layer: view.layer, keyPath: .shadowOffset)

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

    XCTAssertFalse(animation.isAdditive, "Animation is additive when it shouldn't be.")
  }

  func testPositionKeyPathsDontAnimateAdditively() {
    animator.animate(with: traits, between: [CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 2)],
                     layer: view.layer, keyPath: .position)

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

    XCTAssertFalse(animation.isAdditive, "Animation is additive when it shouldn't be.")
  }

  func testRectKeyPathsDontAnimateAdditively() {
    animator.animate(with: traits, between: [CGRect(x: 0, y: 0, width: 0, height: 0),
                                            CGRect(x: 0, y: 0, width: 100, height: 50)],
                     layer: view.layer, keyPath: .bounds)

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

    XCTAssertFalse(animation.isAdditive, "Animation is additive when it shouldn't be.")
  }
}
