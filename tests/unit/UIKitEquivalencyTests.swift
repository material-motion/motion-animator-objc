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

class UIKitEquivalencyTests: XCTestCase {
  var view: UIView!
  var window: UIWindow!

  var originalImplementation: IMP?
  override func setUp() {
    super.setUp()

    window = getTestHarnessKeyWindow()
    view = ShapeLayerBackedView()
    window.addSubview(view)

    rebuildView()
  }

  override func tearDown() {
    view = nil
    window = nil

    super.tearDown()
  }

  private func rebuildView() {
    view.removeFromSuperview()
    view = ShapeLayerBackedView() // Need to animate a view's layer to get implicit animations.
    view.layer.anchorPoint = .zero
    window.addSubview(view)

    // Connect our layers to the render server.
    CATransaction.flush()
  }

  // MARK: Each animatable property needs to be added to exactly one of the following three tests

  func testMostPropertiesImplicitlyAnimateAdditively() {
    let baselineProperties: [AnimatableKeyPath: Any] = [
      .borderWidth: 5,
      .cornerRadius: 3,
      .position: CGPoint(x: 50, y: 20),
      .rotation: 42,
      .scale: 2.5,
      .shadowOffset: CGSize(width: 1, height: 1),
      .shadowOpacity: 0.3,
      .shadowRadius: 5,
      .strokeStart: 0.2,
      .strokeEnd: 0.5,
      .transform: CGAffineTransform(scaleX: 1.5, y: 1.5),
      .x: 12,
      .y: 23,
      .z: 3,

      // Should animate additively, but blocked by
      // https://github.com/material-motion/motion-animator-objc/issues/74
      //.bounds: CGRect(x: 0, y: 0, width: 123, height: 456),
      //.height: 100,
      //.width: 25,
    ]
    for (keyPath, value) in baselineProperties {
      rebuildView()

      MotionAnimator.animate(withDuration: 0.01) {
        self.view.layer.setValue(value, forKeyPath: keyPath.rawValue)
      }

      XCTAssertNotNil(view.layer.animationKeys(),
                      "Expected \(keyPath.rawValue) to generate at least one animation.")
      if let animationKeys = view.layer.animationKeys() {
        for key in animationKeys {
          let animation = view.layer.animation(forKey: key) as! CABasicAnimation
          XCTAssertTrue(animation.isAdditive,
                        "Expected \(key) to be additive as a result of animating "
                        + "\(keyPath.rawValue), but it was not: \(animation.debugDescription).")
        }
      }
    }
  }

  func testSomePropertiesImplicitlyAnimateButNotAdditively() {
    let baselineProperties: [AnimatableKeyPath: Any] = [
      .anchorPoint: CGPoint(x: 0.2, y: 0.4),
      .backgroundColor: UIColor.blue,
      .borderColor: UIColor.red,
      .opacity: 0.5,
      .shadowColor: UIColor.blue,
    ]
    for (keyPath, value) in baselineProperties {
      rebuildView()

      MotionAnimator.animate(withDuration: 0.01) {
        self.view.layer.setValue(value, forKeyPath: keyPath.rawValue)
      }

      XCTAssertNotNil(view.layer.animationKeys(),
                      "Expected \(keyPath.rawValue) to generate at least one animation.")
      if let animationKeys = view.layer.animationKeys() {
        for key in animationKeys {
          let animation = view.layer.animation(forKey: key) as! CABasicAnimation
          XCTAssertFalse(animation.isAdditive,
                        "Expected \(key) not to be additive as a result of animating "
                        + "\(keyPath.rawValue), but it was: \(animation.debugDescription).")
        }
      }
    }
  }

}
