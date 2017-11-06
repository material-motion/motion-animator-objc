# #develop#

 TODO: Enumerate changes.


# 2.0.0

This major release includes several new APIs, bug fixes, and internal cleanup.

## Breaking changes

The animator now adds non-additive animations with the keyPath as the animation key. This is a
behavioral change in that animations will now remove the current animation with the same key.

## Bug fixes

Implicit animations are no longer created when adding animations within a UIView animation block.

## New features

New keypath constants:

- backgroundColor
- position
- rotation
- strokeStart
- strokeEnd

New APIs on CATransaction for setting a transaction-specific timeScaleFactor:

```swift
CATransaction.begin()
CATransaction.mdm_setTimeScaleFactor(0.5)
animator.animate...
CATransaction.commit()
```

## Source changes

* [Add support for customizing the timeScaleFactor as part of a CATransaction (#25)](https://github.com/material-motion/motion-animator-objc/commit/17601b94b19320eb4542fca12ba1fa5a2b487271) (featherless)
* [[breaking] Use the keyPath as the key when the animator is not additive. (#22)](https://github.com/material-motion/motion-animator-objc/commit/bb42e617fc80604e056aee618f953d076f5c8928) (featherless)
* [Disable implicit animations when adding explicit animations in the animator (#20)](https://github.com/material-motion/motion-animator-objc/commit/8be151c06d3769540a5efce9d9f00bbc7e6f1555) (featherless)
* [Move private APIs to the private folder. (#17)](https://github.com/material-motion/motion-animator-objc/commit/ee19fdaad12d8a02f5b8ec655363662dfecc30cc) (featherless)
* [Add rotation, strokeStart, and strokeEnd key paths. (#19)](https://github.com/material-motion/motion-animator-objc/commit/ccdffd5597d5888f63c0a3ef0204cfc9efba2a1f) (featherless)
* [Extract a MDMCoreAnimationTraceable protocol from MotionAnimator. (#18)](https://github.com/material-motion/motion-animator-objc/commit/dbe5c3b5d597e6bad50bfc89b53cf0af95c435bc) (featherless)
* [Add position and backgroundColor as key paths. (#15)](https://github.com/material-motion/motion-animator-objc/commit/38907aef8ec0e29aa01ce9b3c13851226802b464) (featherless)
* [Replace arc with kokoro and bazel support for continuous integration. (#13)](https://github.com/material-motion/motion-animator-objc/commit/2ac68fb1ac4cdf61ba6fc7563a59417d39938074) (featherless)

## API changes

### CATransaction

**new** method: `mdm_timeScaleFactor`.

**new** method: `mdm_setTimeScaleFactor:`.

### Animatable key paths

**new** constant: `MDMKeyPathBackgroundColor`

**new** constant: `MDMKeyPathPosition`

**new** constant: `MDMKeyPathRotation`

**new** constant: `MDMKeyPathStrokeStart`

**new** constant: `MDMKeyPathStrokeEnd`

### MDMCoreAnimationTraceable

**new** protocol: MDMCoreAnimationTraceable

# 1.1.3

This patch release resolves an Xcode 9 build warning.

## Source changes

* [Disable partial availability warning for CASpringAnimation. (#12)](https://github.com/material-motion/motion-animator-objc/commit/e720f9f02b5d0d9d96e3acbba641bac6fba87045) (featherless)

## Non-source changes

* [Update CocoaPods and ensure that warnings are enabled for the project.](https://github.com/material-motion/motion-animator-objc/commit/4a70beb710a492e3162da040ee1ce22caa99c01a) (Jeff Verkoeyen)
* [Add explicit swift version file for CocoaPods.](https://github.com/material-motion/motion-animator-objc/commit/b1b53c3bf648d0fc8c0788d24eb91a92b87f2aba) (Jeff Verkoeyen)

# 1.1.2

Added support for Xcode 7 builds.

## Source changes

* [Resolve Xcode 7 build error. (#11)](https://github.com/material-motion/motion-animator-objc/commit/3e45cbebb8fadca6a75919550b360af944d6af41) (featherless)

# 1.1.1

Bug fix release due to compiler warnings.

## Breaking changes

## New deprecations

## New features

## Source changes

* [Fix compiler warnings due to misconfigured Podfile. (#8)](https://github.com/material-motion/motion-animator-objc/commit/90a8913b1dc76165295cf0bc667575ee211c6411) (featherless)

# 1.1.0

This minor change resolves some Xcode 9 warnings and introduces the ability to speed up or slow down animations.

## New features

- Added a new keypath constant, `MDMKeyPathScale`.
- MDMAnimator animation timing can now be scaled using the new `timeScaleFactor` property.

## Source changes

* [If settlingDuration is unavailable, use the provided spring duration. (#5)](https://github.com/material-motion/motion-animator-objc/commit/4baa99681c0a73180bc0a25019dc575a5fee5ab1) (featherless)
* [Resolve Xcode 9 warnings. (#7)](https://github.com/material-motion/motion-animator-objc/commit/6f84058ca729299261cae0865b8bbb1ccd163179) (featherless)
* [Add a timeScaleFactor API to the animator. (#6)](https://github.com/material-motion/motion-animator-objc/commit/b2a0f96b617edea13517d33b20d8d95b10426bb7) (featherless)
* [Add transform.scale keypath. (#3)](https://github.com/material-motion/motion-animator-objc/commit/9bdf4f6e833283da452797a254a090da61607a2b) (featherless)

# 1.0.1

This is a patch fix release to address build issues within Google's build environment.

## Source changes

* [Add missing header imports.](https://github.com/material-motion/motion-animator-objc/commit/2895dd3e586340018297041d8fce367bf29586c6) (Jeff Verkoeyen)

# 1.0.0

Initial release.

Includes MDMMotionAnimator and a small set of pre-defined animatable key paths.

## Source changes

* [Add support for iOS 8.](https://github.com/material-motion/motion-animator-objc/commit/f83c8ff02a1b99649396e50c11f2dc1ef4dd408f) (Jeff Verkoeyen)
* [Initial commit of MotionAnimator code. (#1)](https://github.com/material-motion/motion-animator-objc/commit/4f816553c409357ead3f9eb27a92066152591664) (featherless)
* [Initial preparation for project.](https://github.com/material-motion/motion-animator-objc/commit/28666dbb46aaebf08e9b284fce7cba280a0736ff) (Jeff Verkoeyen)

## Non-source changes

* [Remove superlatives.](https://github.com/material-motion/motion-animator-objc/commit/5f3367654622c262f4b474be7e1e760814bbff08) (Jeff Verkoeyen)
* [Add more delay to the chip animation.](https://github.com/material-motion/motion-animator-objc/commit/e1af31a0f72b7489431804ccac0eaa5101ef33b0) (Jeff Verkoeyen)
* [Update docs.](https://github.com/material-motion/motion-animator-objc/commit/625ffe117d198421bffcf24a0f56c40203d0f614) (Jeff Verkoeyen)


