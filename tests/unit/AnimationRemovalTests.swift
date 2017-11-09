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

class AnimationRemovalTests: XCTestCase {
  var animator: MotionAnimator!
  var timing: MotionTiming!
  var view: UIView!

  var originalImplementation: IMP?
  override func setUp() {
    super.setUp()

    animator = MotionAnimator()
    timing = MotionTiming(delay: 0,
                          duration: 1,
                          curve: MotionCurveMakeBezier(p1x: 0, p1y: 0, p2x: 0, p2y: 0),
                          repetition: .init(type: .none, amount: 0, autoreverses: false))

    let window = UIWindow()
    window.makeKeyAndVisible()
    view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)
  }

  override func tearDown() {
    animator = nil
    timing = nil
    view = nil

    super.tearDown()
  }

  func testAllAdditiveAnimationsGetsRemoved() {
    animator.animate(with: timing, to: view.layer, withValues: [1, 0], keyPath: .opacity)
    animator.animate(with: timing, to: view.layer, withValues: [0, 0.5], keyPath: .opacity)

    XCTAssertEqual(view.layer.animationKeys()!.count, 2)

    animator.removeAllAnimations()

    XCTAssertNil(view.layer.animationKeys())
    XCTAssertEqual(view.layer.opacity, 0.5)
  }

#if swift(>=3.2)
  func testCommitAndRemoveAllAnimationsCommitsThePresentationValue() {
    let didComplete = expectation(description: "Did complete")

    CATransaction.begin()
    CATransaction.setCompletionBlock {
      didComplete.fulfill()
    }

    animator.animate(with: timing, to: view.layer, withValues: [1, 0], keyPath: .opacity)
    animator.animate(with: timing, to: view.layer, withValues: [0, 0.5], keyPath: .opacity)

    CATransaction.commit()

    XCTAssertEqual(view.layer.animationKeys()!.count, 2)

    let result = XCTWaiter().wait(for: [didComplete], timeout: 0.01)
    XCTAssertEqual(result, .timedOut)

    animator.commitAndRemoveAllAnimations()

    XCTAssertNil(view.layer.animationKeys())
    XCTAssertEqual(view.layer.opacity, view.layer.presentation()?.opacity)
  }
#endif
}
