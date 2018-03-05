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

  var window: UIWindow!
  var layer: CALayer!
  override func setUp() {
    super.setUp()

    window = getTestHarnessKeyWindow()

    layer = CALayer()

    window.layer.addSublayer(layer)

    // Connect our layers to the render server.
    CATransaction.flush()
  }

  override func tearDown() {
    layer = nil
    window = nil

    super.tearDown()
  }

  func testUnFlushedLayerDoesNotImplicitlyAnimateInCATransaction() {
    let unflushedLayer = CALayer()
    CATransaction.begin()
    CATransaction.setAnimationDuration(0.5)
    unflushedLayer.opacity = 0.5
    CATransaction.commit()

    XCTAssertNil(unflushedLayer.animationKeys())
  }

  func testDoesImplicitlyAnimateInCATransaction() {
    CATransaction.begin()
    CATransaction.setAnimationDuration(0.5)
    layer.opacity = 0.5
    CATransaction.commit()

    let animation = layer.animation(forKey: "opacity") as! CABasicAnimation
    XCTAssertEqual(animation.keyPath, "opacity")
    XCTAssertEqual(animation.duration, 0.5)
  }

  func testDoesNotImplicitlyAnimateInCATransactionWithActionsDisabled() {
    CATransaction.begin()
    CATransaction.setAnimationDuration(0.5)
    CATransaction.setDisableActions(true)
    layer.opacity = 0.5
    CATransaction.commit()

    XCTAssertNil(layer.animationKeys())
  }

  func testCATransactionTimingTakesPrecedenceOverUIViewTimingInside() {
    UIView.animate(withDuration: 0.5) {
      CATransaction.begin()
      CATransaction.setAnimationDuration(0.2)
      self.layer.opacity = 0.5
      CATransaction.commit()
    }

    let animation = layer.animation(forKey: "opacity") as! CABasicAnimation
    XCTAssertEqual(animation.keyPath, "opacity")
    XCTAssertEqual(animation.duration, 0.2)
  }

  // Verifies the somewhat counter-intuitive fact that CATransaction's animation duration always
  // takes precedence over UIView's animation duration. This means that animating a headless layer
  // using UIView animation APIs may not result in the expected traits.
  func testCATransactionTimingTakesPrecedenceOverUIViewTimingOutside() {
    CATransaction.begin()
    CATransaction.setAnimationDuration(0.2)
    UIView.animate(withDuration: 0.5) {
      self.layer.opacity = 0.5
    }
    CATransaction.commit()

    let animation = layer.animation(forKey: "opacity") as! CABasicAnimation
    XCTAssertEqual(animation.keyPath, "opacity")
    XCTAssertEqual(animation.duration, 0.2)
  }

  func testDoesImplicitlyAnimateInUIViewAnimateBlock() {
    UIView.animate(withDuration: 0.5) {
      self.layer.opacity = 0.5
    }

    let animation = layer.animation(forKey: "opacity") as! CABasicAnimation
    XCTAssertEqual(animation.keyPath, "opacity")
    XCTAssertEqual(animation.duration, CATransaction.animationDuration())
  }

  func testDoesNotImplicitlyAnimateInUIViewAnimateBlockWithActionsDisabledInside() {
    UIView.animate(withDuration: 0.5) {
      CATransaction.begin()
      CATransaction.setDisableActions(true)
      self.layer.opacity = 0.5
      CATransaction.commit()
    }

    XCTAssertNil(layer.animationKeys())
  }

  func testDoesNotImplicitlyAnimateInUIViewAnimateBlockWithActionsDisabledOutside() {
    CATransaction.begin()
    CATransaction.setDisableActions(true)
    UIView.animate(withDuration: 0.5) {
      self.layer.opacity = 0.5
    }
    CATransaction.commit()

    XCTAssertNil(layer.animationKeys())
  }

  func testAnimatorTimingTakesPrecedenceOverCATransactionTiming() {
    let animator = MotionAnimator()
    animator.additive = false

    let traits = MDMAnimationTraits(duration: 1)

    CATransaction.begin()
    CATransaction.setAnimationDuration(0.5)
    animator.animate(with: traits) {
      self.layer.opacity = 0.5
    }
    CATransaction.commit()

    let animation = layer.animation(forKey: "opacity") as! CABasicAnimation
    XCTAssertEqual(animation.keyPath, "opacity")
    XCTAssertEqual(animation.duration, traits.duration)
  }

  // MARK: Deprecated tests.

  @available(*, deprecated)
  func testDoesImplicitlyAnimateInCATransactionWithLayerDelegateAlone() {
    layer.delegate = MotionAnimator.sharedLayerDelegate()

    CATransaction.begin()
    CATransaction.setAnimationDuration(0.5)
    layer.opacity = 0.5
    CATransaction.commit()

    XCTAssertEqual(layer.animationKeys()!, ["opacity"])
  }

  @available(*, deprecated)
  func testDoesNotImplicitlyAnimateInCATransactionWithLayerDelegateAloneAndActionsAreDisabled() {
    layer.delegate = MotionAnimator.sharedLayerDelegate()

    CATransaction.begin()
    CATransaction.setAnimationDuration(0.5)
    CATransaction.setDisableActions(true)
    layer.opacity = 0.5
    CATransaction.commit()

    XCTAssertNil(layer.animationKeys())
  }

  @available(*, deprecated)
  func testDoesImplicitlyAnimateInUIViewAnimateBlockWithLayerDelegateAlone() {
    layer.delegate = MotionAnimator.sharedLayerDelegate()

    UIView.animate(withDuration: 0.5) {
      self.layer.opacity = 0.5
    }

    XCTAssertEqual(layer.animationKeys()!, ["opacity"])
  }

  @available(*, deprecated)
  func testDoesImplicitlyAnimateWithLayerDelegateAndAnimator() {
    layer.delegate = MotionAnimator.sharedLayerDelegate()

    let animator = MotionAnimator()
    animator.additive = false
    let traits = MDMAnimationTraits(duration: 1)

    animator.animate(with: traits) {
      self.layer.opacity = 0.5
    }

    XCTAssertEqual(layer.animationKeys()!, ["opacity"])
  }
}
