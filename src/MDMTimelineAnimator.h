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
#import "MDMCoreAnimationTraceable.h"

typedef NS_ENUM(NSInteger, MDMTimelineAnimatorState) {
  MDMTimelineAnimatorStateInactive, // The animation is not executing.
  MDMTimelineAnimatorStateActive,   // The animation is executing.
  MDMTimelineAnimatorStateStopped,  // The animation has been stopped and has not transitioned to inactive.
};

typedef NS_ENUM(NSInteger, MDMTimelineAnimatorPosition) {
  MDMTimelineAnimatorPositionPositionEnd,
  MDMTimelineAnimatorPositionPositionStart,
  MDMTimelineAnimatorPositionPositionCurrent,
};

/**
 An animator adds Core Animation animations to a layer based on a provided motion timing.
 */
NS_SWIFT_NAME(TimelineAnimator)
@interface MDMTimelineAnimator : NSObject <MDMCoreAnimationTraceable>

/**
 Initializes an animator with the given duration. The animator object returned by this method begins
 in the UIViewAnimatingStateInactive state. You must explicitly start the animations by calling the
 startAnimation method.
 */
- (nonnull instancetype)initWithDuration:(NSTimeInterval)duration
    NS_DESIGNATED_INITIALIZER;

/**
 Adds the given animations to the animator's queue of animations to be applied when the animator
 transitions to the MDMTimelineAnimatorStateActive state.
 */
- (void)animateWithTiming:(MDMMotionTiming)timing animations:(nonnull void(^)(void))animations;

/**
 The total duration (in seconds) of the overall animation.
 */
@property(nonatomic, readonly) NSTimeInterval duration;

#pragma mark - UIViewAnimating pseudo-conformance

/**
 The current state of the animation.

 This property reflects the current state of the animation. An animator object starts in the
 MDMTimelineAnimatorStateInactive state. Calling the startAnimation or pauseAnimation method changes
 the state to MDMTimelineAnimatorStateActive. Changing the fractionComplete property also moves the
 animator to the active state. The animator remains in the active state until its animations finish,
 at which point it moves back to the inactive state.

 Calling the stopAnimation: method changes the state of the animator to
 MDMTimelineAnimatorStateStopped. When in this state, the animations are stopped and cannot be
 restarted until you call the finishAnimationAtPosition: method, which returns the animator to the
 inactive state.
 */
@property(nonatomic, readonly) MDMTimelineAnimatorState state;

/**
 A Boolean value indicating whether the animation is currently running.

 This property reflects whether the animation is running either in the forward or reverse direction.
 The value of this property is YES only after a call to the startAnimation method. The value is NO
 when the animator is paused or stopped.
 */
@property(nonatomic, readonly, getter=isRunning) BOOL running;

/**
 A Boolean value indicating whether the animation is running in the reverse direction.

 When the value of this property is YES, animations run in the reverse direction—that is, view
 properties animate back to their original values. When the value is NO, view properties animate to
 their intended final values.

 When implementing this property, changes should cause the animation to reverse direction. If you
 allow changes while the animation is running, it is best to pause the animation briefly and then
 start it again in the opposite direction. Once the animation transitions to the
 MDMTimelineAnimatorStateStopped state, you can ignore changes to this property.
 */
@property(nonatomic, getter=isReversed) BOOL reversed;

/**
 The completion percentage of the animation.

 The value of this property is 0.0 at the beginning of the animation and 1.0 at the end of the
 animation. Intermediate values represent progress in the execution of the animation. For example,
 the value 0.5 indicates that the animation is exactly half way complete.

 Assigning a new value to this property causes the animator to update the animation progress to the
 value you specify. You can use this capability to create interactive animations. For example, you
 might use a pan gesture recognizer to update the value based on the completion progress of that
 gesture. You can update the value of this property only while the animator is paused. Changing the
 value of this property on an inactive animator moves it to the active state.
 */
@property(nonatomic) CGFloat fractionComplete;

/**
 Starts the animation from its current position.

 Call this method to start the animations or to resume the animation after they were paused. This
 method sets the state of the animator to MDMTimelineAnimatorStateActive, if it is not already
 there. It is a programmer error to call this method while the state of the animator is set to
 UIViewAnimatingStateStopped.
 */
- (void)startAnimation;

/**
 Starts the animation after the specified delay.

 Call this method to start the animations or to resume a set of paused animations after the
 specified time delay. This method sets the state of the animator to MDMTimelineAnimatorStateActive,
 if it is not already there. It is a programmer error to call this method while the state of the
 animator is set to MDMTimelineAnimatorStateStopped.
 */
- (void)startAnimationAfterDelay:(NSTimeInterval)delay;

/**
 Pauses a running animation at its current position.

 This method pauses running animations at their current values. Calling this method on an inactive
 animator moves its state to MDMTimelineAnimatorStateActive and puts its animations in a paused
 state right away. To resume the animations, call the startAnimation method. If the animation is
 already paused, this method should do nothing. It is a programmer error to call this method while
 the state of the animator is set to UIViewAnimatingStateStopped.
 */
- (void)pauseAnimation;

/**
 Stops the animations at their current positions.

 Call this method when you want to end the animations at their current position. This method removes
 all of the associated animations from the execution stack and sets the values of any animatable
 properties to their current values. This method also updates the state of the animator object based
 on the value of the withoutFinishing parameter.

 If you specify NO for the withoutFinishing parameter, you can subsequently call the
 finishAnimationAtPosition: method to perform the animator’s final actions. For example, a
 UIViewPropertyAnimator object executes its completion blocks when you call this method. You do not
 have to call the finishAnimationAtPosition: method right away, or at all, and you can perform other
 animations before calling that method.
 */
- (void)stopAnimation:(BOOL)withoutFinishing;

/**
 Finishes the animations and returns the animator to the inactive state.

 After putting the animator object into the MDMTimelineAnimatorStateStopped state, call this method
 to perform any final cleanup tasks. It is a programmer error to call this method at any time except
 after a call to the stopAnimation: method where you pass NO for the withoutFinishing parameter.
 Calling this method is not required, but is recommended in cases where you want to ensure that
 completion blocks or other final tasks are performed.
 */
- (void)finishAnimationAtPosition:(MDMTimelineAnimatorPosition)finalPosition;

- (nonnull instancetype)init NS_UNAVAILABLE;

@end
