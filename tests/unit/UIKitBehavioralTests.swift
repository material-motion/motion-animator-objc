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
  var window: UIWindow!

  override func setUp() {
    super.setUp()

    window = getTestHarnessKeyWindow()

    rebuildView()
  }

  override func tearDown() {
    view = nil
    window = nil

    super.tearDown()
  }

  private func rebuildView() {
    window.subviews.forEach { $0.removeFromSuperview() }
    view = ShapeLayerBackedView() // Need to animate a view's layer to get implicit animations.
    view.layer.anchorPoint = .zero
    window.addSubview(view)

    // Connect our layers to the render server.
    CATransaction.flush()
  }

  // MARK: Each animatable property needs to be added to exactly one of the following three tests

  func testSomePropertiesImplicitlyAnimateAdditively() {
    let baselineProperties: [AnimatableKeyPath: Any] = [
      .bounds: CGRect(x: 0, y: 0, width: 123, height: 456),
      .height: 100,
      .position: CGPoint(x: 50, y: 20),
      .rotation: 42,
      .scale: 2.5,
      .transform: CGAffineTransform(scaleX: 1.5, y: 1.5),
      .width: 25,
      .x: 12,
      .y: 23,
    ]
    let properties: [AnimatableKeyPath: Any]
    if #available(iOS 11.0, *) {
      // Corner radius became implicitly animatable in iOS 11.
      var baselineWithCornerRadiusProperties = baselineProperties
      baselineWithCornerRadiusProperties[.cornerRadius] = 3
      properties = baselineWithCornerRadiusProperties
    } else {
      properties = baselineProperties
    }
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
    let baselineProperties: [AnimatableKeyPath: Any] = [
      .backgroundColor: UIColor.blue,
      .opacity: 0.5,
    ]
    let properties: [AnimatableKeyPath: Any]
    if #available(iOS 11.0, *) {
      // Anchor point became implicitly animatable in iOS 11.
      var baselineWithCornerRadiusProperties = baselineProperties
      baselineWithCornerRadiusProperties[.anchorPoint] = CGPoint(x: 0.2, y: 0.4)
      properties = baselineWithCornerRadiusProperties
    } else {
      properties = baselineProperties
    }
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
    let baselineProperties: [AnimatableKeyPath: Any] = [
      .anchorPoint: CGPoint(x: 0.2, y: 0.4),
      .borderWidth: 5,
      .borderColor: UIColor.red,
      .cornerRadius: 3,
      .shadowColor: UIColor.blue,
      .shadowOffset: CGSize(width: 1, height: 1),
      .shadowOpacity: 0.3,
      .shadowRadius: 5,
      .strokeStart: 0.2,
      .strokeEnd: 0.5,
      .z: 3,
    ]

    let properties: [AnimatableKeyPath: Any]
    if #available(iOS 11.0, *) {
      // Corner radius became implicitly animatable in iOS 11.
      var baselineWithOutCornerRadius = baselineProperties
      baselineWithOutCornerRadius.removeValue(forKey: .anchorPoint)
      baselineWithOutCornerRadius.removeValue(forKey: .cornerRadius)
      properties = baselineWithOutCornerRadius

    } else {
      properties = baselineProperties
    }

    for (keyPath, value) in properties {
      rebuildView()

      UIView.animate(withDuration: 0.01) {
        self.view.layer.setValue(value, forKeyPath: keyPath.rawValue)
      }

      XCTAssertNil(view.layer.animationKeys(),
                   "Expected \(keyPath.rawValue) not to generate any animations.")
    }
  }

  // MARK: Every animatable layer property must be added to the following test

  func testNoPropertiesImplicitlyAnimateOutsideOfAnAnimationBlock() {
    let properties: [AnimatableKeyPath: Any] = [
      .backgroundColor: UIColor.blue,
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
    ]
    for (keyPath, value) in properties {
      rebuildView()

      self.view.layer.setValue(value, forKeyPath: keyPath.rawValue)

      XCTAssertNil(view.layer.animationKeys(),
                   "Expected \(keyPath.rawValue) not to generate any animations.")
    }
  }

  // MARK: .beginFromCurrentState option behavior
  //
  // The following tests indicate that UIKit treats .beginFromCurrentState differently depending
  // on the key path being animated. This difference is in line with whether or not a key path is
  // animated additively or not.
  //
  // > See testSomePropertiesImplicitlyAnimateAdditively and
  // > testSomePropertiesImplicitlyAnimateButNotAdditively for a list of which key paths are
  // > animated which way.
  //
  // Notably, ONLY non-additive key paths are affected by the beginFromCurrentState option. This
  // likely became the case starting in iOS 8 when additive animations were enabled by default.
  // Additive animations will always animate additively regardless of whether or not you provide
  // this flag.

  func testDefaultsAnimatesOpacityNonAdditivelyFromItsModelLayerState() {
    UIView.animate(withDuration: 0.1) {
      self.view.alpha = 0.5
    }

    RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.01))

    let initialValue = self.view.layer.opacity

    UIView.animate(withDuration: 0.1) {
      self.view.alpha = 0.2
    }

    XCTAssertNotNil(view.layer.animationKeys(),
                    "Expected an animation to be added, but none were found.")
    guard let animationKeys = view.layer.animationKeys() else {
      return
    }
    XCTAssertEqual(animationKeys.count, 1,
                   "Expected only one animation to be added, but the following were found: "
                    + "\(animationKeys).")
    guard let key = animationKeys.first,
      let animation = view.layer.animation(forKey: key) as? CABasicAnimation else {
        return
    }

    XCTAssertFalse(animation.isAdditive, "Expected the animation not to be additive, but it was.")

    XCTAssertTrue(animation.fromValue is Float,
                  "The animation's from value was not a number type: "
                    + String(describing: animation.fromValue))
    guard let fromValue = animation.fromValue as? Float else {
      return
    }

    XCTAssertEqualWithAccuracy(fromValue, initialValue, accuracy: 0.0001,
                               "Expected the animation to start from \(initialValue), "
                                + "but it did not.")
  }

  func testBeginFromCurrentStateAnimatesOpacityNonAdditivelyFromItsPresentationLayerState() {
    UIView.animate(withDuration: 0.1) {
      self.view.alpha = 0.5
    }

    RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.01))

    let initialValue = self.view.layer.presentation()!.opacity

    UIView.animate(withDuration: 0.1, delay: 0, options: .beginFromCurrentState, animations: { 
      self.view.alpha = 0.2
    }, completion: nil)

    XCTAssertNotNil(view.layer.animationKeys(),
                    "Expected an animation to be added, but none were found.")
    guard let animationKeys = view.layer.animationKeys() else {
      return
    }
    XCTAssertEqual(animationKeys.count, 1,
                   "Expected only one animation to be added, but the following were found: "
                    + "\(animationKeys).")
    guard let key = animationKeys.first,
      let animation = view.layer.animation(forKey: key) as? CABasicAnimation else {
        return
    }

    XCTAssertFalse(animation.isAdditive, "Expected the animation not to be additive, but it was.")

    XCTAssertTrue(animation.fromValue is Float,
                  "The animation's from value was not a number type: "
                    + String(describing: animation.fromValue))
    guard let fromValue = animation.fromValue as? Float else {
      return
    }

    XCTAssertEqualWithAccuracy(fromValue, initialValue, accuracy: 0.0001,
                               "Expected the animation to start from \(initialValue), "
                                + "but it did not.")
  }

  func testDefaultsAnimatesPositionAdditivelyFromItsModelLayerState() {
    UIView.animate(withDuration: 0.1) {
      self.view.layer.position = CGPoint(x: 100, y: self.view.layer.position.y)
    }

    RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.01))

    let initialValue = self.view.layer.position

    UIView.animate(withDuration: 0.1) {
      self.view.layer.position = CGPoint(x: 20, y: self.view.layer.position.y)
    }

    let displacement = initialValue.x - self.view.layer.position.x

    XCTAssertNotNil(view.layer.animationKeys(),
                    "Expected an animation to be added, but none were found.")
    guard let animationKeys = view.layer.animationKeys() else {
      return
    }
    XCTAssertEqual(animationKeys.count, 2,
                   "Expected two animations to be added, but the following were found: "
                    + "\(animationKeys).")
    guard let key = animationKeys.first(where: { $0 != "position" }),
      let animation = view.layer.animation(forKey: key) as? CABasicAnimation else {
        return
    }

    XCTAssertTrue(animation.isAdditive, "Expected the animation to be additive, but it wasn't.")

    XCTAssertTrue(animation.fromValue is CGPoint,
                  "The animation's from value was not a point type: "
                    + String(describing: animation.fromValue))
    guard let fromValue = animation.fromValue as? CGPoint else {
      return
    }

    XCTAssertEqualWithAccuracy(fromValue.x, displacement, accuracy: 0.0001,
                               "Expected the animation to have a delta of \(displacement), "
                                + "but it did not.")
  }

  func testBeginFromCurrentStateAnimatesPositionAdditivelyFromItsModelLayerState() {
    UIView.animate(withDuration: 0.1) {
      self.view.layer.position = CGPoint(x: 100, y: self.view.layer.position.y)
    }

    RunLoop.main.run(until: .init(timeIntervalSinceNow: 0.01))

    let initialValue = self.view.layer.position

    UIView.animate(withDuration: 0.1, delay: 0, options: .beginFromCurrentState, animations: {
      self.view.layer.position = CGPoint(x: 20, y: self.view.layer.position.y)
    }, completion: nil)

    let displacement = initialValue.x - self.view.layer.position.x

    XCTAssertNotNil(view.layer.animationKeys(),
                    "Expected an animation to be added, but none were found.")
    guard let animationKeys = view.layer.animationKeys() else {
      return
    }
    XCTAssertEqual(animationKeys.count, 2,
                   "Expected two animations to be added, but the following were found: "
                    + "\(animationKeys).")
    guard let key = animationKeys.first(where: { $0 != "position" }),
      let animation = view.layer.animation(forKey: key) as? CABasicAnimation else {
        return
    }

    XCTAssertTrue(animation.isAdditive, "Expected the animation to be additive, but it wasn't.")

    XCTAssertTrue(animation.fromValue is CGPoint,
                  "The animation's from value was not a point type: "
                    + String(describing: animation.fromValue))
    guard let fromValue = animation.fromValue as? CGPoint else {
      return
    }

    XCTAssertEqualWithAccuracy(fromValue.x, displacement, accuracy: 0.0001,
                               "Expected the animation to have a delta of \(displacement), "
                                + "but it did not.")
  }

}
