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

class InstantAnimationTests: XCTestCase {

  var animator: MotionAnimator!
  var timing: MotionTiming!
  var view: UIView!
  var addedAnimations: [CAAnimation]!

  override func setUp() {
    super.setUp()

    animator = MotionAnimator()

    timing = MotionTiming(delay: 0,
                          duration: 0,
                          curve: .init(type: .instant, data: (0, 0, 0, 0)),
                          repetition: .init(type: .none, amount: 0, autoreverses: false))

    let window = UIWindow()
    window.makeKeyAndVisible()
    view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)

    addedAnimations = []
    animator.addCoreAnimationTracer { (_, animation) in
      self.addedAnimations.append(animation)
    }
  }

  override func tearDown() {
    animator = nil
    view = nil
    addedAnimations = nil

    super.tearDown()
  }

  func testDoesNotGenerateImplicitAnimations() {
    animator.animate(with: timing, to: view.layer, withValues: [1, 0.5], keyPath: .opacity)

    XCTAssertNil(view.layer.animationKeys())
    XCTAssertEqual(addedAnimations.count, 0)
  }

  func testDoesNotGenerateImplicitAnimationsInUIViewAnimationBlock() {
    UIView.animate(withDuration: 0.5) {
      self.animator.animate(with: self.timing,
                            to: self.view.layer,
                            withValues: [1, 0.5],
                            keyPath: .opacity)
    }

    XCTAssertNil(view.layer.animationKeys())
    XCTAssertEqual(addedAnimations.count, 0)
  }
}
