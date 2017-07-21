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

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import <MotionInterchange/MotionInterchange.h>

#import "MDMAnimatableKeyPaths.h"

/**
 An animator adds Core Animation animations to a layer based on a provided motion timing.
 */
NS_SWIFT_NAME(MotionAnimator)
@interface MDMMotionAnimator : NSObject

/**
 The scaling factor to apply to all time-related values.

 For example, a timeScaleFactor of 2 will double the length of all animations.

 1.0 by default.
 */
@property(nonatomic, assign) CGFloat timeScaleFactor;

/**
 If enabled, all animations will be added with their values reversed.

 Disabled by default.
 */
@property(nonatomic, assign) BOOL shouldReverseValues;

/**
 If enabled, all animations will start from their current presentation value.

 If disabled, animations will start from the first value in the values array.

 Disabled by default.
 */
@property(nonatomic, assign) BOOL beginFromCurrentState;

/**
 If enabled, animations will calculate their values in relation to their destination value.

 Additive animations can be stacked. This is most commonly used to change the destination of an
 animation mid-way through in such a way that momentum appears to be conserved.

 Enabled by default.
 */
@property(nonatomic, assign) BOOL additive;

/**
 Adds a single animation to the layer with the given timing structure.

 @param timing The timing to be used for the animation.
 @param layer The layer to be animated.
 @param values The values to be used in the animation. Must contain exactly two values. Supported
 UIKit types will be coerced to their Core Animation equivalent. Supported UIKit values include
 UIColor and UIBezierPath.
 @param keyPath The key path of the property to be animated.
 */
- (void)animateWithTiming:(MDMMotionTiming)timing
                  toLayer:(nonnull CALayer *)layer
               withValues:(nonnull NSArray *)values
                  keyPath:(nonnull MDMAnimatableKeyPath)keyPath;

/**
 Adds a single animation to the layer with the given timing structure.

 @param timing The timing to be used for the animation.
 @param layer The layer to be animated.
 @param values The values to be used in the animation. Must contain exactly two values. Supported
 UIKit types will be coerced to their Core Animation equivalent. Supported UIKit values include
 UIColor and UIBezierPath.
 @param keyPath The key path of the property to be animated.
 @param completion The completion handler will be executed once this animation has come to rest.
 */
- (void)animateWithTiming:(MDMMotionTiming)timing
                  toLayer:(nonnull CALayer *)layer
               withValues:(nonnull NSArray *)values
                  keyPath:(nonnull MDMAnimatableKeyPath)keyPath
               completion:(nullable void(^)(void))completion;

/**
 Adds a block that will be invoked each time an animation is added to a layer.
 */
- (void)addCoreAnimationTracer:(nonnull void (^)(CALayer * _Nonnull, CAAnimation * _Nonnull))tracer;

@end
