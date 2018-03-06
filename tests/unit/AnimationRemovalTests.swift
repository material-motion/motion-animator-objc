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
  var traits: MDMAnimationTraits!
  var view: UIView!

  override func setUp() {
    super.setUp()

    animator = MotionAnimator()
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

  func testAllAdditiveAnimationsGetsRemoved() {
    animator.animate(with: traits, between: [1, 0], layer: view.layer, keyPath: .cornerRadius)
    animator.animate(with: traits, between: [0, 0.5], layer: view.layer, keyPath: .cornerRadius)

    XCTAssertEqual(view.layer.animationKeys()!.count, 2)

    animator.removeAllAnimations()

    XCTAssertNil(view.layer.animationKeys())
    XCTAssertEqual(view.layer.cornerRadius, 0.5)
  }

  func testCommitAndRemoveAllAnimationsCommitsThePresentationValue() {
    var didComplete = false
    CATransaction.begin()
    CATransaction.setCompletionBlock {
      didComplete = true
    }

    animator.animate(with: traits, between: [1, 0], layer: view.layer, keyPath: .cornerRadius)
    animator.animate(with: traits, between: [0, 0.5], layer: view.layer, keyPath: .cornerRadius)

    CATransaction.commit()

    XCTAssertEqual(view.layer.animationKeys()!.count, 2)

    RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.01))

    XCTAssertFalse(didComplete)

    animator.stopAllAnimations()

    XCTAssertNil(view.layer.animationKeys())
    XCTAssertEqual(view.layer.cornerRadius, view.layer.presentation()?.cornerRadius)
  }
}
