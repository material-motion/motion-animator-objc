/*
 Copyright 2018-present The Material Motion Authors. All Rights Reserved.

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

import Foundation
import UIKit

// Certain test targets (UIKitBehavioralTests's
// testDefaultsAnimatesPositionAdditivelyFromItsModelLayerState and
// testBeginFromCurrentStateAnimatesPositionAdditivelyFromItsModelLayerState) become flaky on iOS
// 8.1 when multiple UIWindow instances are created across multiple tests. Reusing the same key
// window between test instances reduces this flakiness and improves the testing performance
// by a factor of 3 (from ~30s to ~10s overall test time).
func getTestHarnessKeyWindow() -> UIWindow {
  let window: UIWindow
  if let keyWindow = UIApplication.shared.keyWindow {
    window = keyWindow
  } else {
    window = UIWindow()
    window.makeKeyAndVisible()
  }
  return window
}
