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

  func testAnimatorAPIsCompile() {
    let animator = MotionAnimator()
    let timing = MotionTiming(delay: 0,
                              duration: 1,
                              curve: MotionCurveMakeBezier(p1x: 0, p1y: 0, p2x: 0, p2y: 0),
                              repetition: .init(type: .none, amount: 0, autoreverses: false))
    let layer = CALayer()

    animator.animate(with: timing, to: layer,
                     withValues: [UIColor.blue, UIColor.red], keyPath: .backgroundColor)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .cornerRadius)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .height)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .opacity)
    animator.animate(with: timing, to: layer,
                     withValues: [CGPoint.zero, CGPoint(x: 1, y: 1)], keyPath: .position)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .rotation)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .scale)
    animator.animate(with: timing, to: layer,
                     withValues: [CGSize.zero, CGSize(width: 1, height: 1)], keyPath: .shadowOffset)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .shadowOpacity)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .shadowRadius)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .strokeStart)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .strokeEnd)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .width)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .x)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .y)

    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .init(rawValue: "bounds.size.width"))

    XCTAssertTrue(true)
  }

  func testAnimatorOnlyUsesSingleNonAdditiveAnimationForKeyPath() {
    let animator = MotionAnimator()
    animator.additive = false

    let timing = MotionTiming(delay: 0,
                              duration: 1,
                              curve: MotionCurveMakeBezier(p1x: 0, p1y: 0, p2x: 0, p2y: 0),
                              repetition: .init(type: .none, amount: 0, autoreverses: false))

    let window = UIWindow()
    window.makeKeyAndVisible()
    let view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)

    XCTAssertEqual(view.layer.delegate as? UIView, view)

    UIView.animate(withDuration: 0.5) {
      animator.animate(with: timing, to: view.layer, withValues: [0, 1], keyPath: .rotation)

      XCTAssertEqual(view.layer.animationKeys()?.count, 1)
    }
  }

  func testCompletionCallbackIsExecutedWithZeroDuration() {
    let animator = MotionAnimator()

    let timing = MotionTiming(delay: 0,
                              duration: 0,
                              curve: MotionCurveMakeBezier(p1x: 0, p1y: 0, p2x: 0, p2y: 0),
                              repetition: .init(type: .none, amount: 0, autoreverses: false))

    let window = UIWindow()
    window.makeKeyAndVisible()
    let view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)

    XCTAssertEqual(view.layer.delegate as? UIView, view)

    let didComplete = expectation(description: "Did complete")
    animator.animate(with: timing, to: view.layer, withValues: [0, 1], keyPath: .rotation) {
      didComplete.fulfill()
    }

    waitForExpectations(timeout: 1)
  }
}
