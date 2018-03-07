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

class ImplicitAnimationTests: XCTestCase {
  var animator: MotionAnimator!
  var traits: MDMAnimationTraits!
  var view: UIView!
  var addedAnimations: [CAAnimation]!

  var originalImplementation: IMP?
  override func setUp() {
    super.setUp()

    animator = MotionAnimator()
    animator.additive = false

    traits = MDMAnimationTraits(duration: 1)

    let window = getTestHarnessKeyWindow()
    view = UIView() // Need to animate a view's layer to get implicit animations.
    window.addSubview(view)

    addedAnimations = []
    animator.addCoreAnimationTracer { (_, animation) in
      self.addedAnimations.append(animation)
    }

    // Connect our layers to the render server.
    CATransaction.flush()

    originalImplementation =
      class_getMethodImplementation(CALayer.self, #selector(CALayer.action(forKey:)))
  }

  override func tearDown() {
    let implementation =
        class_getMethodImplementation(CALayer.self, #selector(CALayer.action(forKey:)))
    XCTAssertEqual(originalImplementation, implementation)

    animator = nil
    view = nil
    addedAnimations = nil

    super.tearDown()
  }

  func testNoActionAddsNoAnimations() {
    animator.animate(with: traits) {
      // No-op
    }

    XCTAssertEqual(addedAnimations.count, 0)
  }

  func testOneActionAddsOneAnimation() {
    animator.animate(with: traits) {
      self.view.alpha = 0
    }

    XCTAssertEqual(addedAnimations.count, 1)
    guard addedAnimations.count == 1 else {
      return
    }
    let animation = addedAnimations.first as! CABasicAnimation
    XCTAssertEqual(animation.keyPath, AnimatableKeyPath.opacity.rawValue)
    XCTAssertEqual(animation.fromValue as! CGFloat, 1)
    XCTAssertEqual(animation.toValue as! CGFloat, 0)
    XCTAssertEqual(animation.duration, traits.duration)

    let timingCurve = traits.timingCurve as! CAMediaTimingFunction
    XCTAssertEqualWithAccuracy(timingCurve.mdm_point1.x, animation.timingFunction!.mdm_point1.x,
                               accuracy: 0.001)
    XCTAssertEqualWithAccuracy(timingCurve.mdm_point1.y, animation.timingFunction!.mdm_point1.y,
                               accuracy: 0.001)
    XCTAssertEqualWithAccuracy(timingCurve.mdm_point2.x, animation.timingFunction!.mdm_point2.x,
                               accuracy: 0.001)
    XCTAssertEqualWithAccuracy(timingCurve.mdm_point2.y, animation.timingFunction!.mdm_point2.y,
                               accuracy: 0.001)
  }

  func testTwoActionsAddsTwoAnimations() {
    animator.animate(with: traits) {
      self.view.alpha = 0
      self.view.center = .init(x: 50, y: 50)
    }

    XCTAssertEqual(addedAnimations.count, 2)
    guard addedAnimations.count == 2 else {
      return
    }

    do {
      let animation = addedAnimations.first as! CABasicAnimation
      XCTAssertFalse(animation.isAdditive)
      XCTAssertEqual(animation.keyPath, AnimatableKeyPath.opacity.rawValue)
      XCTAssertEqual(animation.fromValue as! CGFloat, 1)
      XCTAssertEqual(animation.toValue as! CGFloat, 0)
      XCTAssertEqual(animation.duration, traits.duration)

      let timingCurve = traits.timingCurve as! CAMediaTimingFunction
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point1.x, animation.timingFunction!.mdm_point1.x,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point1.y, animation.timingFunction!.mdm_point1.y,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point2.x, animation.timingFunction!.mdm_point2.x,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point2.y, animation.timingFunction!.mdm_point2.y,
                                 accuracy: 0.001)
    }
    do {
      let animation = addedAnimations[1] as! CABasicAnimation
      XCTAssertFalse(animation.isAdditive)
      XCTAssertEqual(animation.keyPath, AnimatableKeyPath.position.rawValue)
      XCTAssertEqual(animation.fromValue as! CGPoint, .init(x: 0, y: 0))
      XCTAssertEqual(animation.toValue as! CGPoint, .init(x: 50, y: 50))
      XCTAssertEqual(animation.duration, traits.duration)

      let timingCurve = traits.timingCurve as! CAMediaTimingFunction
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point1.x, animation.timingFunction!.mdm_point1.x,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point1.y, animation.timingFunction!.mdm_point1.y,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point2.x, animation.timingFunction!.mdm_point2.x,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point2.y, animation.timingFunction!.mdm_point2.y,
                                 accuracy: 0.001)
    }
  }

  func testFrameActionAddsTwoAnimations() {
    animator.animate(with: traits) {
      self.view.frame = .init(x: 0, y: 0, width: 100, height: 100)
    }

    XCTAssertEqual(addedAnimations.count, 2)
    guard addedAnimations.count == 2 else {
      return
    }

    do {
      let animation = addedAnimations
          .flatMap { $0 as? CABasicAnimation }
          .first(where: { $0.keyPath == AnimatableKeyPath.position.rawValue})!
      XCTAssertFalse(animation.isAdditive)
      XCTAssertEqual(animation.fromValue as! CGPoint, .init(x: 0, y: 0))
      XCTAssertEqual(animation.toValue as! CGPoint, .init(x: 50, y: 50))
      XCTAssertEqual(animation.duration, traits.duration)

      let timingCurve = traits.timingCurve as! CAMediaTimingFunction
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point1.x, animation.timingFunction!.mdm_point1.x,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point1.y, animation.timingFunction!.mdm_point1.y,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point2.x, animation.timingFunction!.mdm_point2.x,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point2.y, animation.timingFunction!.mdm_point2.y,
                                 accuracy: 0.001)
    }
    do {
      let animation = addedAnimations
        .flatMap { $0 as? CABasicAnimation }
        .first(where: { $0.keyPath == AnimatableKeyPath.bounds.rawValue})!
      XCTAssertFalse(animation.isAdditive)
      XCTAssertEqual(animation.fromValue as! CGRect, .init(x: 0, y: 0, width: 0, height: 0))
      XCTAssertEqual(animation.toValue as! CGRect, .init(x: 0, y: 0, width: 100, height: 100))
      XCTAssertEqual(animation.duration, traits.duration)

      let timingCurve = traits.timingCurve as! CAMediaTimingFunction
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point1.x, animation.timingFunction!.mdm_point1.x,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point1.y, animation.timingFunction!.mdm_point1.y,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point2.x, animation.timingFunction!.mdm_point2.x,
                                 accuracy: 0.001)
      XCTAssertEqualWithAccuracy(timingCurve.mdm_point2.y, animation.timingFunction!.mdm_point2.y,
                                 accuracy: 0.001)
    }
  }

  func testOneActionAddsNoAnimationWhenActionsDisable() {
    CATransaction.begin()
    CATransaction.setDisableActions(true)

    animator.animate(with: traits) {
      self.view.alpha = 0
    }

    CATransaction.commit()

    XCTAssertEqual(addedAnimations.count, 0)
    XCTAssertEqual(view.alpha, 0)
  }

  func testBackingLayerDoesNotImplicitlyAnimate() {
    CATransaction.begin()
    CATransaction.setAnimationDuration(0.5)

    view.layer.opacity = 0.5

    CATransaction.commit()

    XCTAssertNil(view.layer.animationKeys())
  }

  func testBackingLayerDoesAnimateInsideUIViewAnimateBlock() {
    UIView.animate(withDuration: 0.5) {
      self.view.layer.opacity = 0.5
    }

    XCTAssertNotNil(view.layer.animationKeys)
    if let animationKeys = view.layer.animationKeys() {
      XCTAssertEqual(animationKeys, ["opacity"])
    }
  }

  func testDurationOfZeroRunsAnimationsBlockButGeneratesNoAnimations() {
    let traits = MDMAnimationTraits(duration: 0)

    animator.animate(with: traits) {
      self.view.alpha = 0
    }

    XCTAssertEqual(addedAnimations.count, 0)
    XCTAssertEqual(view.alpha, 0)
  }

  func testTimeScaleFactorOfZeroRunsAnimationsBlockButGeneratesNoAnimations() {
    animator.timeScaleFactor = 0

    animator.animate(with: traits) {
      self.view.alpha = 0
    }

    XCTAssertEqual(addedAnimations.count, 0)
    XCTAssertEqual(view.alpha, 0)
  }

  func testUnsupportedAnimationKeyIsNotAnimated() {
    animator.animate(with: traits) {
      self.view.layer.sublayers = []
    }

    XCTAssertNil(view.layer.animationKeys(),
                 "No animations should have been added, but the following keys were found: "
                  + "\(view.layer.animationKeys()!)")
  }
}
