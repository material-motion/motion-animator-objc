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

class ShapeLayerBackedView: UIView {
  override static var layerClass: AnyClass { return CAShapeLayer.self }

  override init(frame: CGRect) {
    super.init(frame: frame)

    let shapeLayer = self.layer as! CAShapeLayer
    shapeLayer.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 100, height: 100)).cgPath
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class UIKitBehavioralTests: XCTestCase {
  var view: UIView!

  var originalImplementation: IMP?
  override func setUp() {
    super.setUp()

    let window = UIWindow()
    window.makeKeyAndVisible()
    view = ShapeLayerBackedView()
    window.addSubview(view)

    rebuildView()
  }

  override func tearDown() {
    view = nil

    super.tearDown()
  }

  private func rebuildView() {
    let oldSuperview = view.superview!
    view.removeFromSuperview()
    view = ShapeLayerBackedView() // Need to animate a view's layer to get implicit animations.
    oldSuperview.addSubview(view)

    // Connect our layers to the render server.
    CATransaction.flush()
  }

  func testSomePropertiesImplicitlyAnimateAdditively() {
    let properties: [AnimatableKeyPath: Any] = [
      .cornerRadius: 3,
      .height: 100,
      .position: CGPoint(x: 50, y: 20),
      .rotation: 42,
      .scale: 2.5,
      .width: 25,
      .x: 12,
      .y: 23,
    ]
    for (keyPath, value) in properties {
      rebuildView()

      UIView.animate(withDuration: 0.01) {
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
    let properties: [AnimatableKeyPath: Any] = [
      .backgroundColor: UIColor.blue,
      .opacity: 0.5,
    ]
    for (keyPath, value) in properties {
      rebuildView()

      UIView.animate(withDuration: 0.01) {
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

  func testSomePropertiesDoNotImplicitlyAnimate() {
    let properties: [AnimatableKeyPath: Any] = [
      .strokeStart: 0.2,
      .strokeEnd: 0.5,
    ]
    for (keyPath, value) in properties {
      rebuildView()

      UIView.animate(withDuration: 0.01) {
        self.view.layer.setValue(value, forKeyPath: keyPath.rawValue)
      }

      XCTAssertNil(view.layer.animationKeys(),
                   "Expected \(keyPath.rawValue) not to generate any animations.")
    }
  }
}

