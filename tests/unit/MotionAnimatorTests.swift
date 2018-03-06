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

class MotionAnimatorTests: XCTestCase {

  func testAnimatorOnlyUsesSingleNonAdditiveAnimationForKeyPath() {
    let animator = MotionAnimator()
    animator.additive = false
    let traits = MDMAnimationTraits(duration: 1)

    let window = getTestHarnessKeyWindow()
    let view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)

    XCTAssertEqual(view.layer.delegate as? UIView, view)

    UIView.animate(withDuration: 0.5) {
      animator.animate(with: traits, between: [0, 1],
                       layer: view.layer, keyPath: .rotation)

      XCTAssertEqual(view.layer.animationKeys()?.count, 1)
    }
  }

  func testCompletionCallbackIsExecutedWithZeroDuration() {
    let animator = MotionAnimator()
    let traits = MDMAnimationTraits(duration: 0)

    let window = UIWindow()
    window.makeKeyAndVisible()
    let view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)

    XCTAssertEqual(view.layer.delegate as? UIView, view)

    let didComplete = expectation(description: "Did complete")
    animator.animate(with: traits, between: [0, 1],
                     layer: view.layer, keyPath: .rotation) { _ in
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 1)
  }
}
