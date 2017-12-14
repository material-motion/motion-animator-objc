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

class AnimatorBehavioralTests: XCTestCase {
  var window: UIWindow!
  var traits: MDMAnimationTraits!

  var originalImplementation: IMP?
  override func setUp() {
    super.setUp()

    window = UIWindow()
    window.makeKeyAndVisible()

    traits = MDMAnimationTraits(duration: 1)
  }

  override func tearDown() {
    traits = nil
    window = nil

    super.tearDown()
  }

  private let properties: [AnimatableKeyPath: Any] = [
    .backgroundColor: UIColor.blue,
    .borderWidth: 5,
    .borderColor: UIColor.red,
    .bounds: CGRect(x: 0, y: 0, width: 123, height: 456),
    .cornerRadius: 3,
    .height: 100,
    .opacity: 0.5,
    .position: CGPoint(x: 50, y: 20),
    .rotation: 42,
    .scale: 2.5,
    .shadowOffset: CGSize(width: 1, height: 1),
    .shadowOpacity: 0.3,
    .shadowRadius: 5,
    .strokeStart: 0.2,
    .strokeEnd: 0.5,
    .transform: CGAffineTransform(scaleX: 1.5, y: 1.5),
    .width: 25,
    .x: 12,
    .y: 23,
    .z: 3,
  ]

  func testAllKeyPathsExplicitlyAnimateWithLayerBackingUIView() {
    for (keyPath, value) in properties {
      let view = ShapeLayerBackedView()
      window.addSubview(view)

      // Connect our layers to the render server.
      CATransaction.flush()

      let animator = MotionAnimator()
      let initialValue = view.layer.value(forKeyPath: keyPath.rawValue) ?? NSNull()
      animator.animate(with: traits, between: [initialValue, value],
                       layer: view.layer, keyPath: keyPath)

      XCTAssertNotNil(view.layer.animationKeys(),
                      "Expected \(keyPath.rawValue) to generate animations with the following "
                        + "animator configuration: "
                        + "additive = \(animator.additive) "
                        + "beginFromCurrentState = \(animator.beginFromCurrentState)")

      view.removeFromSuperview()
    }
  }

  func testAllKeyPathsImplicitlyAnimateWithLayerBackingUIView() {
    for (keyPath, value) in properties {
      let view = ShapeLayerBackedView()
      window.addSubview(view)

      // Connect our layers to the render server.
      CATransaction.flush()

      let animator = MotionAnimator()
      animator.animate(with: traits) {
        view.layer.setValue(value, forKeyPath: keyPath.rawValue)
      }

      XCTAssertNotNil(view.layer.animationKeys(),
                      "Expected \(keyPath.rawValue) to generate animations with the following "
                        + "animator configuration: "
                        + "additive = \(animator.additive) "
                        + "beginFromCurrentState = \(animator.beginFromCurrentState)")

      view.removeFromSuperview()
    }
  }

  func testAllKeyPathsExplicitlyAnimateWithHeadlessLayer() {
    for (keyPath, value) in properties {
      let layer = CAShapeLayer()
      window.layer.addSublayer(layer)

      // Connect our layers to the render server.
      CATransaction.flush()

      let animator = MotionAnimator()
      let initialValue = layer.value(forKeyPath: keyPath.rawValue) ?? NSNull()
      animator.animate(with: traits, between: [initialValue, value],
                       layer: layer, keyPath: keyPath)

      XCTAssertNotNil(layer.animationKeys(),
                      "Expected \(keyPath.rawValue) to generate animations with the following "
                        + "animator configuration: "
                        + "additive = \(animator.additive) "
                        + "beginFromCurrentState = \(animator.beginFromCurrentState)")

      layer.removeFromSuperlayer()
    }
  }

  func testAllKeyPathsImplicitlyAnimateWithHeadlessLayer() {
    for (keyPath, value) in properties {
      let layer = CAShapeLayer()
      window.layer.addSublayer(layer)

      // Connect our layers to the render server.
      CATransaction.flush()

      let animator = MotionAnimator()
      animator.animate(with: traits) {
        layer.setValue(value, forKeyPath: keyPath.rawValue)
      }

      XCTAssertNotNil(layer.animationKeys(),
                      "Expected \(keyPath.rawValue) to generate animations with the following "
                        + "animator configuration: "
                        + "additive = \(animator.additive) "
                        + "beginFromCurrentState = \(animator.beginFromCurrentState)")

      layer.removeFromSuperlayer()
    }
  }

  func testAllKeyPathsImplicitlyAnimateWithHeadlessLayerWithUIKitAPI() {
    for (keyPath, value) in properties {
      let layer = CAShapeLayer()
      window.layer.addSublayer(layer)

      // Connect our layers to the render server.
      CATransaction.flush()

      MotionAnimator.animate(withDuration: 0.5, animations: {
        layer.setValue(value, forKeyPath: keyPath.rawValue)
      })

      XCTAssertNotNil(layer.animationKeys(), "Expected \(keyPath.rawValue) to generate animations")

      layer.removeFromSuperlayer()
    }
  }
}
