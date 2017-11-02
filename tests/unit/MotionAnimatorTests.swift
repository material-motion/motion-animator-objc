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
import MotionAnimator

class MotionAnimatorTests: XCTestCase {

  func testAnimatorAPIsCompile() {
    let animator = MotionAnimator()
    let timing = MotionTiming(delay: 0,
                              duration: 1,
                              curve: .init(type: .bezier, data: (0, 0, 0, 0)),
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
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .strokeStart)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .strokeEnd)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .width)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .x)
    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .y)

    animator.animate(with: timing, to: layer, withValues: [0, 1], keyPath: .init(rawValue: "bounds.size.width"))

    XCTAssertTrue(true)
  }

}

