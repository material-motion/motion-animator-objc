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


