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

import UIKit
import MotionAnimator

// This demo shows how to the MotionAnimator UIKit-ish APIs for animating properties and is provided
// as a contrast to the TapToBounceTraits example.
class TapToBounceUIKitExampleViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let circle = UIButton()
    circle.bounds = CGRect(x: 0, y: 0, width: 128, height: 128)
    circle.center = view.center
    circle.layer.cornerRadius = circle.bounds.width / 2
    circle.layer.borderColor = UIColor(red: (CGFloat)(0x88) / 255.0,
                                       green: (CGFloat)(0xEF) / 255.0,
                                       blue: (CGFloat)(0xAA) / 255.0,
                                       alpha: 1).cgColor
    circle.backgroundColor = UIColor(red: (CGFloat)(0xEF) / 255.0,
                                     green: (CGFloat)(0x88) / 255.0,
                                     blue: (CGFloat)(0xAA) / 255.0,
                                     alpha: 1)
    view.addSubview(circle)

    circle.addTarget(self, action: #selector(didFocus),
                     for: [.touchDown, .touchDragEnter])
    circle.addTarget(self, action: #selector(didUnfocus),
                     for: [.touchUpInside, .touchUpOutside, .touchDragExit])
  }

  func didFocus(_ sender: UIButton) {
    MotionAnimator.animate(withDuration: 0.8,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0,
                           options: [],
                           animations: {
      sender.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)

      // This would normally not be animatable with the UIView animation APIs, but it is animatable
      // with the motion animator.
      sender.layer.borderWidth = 10
    }, completion: nil)
  }

  func didUnfocus(_ sender: UIButton) {
    MotionAnimator.animate(withDuration: 0.8,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0,
                           options: [],
                           animations: {
      sender.transform = .identity
      sender.layer.borderWidth = 0
    }, completion: nil)
  }
}

