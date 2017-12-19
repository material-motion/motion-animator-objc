![Motion Animator Banner](img/motion-animator-banner.gif)

> An animator for iOS 8+ that combines the best aspects of modern UIView and CALayer animation APIs.

[![Build Status](https://travis-ci.org/material-motion/motion-animator-objc.svg?branch=develop)](https://travis-ci.org/material-motion/motion-animator-objc)
[![codecov](https://codecov.io/gh/material-motion/motion-animator-objc/branch/develop/graph/badge.svg)](https://codecov.io/gh/material-motion/motion-animator-objc)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/MotionAnimator.svg)](https://cocoapods.org/pods/MotionAnimator)
[![Platform](https://img.shields.io/cocoapods/p/MotionAnimator.svg)](http://cocoadocs.org/docsets/MotionAnimator)

<table>
  <tr><td>Implicit and explicit additive animations.</td></tr>
  <tr><td>Parameterized motion with the <a href="https://github.com/material-motion/motion-interchange-objc">Interchange</a>.</td></tr>
  <tr><td>Provide velocity to animations directly from gesture recognizers.</td></tr>
  <tr><td>Maximize frame rates by relying more on Core Animation.</td></tr>
  <tr><td>Animatable properties are Swift enum types.</td></tr>
  <tr><td>Consistent model layer value expectations.</td></tr>
</table>

The following properties can be implicitly animated using the MotionAnimator on iOS 8 and up:

<table>
  <thead><td>CAlayer</td><td>UIView</td></thead>
  <tr><td><tt>anchorPoint</tt></td></tr>
  <tr><td><tt>backgroundColor</tt></td><td><tt>backgroundColor</tt></td></tr>
  <tr><td><tt>bounds</tt></td><td><tt>bounds</tt></td></tr>
  <tr><td><tt>borderWidth</tt></td></tr>
  <tr><td><tt>borderColor</tt></td></tr>
  <tr><td><tt>cornerRadius</tt></td></tr>
  <tr><td><tt>height</tt></td><td><tt>height</tt></td></tr>
  <tr><td><tt>opacity</tt></td><td><tt>alpha</tt></td></tr>
  <tr><td><tt>position</tt></td><td><tt>center</tt></td></tr>
  <tr><td><tt>rotation</tt></td><td><tt>rotation</tt></td></tr>
  <tr><td><tt>scale</tt></td><td><tt>scale</tt></td></tr>
  <tr><td><tt>shadowColor</tt></td></tr>
  <tr><td><tt>shadowOffset</tt></td></tr>
  <tr><td><tt>shadowOpacity</tt></td></tr>
  <tr><td><tt>shadowRadius</tt></td></tr>
  <tr><td><tt>transform</tt></td><td><tt>transform</tt></td></tr>
  <tr><td><tt>width</tt></td><td><tt>width</tt></td></tr>
  <tr><td><tt>x</tt></td><td><tt>x</tt></td></tr>
  <tr><td><tt>y</tt></td><td><tt>y</tt></tr>
  <tr><td><tt>z</tt></td></td></tr>
  <tr><td>CAShapeLayer <tt>strokeStart</tt></td></tr>
  <tr><td>CAShapeLayer <tt>strokeEnd</tt></td></tr>
</table>

Note: any animatable property can also be animated with MotionAnimator's explicit animation APIs, even if it's not listed in the table above.

> Is a property missing from this list? [We welcome pull requests](https://github.com/material-motion/motion-animator-objc/edit/develop/src/MDMAnimatableKeyPaths.h)!

## Example apps/unit tests

Check out a local copy of the repo to access the Catalog application by running the following
commands:

    git clone https://github.com/material-motion/motion-animator-objc.git
    cd motion-animator-objc
    pod install
    open MotionAnimator.xcworkspace

## Installation

### Installation with CocoaPods

> CocoaPods is a dependency manager for Objective-C and Swift libraries. CocoaPods automates the
> process of using third-party libraries in your projects. See
> [the Getting Started guide](https://guides.cocoapods.org/using/getting-started.html) for more
> information. You can install it with the following command:
>
>     gem install cocoapods

Add `motion-animator` to your `Podfile`:

    pod 'MotionAnimator'

Then run the following command:

    pod install

### Usage

Import the framework:

    @import MotionAnimator;

You will now have access to all of the APIs.

## Guides

- [How to make a spec from existing animations](#how-to-make-a-spec-from-existing-animations)
- [How to animate explicit layer properties](#how-to-animate-explicit-layer-properties)
- [How to animate like UIView](#how-to-animate-like-UIView)
- [How to animate a transition](#how-to-animate-a-transition)
- [How to animate an interruptible transition](#how-to-animate-an-interruptible-transition)

### How to make a spec from existing animations

A *motion spec* is a complete representation of the motion curves that meant to be applied during an
animation. Your motion spec might consist of a single `MDMMotionTiming` instance, or it might be a
nested structure of `MDMMotionTiming` instances, each representing motion for a different part of a
larger animation. In either case, your magic motion constants now have a place to live.

Consider a simple example of animating a view on and off-screen. Without a spec, our code might look
like so:

```objc
CGPoint before = dismissing ? onscreen : offscreen;
CGPoint after = dismissing ? offscreen : onscreen;
view.center = before;
[UIView animateWithDuration:0.5 animations:^{
  view.center = after;
}];
```

What if we want to change this animation to use a spring curve instead of a cubic bezier? To do so
we'll need to change our code to use a new API:

```objc
CGPoint before = dismissing ? onscreen : offscreen;
CGPoint after = dismissing ? offscreen : onscreen;
view.center = before;
[UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:0 animations:^{
  view.center = after;
} completion:nil];
```

Now let's say we wrote the same code with a motion spec and animator:

```objc
MDMMotionTiming motionSpec = {
  .duration = 0.5, .curve = MDMMotionCurveMakeSpring(1, 100, 1),
};

MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];
animator.shouldReverseValues = dismissing;
view.center = offscreen;
[_animator animateWithTiming:kMotionSpec animations:^{
  view.center = onscreen;
}];
```

Now if we want to change our motion back to an easing curve, we only have to change the spec:

```objc
MDMMotionTiming motionSpec = {
  .duration = 0.5, .curve = MDMMotionCurveMakeBezier(0.4f, 0.0f, 0.2f, 1.0f),
};
```

The animator code stays the same. It's now possible to modify the motion parameters at runtime
without affecting any of the animation logic.

This pattern is useful for building transitions and animations. To learn more through examples,
see the following implementations:

**Material Components Activity Indicator**

- [Motion spec declaration](https://github.com/material-components/material-components-ios/blob/develop/components/ActivityIndicator/src/private/MDCActivityIndicatorMotionSpec.h)
- [Motion spec definition](https://github.com/material-components/material-components-ios/blob/develop/components/ActivityIndicator/src/private/MDCActivityIndicatorMotionSpec.m)
- [Motion spec usage](https://github.com/material-components/material-components-ios/blob/develop/components/ActivityIndicator/src/MDCActivityIndicator.m#L461)

**Material Components Progress View**

- [Motion spec declaration](https://github.com/material-components/material-components-ios/blob/develop/components/ProgressView/src/private/MDCProgressView%2BMotionSpec.h#L21)
- [Motion spec definition](https://github.com/material-components/material-components-ios/blob/develop/components/ProgressView/src/private/MDCProgressView%2BMotionSpec.m#L19)
- [Motion spec usage](https://github.com/material-components/material-components-ios/blob/develop/components/ProgressView/src/MDCProgressView.m#L155)

**Material Components Masked Transition**

- [Motion spec declaration](https://github.com/material-components/material-components-ios/blob/develop/components/MaskedTransition/src/private/MDCMaskedTransitionMotionSpec.h#L20)
- [Motion spec definition](https://github.com/material-components/material-components-ios/blob/develop/components/MaskedTransition/src/private/MDCMaskedTransitionMotionSpec.m#L23)
- [Motion spec usage](https://github.com/material-components/material-components-ios/blob/develop/components/MaskedTransition/src/MDCMaskedTransition.m#L183)

### How to animate explicit layer properties

`MDMMotionAnimator` provides an explicit API for adding animations to animatable CALayer key paths.
This API is similar to creating a `CABasicAnimation` and adding it to the layer.

```objc
[animator animateWithTiming:timing.chipHeight
                    toLayer:chipView.layer
                 withValues:@[ @(chipFrame.size.height), @(headerFrame.size.height) ]
                    keyPath:MDMKeyPathHeight];
```

### How to animate like UIView

`MDMMotionAnimator` provides an API that is similar to UIView's `animateWithDuration:`. Use this API
when you want to apply the same timing to a block of animations:

```objc
chipView.frame = chipFrame;
[animator animateWithTiming:timing.chipHeight animations:^{
  chipView.frame = headerFrame;
}];
// chipView.layer's position and bounds will now be animated with timing.chipHeight's timing.
```

### How to animate a transition

Start by creating an `MDMMotionAnimator` instance.

```objc
MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];
```

When we describe our transition we'll describe it as though we're moving forward and take advantage
of the `shouldReverseValues` property on our animator to handle the reverse direction.

```objc
animator.shouldReverseValues = isTransitionReversed;
```

To animate a property on a view, we invoke the `animate` method. We must provide a timing, values,
and a key path:

```objc
[animator animateWithTiming:timing
                    toLayer:view.layer
                 withValues:@[ @(collapsedHeight), @(expandedHeight) ]
                    keyPath:MDMKeyPathHeight];
```

### How to animate an interruptible transition

`MDMMotionAnimator` is configured by default to generate interruptible animations using Core
Animation's additive animation APIs. You can simply re-execute the `animate` calls when your
transition's direction changes and the animator will add new animations for the updated direction.

## Helpful literature

- [Additive animations: animateWithDuration in iOS 8](http://iosoteric.com/additive-animations-animatewithduration-in-ios-8/)
- [WWDC 2014 video on additive animations](https://developer.apple.com/videos/play/wwdc2014/236/)

## Contributing

We welcome contributions!

Check out our [upcoming milestones](https://github.com/material-motion/motion-animator-objc/milestones).

Learn more about [our team](https://material-motion.github.io/material-motion/team/),
[our community](https://material-motion.github.io/material-motion/team/community/), and
our [contributor essentials](https://material-motion.github.io/material-motion/team/essentials/).

## License

Licensed under the Apache 2.0 license. See LICENSE for details.
