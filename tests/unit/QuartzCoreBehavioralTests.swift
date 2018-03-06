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

class QuartzCoreBehavioralTests: XCTestCase {
  var layer: CAShapeLayer!

  var window: UIWindow!
  var originalImplementation: IMP?
  override func setUp() {
    super.setUp()

    window = getTestHarnessKeyWindow()
  }

  override func tearDown() {
    layer = nil

    super.tearDown()
  }

  private func rebuildLayer() {
    layer = CAShapeLayer()
    window.layer.addSublayer(layer)

    // Connect our layers to the render server.
    CATransaction.flush()
  }

  func testWhichPropertiesImplicitlyAnimateAdditively() {
    let properties: [AnimatableKeyPath: Any] = [:]
    for (keyPath, value) in properties {
      rebuildLayer()

      layer.setValue(value, forKeyPath: keyPath.rawValue)

      XCTAssertNotNil(layer.animationKeys(),
                      "Expected \(keyPath.rawValue) to generate at least one animation.")
      if let animationKeys = layer.animationKeys() {
        for key in animationKeys {
          let animation = layer.animation(forKey: key) as! CABasicAnimation
          XCTAssertTrue(animation.isAdditive,
                        "Expected \(key) to be additive as a result of animating "
                        + "\(keyPath.rawValue), but it was not: \(animation.debugDescription).")
        }
      }
    }
  }

  func testWhichPropertiesImplicitlyAnimateButNotAdditively() {
    let properties: [AnimatableKeyPath: Any] = [
      .anchorPoint: CGPoint(x: 0.2, y: 0.4),
      .borderWidth: 5,
      .borderColor: UIColor.red,
      .bounds: CGRect(x: 0, y: 0, width: 123, height: 456),
      .cornerRadius: 3,
      .height: 100,
      .opacity: 0.5,
      .position: CGPoint(x: 50, y: 20),
      .rotation: 42,
      .scale: 2.5,
      .shadowColor: UIColor.blue,
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
    for (keyPath, value) in properties {
      rebuildLayer()

      layer.setValue(value, forKeyPath: keyPath.rawValue)

      XCTAssertNotNil(layer.animationKeys(),
                      "Expected \(keyPath.rawValue) to generate at least one animation.")
      if let animationKeys = layer.animationKeys() {
        for key in animationKeys {
          let animation = layer.animation(forKey: key) as! CABasicAnimation
          XCTAssertFalse(animation.isAdditive,
                        "Expected \(key) not to be additive as a result of animating "
                        + "\(keyPath.rawValue), but it was: \(animation.debugDescription).")
        }
      }
    }
  }

  func testWhichPropertiesDoNotImplicitlyAnimate() {
    let properties: [AnimatableKeyPath: Any] = [
      .backgroundColor: UIColor.blue,
    ]
    for (keyPath, value) in properties {
      rebuildLayer()

      layer.setValue(value, forKeyPath: keyPath.rawValue)

      XCTAssertNil(layer.animationKeys(),
                   "Expected \(keyPath.rawValue) not to generate any animations.")
    }
  }
}

