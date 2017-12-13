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
  var view: UIView!
  var addedAnimations: [CAAnimation]!

  override func setUp() {
    super.setUp()

    animator = MotionAnimator()

    let window = UIWindow()
    window.makeKeyAndVisible()
    view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)

    // Connect our layers to the render server.
    CATransaction.flush()

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
    let traits = MDMAnimationTraits(duration: 0)

    animator.animate(with: traits, between: [1, 0.5],
                     layer: view.layer, keyPath: .opacity)

    XCTAssertNil(view.layer.animationKeys())
    XCTAssertEqual(addedAnimations.count, 0)
  }

  func testDoesNotGenerateImplicitAnimationsInUIViewAnimationBlock() {
    let traits = MDMAnimationTraits(duration: 0)

    UIView.animate(withDuration: 0.5) {
      self.animator.animate(with: traits, between: [1, 0.5],
                            layer: self.view.layer, keyPath: .opacity)
    }

    XCTAssertNil(view.layer.animationKeys())
    XCTAssertEqual(addedAnimations.count, 0)
  }

  func testDoesNotGenerateImplicitAnimationsWithNilCurve() {
    let traits = MDMAnimationTraits(delay: 0, duration: 0.5, timingCurve: nil)

    animator.animate(with: traits, between: [1, 0.5],
                     layer: view.layer, keyPath: .opacity)

    XCTAssertNil(view.layer.animationKeys())
    XCTAssertEqual(addedAnimations.count, 0)
  }

  func testDoesNotGenerateImplicitAnimationsInUIViewAnimationBlockWithNilCurve() {
    let traits = MDMAnimationTraits(delay: 0, duration: 0.5, timingCurve: nil)

    UIView.animate(withDuration: 0.5) {
      self.animator.animate(with: traits, between: [1, 0.5],
                            layer: self.view.layer, keyPath: .opacity)
    }

    XCTAssertNil(view.layer.animationKeys())
    XCTAssertEqual(addedAnimations.count, 0)
  }
}
