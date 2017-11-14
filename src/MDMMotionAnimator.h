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

#ifdef IS_BAZEL_BUILD
#import "MotionInterchange.h"
#else
#import <MotionInterchange/MotionInterchange.h>
#endif

#import "MDMAnimatableKeyPaths.h"
#import "MDMCoreAnimationTraceable.h"

/**
 An animator adds Core Animation animations to a layer based on a provided motion timing.
 */
NS_SWIFT_NAME(MotionAnimator)
@interface MDMMotionAnimator : NSObject <MDMCoreAnimationTraceable>

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

 If `additive` is disabled, the animation will be added to the layer with the keyPath as its key.
 In this case, multiple invocations of this function on the same key path will remove the
 animations added from prior invocations.

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

 If `additive` is disabled, the animation will be added to the layer with the keyPath as its key.
 In this case, multiple invocations of this function on the same key path will remove the
 animations added from prior invocations.

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
 Performs `animations` using the timing provided.

 @param timing The timing to be used for the animation.
 @param animations The block to be executed. Any animatable properties changed within this block
 will result in animations being added to the view's layer with the provided timing. The block is
 non-escaping.
 */
- (void)animateWithTiming:(MDMMotionTiming)timing animations:(nonnull void(^)(void))animations;

/**
 Performs `animations` using the timing provided and executes the completion handler once all added
 animations have completed.

 @param timing The timing to be used for the animation.
 @param animations The block to be executed. Any animatable properties changed within this block
 will result in animations being added to the view's layer with the provided timing. The block is
 non-escaping.
 @param completion The completion handler will be executed once all added animations have come to
 rest. The block is escaping and will be released once the animations have completed.
 */
- (void)animateWithTiming:(MDMMotionTiming)timing
               animations:(nonnull void (^)(void))animations
               completion:(nullable void(^)(void))completion;

/**
 Removes every animation added by this animator.

 Removing animations in this manner will give the appearance of each animated layer property
 instantaneously jumping to its animated destination.
 */
- (void)removeAllAnimations;

/**
 Commits the presentation layer value to the model layer value for every active animation's key path
 and then removes every animation.

 This method is most commonly called in reaction to the initiation of a gesture so that any
 in-flight animations are stopped at their current on-screen position.
 */
- (void)stopAllAnimations;

@end
