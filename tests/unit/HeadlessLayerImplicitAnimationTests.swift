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

// A headless layer is one without a delegate. UIView's backing CALayer instance automatically sets
// its delegate to the UIView, but CALayer instances created on their own have no delegate. These
// tests validate our expectations for how headless layers should behave both with and without our
// motion animator support.
class HeadlessLayerImplicitAnimationTests: XCTestCase {

  func testDoesNotImplicitlyAnimate() {
    let layer = CALayer()
    // No delegate = no implicit animations.

    UIView.animate(withDuration: 0.5) {
      layer.opacity = 0.5
    }

    XCTAssertNil(layer.animationKeys())
  }

  func testDoesNotImplicitlyAnimateWithLayerDelegateAlone() {
    let layer = CALayer()
    // Delegate will allow us to do implicit animations, but only via the motion animator.
    layer.delegate = MotionAnimator.sharedLayerDelegate()

    UIView.animate(withDuration: 0.5) {
      layer.opacity = 0.5
    }

    XCTAssertNil(layer.animationKeys())
  }

  func testDoesImplicitlyAnimateWithLayerDelegateAndAnimator() {
    let layer = CALayer()
    layer.delegate = MotionAnimator.sharedLayerDelegate()

    let animator = MotionAnimator()
    let timing = MotionTiming(delay: 0,
                              duration: 1,
                              curve: MotionCurveMakeBezier(p1x: 0, p1y: 0, p2x: 0, p2y: 0),
                              repetition: .init(type: .none, amount: 0, autoreverses: false))

    animator.animate(with: timing) {
      layer.opacity = 0.5
    }

    XCTAssertEqual(layer.animationKeys()?.count, 1)
  }
}
