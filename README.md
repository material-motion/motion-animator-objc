# Motion Animator

> A Motion Animator creates performant, interruptible animations from motion specs.

[![Build Status](https://travis-ci.org/material-motion/motion-animator-objc.svg?branch=develop)](https://travis-ci.org/material-motion/motion-animator-objc)
[![codecov](https://codecov.io/gh/material-motion/motion-animator-objc/branch/develop/graph/badge.svg)](https://codecov.io/gh/material-motion/motion-animator-objc)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/MotionAnimator.svg)](https://cocoapods.org/pods/MotionAnimator)
[![Platform](https://img.shields.io/cocoapods/p/MotionAnimator.svg)](http://cocoadocs.org/docsets/MotionAnimator)
[![Docs](https://img.shields.io/cocoapods/metrics/doc-percent/MotionAnimator.svg)](http://cocoadocs.org/docsets/MotionAnimator)

This library turns [Motion Interchange](https://github.com/material-motion/motion-interchange-objc)
data structures into performant Core Animation animations using a lightweight animator object.

<img src="assets/chip.gif" />

In the above example we're animating the expansion and collapse of a calendar event using the
following motion specification:

```objc
struct CalendarChipTiming {
  MDMMotionTiming chipWidth;
  MDMMotionTiming chipHeight;
  MDMMotionTiming chipY;

  MDMMotionTiming chipContentOpacity;
  MDMMotionTiming headerContentOpacity;

  MDMMotionTiming navigationBarY;
};
typedef struct CalendarChipTiming CalendarChipTiming;

struct CalendarChipMotionSpec {
  CalendarChipTiming expansion;
  CalendarChipTiming collapse;
};
typedef struct CalendarChipMotionSpec CalendarChipMotionSpec;

FOUNDATION_EXTERN struct CalendarChipMotionSpec CalendarChipSpec;
```

In our application logic, we first determine which motion timing to use and then we create an
instance of `MDMMotionAnimator`. The animator allows us to create animations with the given
motion timing.

```objc
CalendarChipTiming timing = _expanded ? CalendarChipSpec.expansion : CalendarChipSpec.collapse;

MDMMotionAnimator *animator = [[MDMMotionAnimator alloc] init];
animator.shouldReverseValues = !_expanded;

[animator animateWithTiming:timing.chipHeight
                    toLayer:chipView.layer
                 withValues:@[ @(chipFrame.size.height), @(headerFrame.size.height) ]
                    keyPath:MDMKeyPathHeight];
...
```

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

## Example apps/unit tests

Check out a local copy of the repo to access the Catalog application by running the following
commands:

    git clone https://github.com/material-motion/motion-animator-objc.git
    cd motion-animator-objc
    pod install
    open MotionAnimator.xcworkspace

## Guides

1. [Architecture](#architecture)
2. [How to animate a transition](#how-to-animate-a-transition)
3. [How to animate an interruptible transition](#how-to-animate-an-interruptible-transition)

### Architecture

`MDMMotionAnimator` is the primary API provided by this library. You can configure the animations
that an animator creates by modifying its configuration properties. When you're ready to add an
animation to a CALayer instance, call one of the `animate` method variants and an animation will
be added to the layer.

This library depends on [MotionInterchange](https://github.com/material-motion/motion-interchange-objc)
in order to represent motion timing in a consistent fashion.

### How to animate a transition

> This guide assumes that you are animating a two state bi-directional transition.

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

## Contributing

We welcome contributions!

Check out our [upcoming milestones](https://github.com/material-motion/motion-animator-objc/milestones).

Learn more about [our team](https://material-motion.github.io/material-motion/team/),
[our community](https://material-motion.github.io/material-motion/team/community/), and
our [contributor essentials](https://material-motion.github.io/material-motion/team/essentials/).

## License

Licensed under the Apache 2.0 license. See LICENSE for details.
