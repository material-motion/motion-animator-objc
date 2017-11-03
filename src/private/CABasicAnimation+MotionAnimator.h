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

#import "MotionInterchange.h"

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

// Returns a basic animation configured with the provided timing and scale factor.
FOUNDATION_EXPORT
CABasicAnimation *MDMAnimationFromTiming(MDMMotionTiming timing, CGFloat timeScaleFactor);

// Attemps to configure the provided animation to be additive.
// Not all animation value types are supported. If an animation's value type was not supported,
// the animation will not be modified.
FOUNDATION_EXPORT void MDMMakeAnimationAdditive(CABasicAnimation *animation);
