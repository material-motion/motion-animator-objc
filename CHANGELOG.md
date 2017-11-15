# 2.3.0

This minor release introduces new features for working with gestural interactions.

## New features

Added two new methods for removing and stopping running animations.

## Source changes

* [Add support for removing added animations (#42)](https://github.com/material-motion/motion-animator-objc/commit/51ac34ada49013590d1c79480256faef8017624e) (featherless)

## API changes

### MDMMotionAnimator

**new** method: `removeAllAnimations`

**new** method: `stopAllAnimations`

# 2.2.1

This patch release fixes a bug where CGPoint and CGSize spring animations would not properly extract
initial velocity from their motion timings.

## Source changes

* [Fix bug where CGPoint and CGSize animations were not extracting initialVelocity (#39)](https://github.com/material-motion/motion-animator-objc/commit/edabddc16bbd4aff0b7b692486615060d7371fb7) (featherless)

## Non-source changes

* [Add missing sdk_frameworks to the BUILD file. (#40)](https://github.com/material-motion/motion-animator-objc/commit/cef4416cc9ae9477a4463bd8197bc64c64e1c7f0) (featherless)

# 2.2.0

This minor release introduces support for the new initial velocity spring curve value in
MotionInterchange v1.3.0. This release also includes additional public and internal documentation.

## Dependency changes

The minimum MotionInterchange version has been increased to v1.3.0.

## New features

`MDMMotionAnimator` now supports initial velocity for spring curves.

## Source changes

* [Use MotionCurve make methods to create motion timings in the tests. (#38)](https://github.com/material-motion/motion-animator-objc/commit/f80203d711126130a5d58c880bae0cea4c72b6e7) (featherless)
* [Extract initial velocity from the motion timing. (#37)](https://github.com/material-motion/motion-animator-objc/commit/ab431bd2416b43ce601b16fbb4abdb3b9eba851e) (featherless)
* [Silence a deprecation warning in motion interchange 1.3.0.](https://github.com/material-motion/motion-animator-objc/commit/29b551ae730f1a48f37793c65bf14d761a544b6b) (Jeff Verkoeyen)

## Non-source changes

* [Bump MotionInterchange dependency to 1.3.](https://github.com/material-motion/motion-animator-objc/commit/3b543b856df8543d8af4127b8d5536fb31100d3b) (Jeff Verkoeyen)
* [Ensure that deprecations are treated as warnings, not errors, when building with CocoaPods.](https://github.com/material-motion/motion-animator-objc/commit/b1289ea58130aba8e8dc2455989130db9f8be5ed) (Jeff Verkoeyen)
* [Move example project up.](https://github.com/material-motion/motion-animator-objc/commit/800b2996ba39746adbdfe4bf19c18ccc37f2bc91) (Jeff Verkoeyen)
* [Formatting.](https://github.com/material-motion/motion-animator-objc/commit/0a7dac13f196c5d9774fe5f712a0f8b1b0a4026e) (Jeff Verkoeyen)
* [Add more tutorials and rework the introduction.](https://github.com/material-motion/motion-animator-objc/commit/f25998e6d7161ed46f89bdab799c1be678dc98a9) (Jeff Verkoeyen)
* [Add a guide on building motion specs.](https://github.com/material-motion/motion-animator-objc/commit/f34172534d153ff461fc57943abc81605b3349da) (Jeff Verkoeyen)
* [Add jazzy yaml.](https://github.com/material-motion/motion-animator-objc/commit/22e3bfc4a5bbe504f8f7dad3d41804257b50d28f) (Jeff Verkoeyen)

# 2.1.1

This patch release fixes issues with downstream bazel builds.

## Source changes

* [Touch up the block animations docs. (#35)](https://github.com/material-motion/motion-animator-objc/commit/64d6c3107872fc5d430d960c7d87f93799592457) (featherless)
* [Resolve bazel build dependency issues. (#29)](https://github.com/material-motion/motion-animator-objc/commit/94b86e6c4af2702d1153166eb2855fcde8d5c92c) (featherless)

## Non-source changes

* [Fix typo in the changelog.](https://github.com/material-motion/motion-animator-objc/commit/602c656b7fbad73831b6e495003000cfbd59e0e0) (Jeff Verkoeyen)

# 2.1.0

This minor release introduces new implicit animation APIs. These APIs provide a migration path from
existing UIView `animateWithDuration:...` code.

## New features

New APIs for writing implicit animations in UIView style:

```swift
animator.animate(with: timing) {
  view.alpha = 0
}
```

## Source changes

* [Add a unit test verifying that the completion handler is called when duration == 0. (#34)](https://github.com/material-motion/motion-animator-objc/commit/81b140a9b8bd412443fa6822c0838db1a49585a8) (featherless)
* [Add new APIs for implicit animations. (#30)](https://github.com/material-motion/motion-animator-objc/commit/17939797b8ed38a5a51d22fb90b235f1852e4366) (featherless)

## API changes

### MDMMotionAnimator

**new** method: `animateWithTiming:animations:`

**new** method: `animateWithTiming:animations:completion:`

## Non-source changes

* [Update dependencies and lock MotionInterchange to ~> 1.2. (#31)](https://github.com/material-motion/motion-animator-objc/commit/87c7a5c04b11e85d15b78939fcf79a4e67004c18) (featherless)

# 2.0.2

This patch release includes minor fixes for CocoaPods unit tests.

CocoaPods Swift modules require that header dependencies be imported using `<>` notation.

## Source changes

* [Use <> framework import for MDMMotionAnimator.h in order to support module builds. (#28)](https://github.com/material-motion/motion-animator-objc/commit/f8fd0506320c31e1c471477639332b2ccb6b09fc) (featherless)

# 2.0.1

This patch release includes minor fixes for bazel + kokoro continuous integration.

## Source changes

* [Replace framework import with relative import. (#27)](https://github.com/material-motion/motion-animator-objc/commit/f9fd0af201ef7ae01ebc11fb7d2950fcc9116b4e) (featherless)

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


