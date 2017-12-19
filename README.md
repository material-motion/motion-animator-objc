![Motion Animator Banner](img/motion-animator-banner.gif)

> An animator for iOS 8+ that combines the best aspects of modern UIView and CALayer animation APIs.

[![Build Status](https://travis-ci.org/material-motion/motion-animator-objc.svg?branch=develop)](https://travis-ci.org/material-motion/motion-animator-objc)
[![codecov](https://codecov.io/gh/material-motion/motion-animator-objc/branch/develop/graph/badge.svg)](https://codecov.io/gh/material-motion/motion-animator-objc)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/MotionAnimator.svg)](https://cocoapods.org/pods/MotionAnimator)
[![Platform](https://img.shields.io/cocoapods/p/MotionAnimator.svg)](http://cocoadocs.org/docsets/MotionAnimator)

<table>
  <tr><td>🎉</td><td>Implicit and explicit additive animations.</td></tr>
  <tr><td>🎉</td><td>Parameterized motion with the <a href="https://github.com/material-motion/motion-interchange-objc">Interchange</a>.</td></tr>
  <tr><td>🎉</td><td>Provide velocity to animations directly from gesture recognizers.</td></tr>
  <tr><td>🎉</td><td>Maximize frame rates by relying more on Core Animation.</td></tr>
  <tr><td>🎉</td><td>Animatable properties are Swift enum types.</td></tr>
  <tr><td>🎉</td><td>Consistent model layer value expectations.</td></tr>
</table>

The following properties can be implicitly animated using the MotionAnimator on iOS 8 and up:

<table>
  <tr><td>CALayer <tt>anchorPoint</tt></td></tr>
  <tr><td>CALayer <tt>backgroundColor</tt></td><td>UIView <tt>backgroundColor</tt></td></tr>
  <tr><td>CALayer <tt>bounds</tt></td><td>UIView <tt>bounds</tt></td></tr>
  <tr><td>CALayer <tt>borderWidth</tt></td></tr>
  <tr><td>CALayer <tt>borderColor</tt></td></tr>
  <tr><td>CALayer <tt>cornerRadius</tt></td></tr>
  <tr><td>CALayer <tt>height</tt></td><td>UIView <tt>height</tt></td></tr>
  <tr><td>CALayer <tt>opacity</tt></td><td>UIView <tt>alpha</tt></td></tr>
  <tr><td>CALayer <tt>position</tt></td><td>UIView <tt>center</tt></td></tr>
  <tr><td>CALayer <tt>rotation</tt></td><td>UIView <tt>rotation</tt></td></tr>
  <tr><td>CALayer <tt>scale</tt></td><td>UIView <tt>scale</tt></td></tr>
  <tr><td>CALayer <tt>shadowColor</tt></td></tr>
  <tr><td>CALayer <tt>shadowOffset</tt></td></tr>
  <tr><td>CALayer <tt>shadowOpacity</tt></td></tr>
  <tr><td>CALayer <tt>shadowRadius</tt></td></tr>
  <tr><td>CALayer <tt>transform</tt></td><td>UIView <tt>transform</tt></td></tr>
  <tr><td>CALayer <tt>width</tt></td><td>UIView <tt>width</tt></td></tr>
  <tr><td>CALayer <tt>x</tt></td><td>UIView <tt>x</tt></td></tr>
  <tr><td>CALayer <tt>y</tt></td><td>UIView <tt>y</tt></tr>
  <tr><td>CALayer <tt>z</tt></td></td></tr>
  <tr><td>CAShapeLayer <tt>strokeStart</tt></td></tr>
  <tr><td>CAShapeLayer <tt>strokeEnd</tt></td></tr>
</table>

Note: any animatable property can also be animated with MotionAnimator's explicit animation APIs, even if it's not listed in the table above.

> Is a property missing from this list? [We welcome pull requests](https://github.com/material-motion/motion-animator-objc/edit/develop/src/MDMAnimatableKeyPaths.h)!

## MotionAnimator: a drop-in replacement

UIView's implicit animation APIs are also available on the MotionAnimator:

```swift
// Animating implicitly with UIView APIs
UIView.animate(withDuration: 1.0, animations: {
  view.alpha = 0.5
})

// Equivalent MotionAnimator API
MotionAnimator.animate(withDuration: 1.0, animations: {
  view.alpha = 0.5
})
```

But the MotionAnimator allows you to animate more properties — and on more iOS versions:

```swift
UIView.animate(withDuration: 1.0, animations: {
  view.layer.cornerRadius = 10 // Only works on iOS 11 and up
})

MotionAnimator.animate(withDuration: 1.0, animations: {
  view.layer.cornerRadius = 10 // Works on iOS 8 and up
})
```

MotionAnimator makes use of the [MotionInterchange](https://github.com/material-motion/motion-interchange-objc), a standardized format for representing animation traits. This makes it possible to tweak the traits of an animation without rewriting the code that ultimately creates the animation, useful for building tweaking tools and making motion "stylesheets".

```swift
// Want to change a trait of your animation? You'll need to use a different function altogether
// to do so:
UIView.animate(withDuration: 1.0, animations: {
  view.alpha = 0.5
})
UIView.animate(withDuration: 1.0, delay: 0.5, options: [], animations: {
  view.alpha = 0.5
}, completion: nil)

// But with the MotionInterchange, you can create and manipulate the traits of an animation
// separately from its execution.
let traits = MDMAnimationTraits(duration: 1.0)
traits.delay = 0.5

let animator = MotionAnimator()
animator.animate(with: traits, animations: {
  view.alpha = 0.5
})
```

The MotionAnimator can also be used to replace explicit Core Animation code with additive explicit animations:

```swift
let from = 0
let to = 10
// Animating expicitly with Core Animation APIs
let animation = CABasicAnimation(keyPath: "cornerRadius")
animation.fromValue = (from - to)
animation.toValue = 0
animation.isAdditive = true
animation.duration = 1.0
view.layer.add(animation, forKey: animation.keyPath)
view.layer.cornerRadius = to

// Equivalent implicit MotionAnimator API. cornerRadius will be animated additively by default.
view.layer.cornerRadius = 0
MotionAnimator.animate(withDuration: 1, animations: {
  view.layer.cornerRadius = 10
})

// Equivalent explicit MotionAnimator API
// Note that this API will also set the final animation value to the layer's model layer, similar
// to how implicit animations work, and unlike the explicit pure Core Animation implementation
// above.
let animator = MotionAnimator()
animator.animate(with: MDMAnimationTraits(duration: 1.0),
                 between: [0, 10],
                 layer: view.layer,
                 keyPath: .cornerRadius)
```

Springs on iOS require an initial velocity that's normalized by the displacement of the animation. MotionAnimator calculates this for you so that you can directly provide gesture recognizer velocity values:

```swift
// Common variables
let gestureYVelocity = gestureRecognizer.velocity(in: someContainerView).y
let destinationY = 75

// Animating springs implicitly with UIView APIs
let displacement = destinationY - view.position.y
UIView.animate(withDuration: 1.0,
               delay: 0,
               usingSpringWithDamping: 1.0,
               initialSpringVelocity: gestureYVelocity / displacement,
               options: [],
               animations: {
                 view.layer.position = CGPoint(x: view.position.x, y: destinationY)
               },
               completion: nil)

// Equivalent MotionAnimator API
let animator = MotionAnimator()
let traits = MDMAnimationTraits(duration: 1.0)
traits.timingCurve = MDMSpringTimingCurveGenerator(duration: traits.duration,
                                                   dampingRatio: 1.0,
                                                   initialVelocity: gestureYVelocity)
animator.animate(with: traits,
                 between: [view.layer.position.y, destinationY],
                 layer: view.layer,
                 keyPath: .y)
```

## API snippets

### Implicit animations

```swift
MotionAnimator.animate(withDuration: <#T##TimeInterval#>) {
  <#code#>
}
```

```swift
MotionAnimator.animate(withDuration: <#T##TimeInterval#>,
                       delay: <#T##TimeInterval#>,
                       options: <#T##UIViewAnimationOptions#>,
                       animations: {
  <#code#>
})
```

### Explicit animations

```swift
let traits = MDMAnimationTraits(delay: <#T##TimeInterval#>,
                                duration: <#T##TimeInterval#>,
                                animationCurve: <#T##UIViewAnimationCurve#>)
let animator = MotionAnimator()
animator.animate(with: <#T##MDMAnimationTraits#>,
                 between: [<#T##[From (Any)]#>, <#T##[To (Any)]#>],
                 layer: <#T##CALayer#>,
                 keyPath: <#T##AnimatableKeyPath#>)
```

### Animating transitions

```swift
let animator = MotionAnimator()
animator.shouldReverseValues = transition.direction == .backwards

let traits = MDMAnimationTraits(delay: <#T##TimeInterval#>,
                                duration: <#T##TimeInterval#>,
                                animationCurve: <#T##UIViewAnimationCurve#>)
animator.animate(with: <#T##MDMAnimationTraits#>,
                 between: [<#T##[From (Any)]#>, <#T##[To (Any)]#>],
                 layer: <#T##CALayer#>,
                 keyPath: <#T##AnimatableKeyPath#>)
```

### Creating motion specifications

```swift
class MotionSpec {
  static let chipWidth = MDMAnimationTraits(delay: 0.000, duration: 0.350)
  static let chipHeight = MDMAnimationTraits(delay: 0.000, duration: 0.500)
}

let animator = MotionAnimator()
animator.shouldReverseValues = transition.direction == .backwards

animator.animate(with: MotionSpec.chipWidth,
                 between: [<#T##[From (Any)]#>, <#T##[To (Any)]#>],
                 layer: <#T##CALayer#>,
                 keyPath: <#T##AnimatableKeyPath#>)
animator.animate(with: MotionSpec.chipHeight,
                 between: [<#T##[From (Any)]#>, <#T##[To (Any)]#>],
                 layer: <#T##CALayer#>,
                 keyPath: <#T##AnimatableKeyPath#>)
```

### Animating from the current state

```swift
// Will animate any non-additive animations from their current presentation layer value
animator.beginFromCurrentState = true
```

### Debugging animations

```swift
animator.addCoreAnimationTracer { layer, animation in
  print(animation.debugDescription)
}
```

### Stopping animations in reaction to a gesture recognizer

```swift
if gesture.state == .began {
  animator.stopAllAnimations()
}
```

### Removing all animations

```swift
animator.removeAllAnimations()
```

## Main thread animations vs Core Animation

Animation systems on iOS can be split into two general categories: main thread-based and Core Animation.

**Main thread**-based animation systems include UIDynamics, Facebook's [POP](https://github.com/facebook/pop), or anything driven by a CADisplayLink. These animation systems share CPU time with your app's main thread, meaning they're sharing resources with UIKit, text rendering, and any other main-thread bound processes. This also means the animations are subject to *main thread jank*, in other words: dropped frames of animation or "stuttering".

**Core Animation** makes use of the *render server*, an operating system-wide process for animations on iOS. This independence from an app's process allows the render server to avoid main thread jank altogether.

The primary benefit of main thread animations over Core Animation is that Core Animation's list of animatable properties is small and unchangeable, while main thread animations can animate anything in your application. A good example of this is using POP to animate a "time" property, and to map that time to the hands of a clock. This type of behavior cannot be implemented in Core Animation without moving code out of the render server and in to the main thread.

The primary benefit of Core Animation over main thread animations, on the other hand, is that your animations will be much less likely to drop frames simply because your app is busy on its main thread.

When evaluating whether to use a main thread-based animation system or not, check first whether the same animations can be performed in Core Animation instead. If they can, you may be able to offload the animations from your app's main thread by using Core Animation, saving you valuable processing time for other main thread-bound operations.

MotionAnimator is a purely Core Animation-based animator. If you are looking for main thread solutions then check out the following technologies:

- [UIDynamics](https://developer.apple.com/documentation/uikit/animation_and_haptics/uikit_dynamics)
- [POP](https://github.com/facebook/pop)
- [CADisplayLink](https://developer.apple.com/documentation/quartzcore/cadisplaylink)

# Core Animation: a deep dive

> Recommended reading:
>
> - [Building Animation Driven Interfaces](http://asciiwwdc.com/2010/sessions/123)
> - [Core Animation in Practice, Part 1](http://asciiwwdc.com/2010/sessions/424)
> - [Core Animation in Practice, Part 2](http://asciiwwdc.com/2010/sessions/425)
> - [Building Interruptible and Responsive Interactions](http://asciiwwdc.com/2014/sessions/236)
> - [Advanced Graphics and Animations for iOS Apps](http://asciiwwdc.com/2014/sessions/419)
> - [Advances in UIKit Animations and Transitions](http://asciiwwdc.com/2016/sessions/216)
> - [Animating Layer Content](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/CreatingBasicAnimations/CreatingBasicAnimations.html)
> - [Advanced Animation Tricks](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/AdvancedAnimationTricks/AdvancedAnimationTricks.html)
> - [Additive animations: animateWithDuration in iOS 8](http://iosoteric.com/additive-animations-animatewithduration-in-ios-8/)

There are two primary ways to animate with Core Animation on iOS:

1. **implicitly**, with the UIView `animateWithDuration:` APIs, or by setting properties on standalone CALayer instances (those that are **not** backing a UIView), and
2. **explicitly**, with the CALayer `addAnimation:forKey:` APIs.

A subset of UIView's and CALayer's public APIs is animatable by Core Animation. Of these animatable properties, some are implicitly animatable while some are not. Whether a property is animatable or not depends on the context within which it's being animated, and whether an animation is additive or not depends on which animation API is being used. With this matrix of conditions it's understandable that it can sometimes be difficult to know how to effectively make use of Core Animation.

The following quiz helps illustrate that the UIKit and Core Animation APIs can often lead to unintuitive behavior. Try to guess which of the following snippets will generate an animation and, if they do, what the generated animation's duration will be:

> Imagine that each code snippet is a standalone unit test (because [they are](tests/unit/HeadlessLayerImplicitAnimationTests.swift)!).

```swift
let view = UIView()
UIView.animate(withDuration: 0.8, animations: {
  view.alpha = 0.5
})
```

<details>
  <summary>Click to see the answer</summary>
  Generates an animation with duration of 0.8.
</details>

---

```swift
let view = UIView()
UIView.animate(withDuration: 0.8, animations: {
  view.layer.opacity = 0.5
})
```

<details>
  <summary>Click to see the answer</summary>
  Generates an animation with duration of 0.8.
</details>

---

```swift
let view = UIView()
UIView.animate(withDuration: 0.8, animations: {
  view.layer.cornerRadius = 3
})
```

<details>
  <summary>Click to see the answer</summary>
  On iOS 11 and up, generates an animation with duration of 0.8. Older operating systems will not generate an animation.
</details>

---

```swift
let view = UIView()
view.alpha = 0.5
```

<details>
  <summary>Click to see the answer</summary>
  Does not generate an animation.
</details>

---

```swift
let view = UIView()
view.layer.opacity = 0.5
```

<details>
  <summary>Click to see the answer</summary>
  Does not generate an animation.
</details>

---

```swift
let layer = CALayer()
layer.opacity = 0.5
```

<details>
  <summary>Click to see the answer</summary>
  Does not generate an animation.
</details>

---

```swift
let view = UIView()
window.addSubview(view)
let layer = CALayer()
view.layer.addSublayer(layer)

// Pump the run loop once.
RunLoop.main.run(mode: .defaultRunLoopMode, before: .distantFuture)

layer.opacity = 0.5
```

<details>
  <summary>Click to see the answer</summary>
  Generates an animation with duration of 0.25.
</details>

---

```swift
let view = UIView()
window.addSubview(view)
let layer = CALayer()
view.layer.addSublayer(layer)

// Pump the run loop once.
RunLoop.main.run(mode: .defaultRunLoopMode, before: .distantFuture)

UIView.animate(withDuration: 0.8, animations: {
  layer.opacity = 0.5
})
```

<details>
  <summary>Click to see the answer</summary>
  Generates an animation with duration of 0.25. This isn't a typo: standalone layers read from the current CATransaction rather than UIView's parameters when implicitly animating, even when the change happens within a UIView animation block.
</details>

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
