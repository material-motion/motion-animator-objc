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
  var timing: MotionTiming!
  var view: UIView!

  override func setUp() {
    super.setUp()

    animator = MotionAnimator()

    animator.additive = false

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

  func testNumericKeyPathsDontAnimateAdditively() {
    animator.animate(with: timing, to: view.layer, withValues: [1, 0], keyPath: .cornerRadius)

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
    animator.animate(with: timing, to: view.layer,
                     withValues: [CGSize(width: 0, height: 0),
                                  CGSize(width: 1, height: 2)], keyPath: .shadowOffset)

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
    animator.animate(with: timing, to: view.layer,
                     withValues: [CGPoint(x: 0, y: 0),
                                  CGPoint(x: 1, y: 2)], keyPath: .position)

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
    animator.animate(with: timing, to: view.layer,
                     withValues: [CGRect(x: 0, y: 0, width: 0, height: 0),
                                  CGRect(x: 0, y: 0, width: 100, height: 50)], keyPath: .bounds)

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
