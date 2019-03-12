# 4.0.0

This major release drops official support for iOS 8 and fixes a static analyzer warning.

## Source changes

* [Resolve a static analyzer warning. (#124)](https://github.com/material-motion/motion-animator-objc/commit/0dce7f8c521e321cb904e9fbe3dc5880e623d6d8) (featherless)

## Non-source changes

* [Ran pod install with latest cocoapods. (#123)](https://github.com/material-motion/motion-animator-objc/commit/953f7505cc85d66dcd88c4c306765d22ea73c230) (featherless)
* [Drop support for iOS 8 (#122)](https://github.com/material-motion/motion-animator-objc/commit/ecb75418b8d86cc34041a675c89abc12ad4e509a) (featherless)

# 3.0.0

This major release upgrades the bazel dependencies and workspace. This change is breaking for anyone
using bazel to build this library. In order to use this library with bazel, you will also need to
upgrade your workspace versions to match the ones now used in this library's `WORKSPACE` file.

## Source changes

* [Make tests more robust to crashing failures. (#118)](https://github.com/material-motion/motion-animator-objc/commit/d2f5971a554d2e63b74a3ad7d36cd9b7ed7823ca) (featherless)

## Non-source changes

* [Automatic changelog preparation for release.](https://github.com/material-motion/motion-animator-objc/commit/2f7d3af5fd9cf6bdcb88e0b955e7ceb903dc9b22) (Jeff Verkoeyen)
* [Update bazel workspace to latest versions. (#120)](https://github.com/material-motion/motion-animator-objc/commit/e28f79e51bbfa7a41d7c9941e7a0ba7beaaa05ff) (featherless)
* [Don't animate system views with the animator. (#119)](https://github.com/material-motion/motion-animator-objc/commit/c8057832a9f961585978d59a7ea03e8f641d8ae6) (featherless)
* [Update .travis.yml](https://github.com/material-motion/motion-animator-objc/commit/e839e817c80aa8df34faacf7fe95d6fb1d508643) (featherless)
* [Update .kokoro](https://github.com/material-motion/motion-animator-objc/commit/4eed01c25d7fd84fe9e48f147f195987ebbf26e9) (featherless)
* [Update .kokoro](https://github.com/material-motion/motion-animator-objc/commit/55dd1b14f243418bf4d4fe4ea0eb0a6bcfbb88de) (featherless)
* [Update bazel workspace and version to latest. (#117)](https://github.com/material-motion/motion-animator-objc/commit/b8261f30f3437c75e8bc1b9f25c074304acc43b5) (featherless)

# 2.8.1

This patch release resolves some runtime crashes, improves the stability of our unit tests, and features an improved README.md.

## Bug fixes

Fixed unrecognized selector crashes on iOS 8 devices.

Fixed crashes in Legacy API when providing nil completion blocks.

## Source changes

* [Ensure that zero duration test is testing with zero duration. (#115)](https://github.com/material-motion/motion-animator-objc/commit/66842d1c8fd865c39e0955b3a25becb775023818) (featherless)
* [Reduce flakiness in UIKitBehavioralTests. (#113)](https://github.com/material-motion/motion-animator-objc/commit/b45a6c4a20db5529a11fb5c9c64b52a916a15fa7) (featherless)
* [Return `nil` CAAction when swapping implementation (#109)](https://github.com/material-motion/motion-animator-objc/commit/53255ab590908cc18841e3eed4af440e52132376) (Robert Moore)
* [Fix crash in Legacy API for nil completion blocks (#110)](https://github.com/material-motion/motion-animator-objc/commit/fd9710d220bb48a64ac008a399be74d04f6ab8b7) (Robert Moore)

## Non-source changes

* [Iterating on the readme. (#102)](https://github.com/material-motion/motion-animator-objc/commit/97d7bcd7d8549398e9ac176a15ab028b898781a6) (featherless)
* [Update .travis.yml (#114)](https://github.com/material-motion/motion-animator-objc/commit/891f25c08e6e7ae5105867a97bfe6823f09e55fd) (featherless)
* [Add core animation quiz to the readme. (#108)](https://github.com/material-motion/motion-animator-objc/commit/05ad80b7074eadb3131543292b11f18837d91e6b) (featherless)
* [Add readme section on main thread animations vs Core Animation. (#107)](https://github.com/material-motion/motion-animator-objc/commit/ccd350d1fbdb8a95b6922bf99680d10183a91f90) (featherless)
* [Add API snippets section. (#106)](https://github.com/material-motion/motion-animator-objc/commit/823e0ffa286a6918aaf67b3a6070dab16cfa775d) (featherless)
* [Add drop in replacement APIs section to the readme (#105)](https://github.com/material-motion/motion-animator-objc/commit/d53f753a976b1d067d226ed9bfd1893875d4ab8d) (featherless)
* [Add a feature table to the readme. (#104)](https://github.com/material-motion/motion-animator-objc/commit/0632c668e26347208d60c464e683774cd9dab5b7) (featherless)

# 2.8.0

This minor release introduces support for animating more key paths and support for drop-in UIView animation API replacements.

## New features

The MotionAnimator can now implicitly animate the following CALayer properties: `anchorPoint`, `borderWidth`, `borderColor`, `shadowColor`, and `zPosition`.

There are now UIKit equivalency APIs that can be used as drop-in replacements for existing UIView animation code.

## Source changes

* [Add IS_BAZEL_BUILD around MotionInterchange import (#103)](https://github.com/material-motion/motion-animator-objc/commit/042eb8cb46c077121f817d5e8ebc7b51d4ec54b9) (Louis Romero)
* [Anchor point became animatable on iOS 11.](https://github.com/material-motion/motion-animator-objc/commit/a56cd92874440b975591e421eaad8d4ef28cb9d4) (Jeff Verkoeyen)
* [Add support for animating anchorPoint. (#97)](https://github.com/material-motion/motion-animator-objc/commit/646b6f6fd1ed3a10dae7ab4e98caa43cad65f2ff) (featherless)
* [Add support for animating shadow color. (#99)](https://github.com/material-motion/motion-animator-objc/commit/ca896623a4e5a42a458e6fd59c8f405b55e87e26) (featherless)
* [Add support for animating border width and color. (#98)](https://github.com/material-motion/motion-animator-objc/commit/55c23d5c4f8029cc45f6331a894ddf1960863ba7) (featherless)
* [Add support for animating z position. (#96)](https://github.com/material-motion/motion-animator-objc/commit/23cd380bf2414b2834da7f8d55548cd00166d6f8) (featherless)
* [Add support for additively animating bounds. (#93)](https://github.com/material-motion/motion-animator-objc/commit/32c78d4d93b6c82ff55693c54176b2826f718e5e) (featherless)
* [Improve the documentation for initial velocity. (#94)](https://github.com/material-motion/motion-animator-objc/commit/e260418023430e0541360ec46ed6d4d931dbf05c) (featherless)
* [Standardize our param docs formatting. (#95)](https://github.com/material-motion/motion-animator-objc/commit/024296aca338b106cf49b87fcc83b9feb216ee9d) (featherless)
* [Add back test properties that were accidentally removed in 69469aedb987e516ff1f43a123b3ee29dfef38ca.](https://github.com/material-motion/motion-animator-objc/commit/e41ccb4890b9ed3bad5ab52015f8224adb5bbba6) (Jeff Verkoeyen)
* [Add support for using a spring generator as a timing curve. (#91)](https://github.com/material-motion/motion-animator-objc/commit/46fd517e18b3a9555e46dcdd942601dd4ccd5149) (featherless)
* [Throw an assertion when an unrecognized timing curve is provided. (#92)](https://github.com/material-motion/motion-animator-objc/commit/1e76e2ba8fe9bc08d623a55623f5fd40579d0287) (featherless)
* [Add UIKit equivalent APIs for animating implicitly. (#90)](https://github.com/material-motion/motion-animator-objc/commit/69469aedb987e516ff1f43a123b3ee29dfef38ca) (featherless)

## API changes

Auto-generated by running:

    apidiff origin/stable release-candidate objc src/MotionAnimator.h

#### Animatable key paths

*new* constant: `MDMKeyPathAnchorPoint`

*new* constant: `MDMKeyPathBorderWidth`

*new* constant: `MDMKeyPathBorderColor`

*new* constant: `MDMKeyPathShadowColor`

*new* constant: `MDMKeyPathZ`

#### MDMMotionAnimator(UIKitEquivalency)

*new* class method: `+animateWithDuration:delay:options:animations:completion:` in `MDMMotionAnimator(UIKitEquivalency)`

*new* class method: `+animateWithDuration:animations:completion:` in `MDMMotionAnimator(UIKitEquivalency)`

*new* class method: `+animateWithDuration:animations:` in `MDMMotionAnimator(UIKitEquivalency)`

*new* class method: `+animateWithDuration:delay:usingSpringWithDamping:initialSpringVelocity:options:animations:completion:` in `MDMMotionAnimator(UIKitEquivalency)`

## Non-source changes

* [Animate the border as well to demonstrate that we can animate CALayer properties with the animator. (#101)](https://github.com/material-motion/motion-animator-objc/commit/e48cc459f281afde1ab2ae2c985b4fb64555c0f9) (featherless)
* [Add a UIKit-ish tap to bounce example as a contrast to the traits example. (#100)](https://github.com/material-motion/motion-animator-objc/commit/c04fd1a5ad5ba910cb609d5edf52f1fa2b88826f) (featherless)
* [Wording order.](https://github.com/material-motion/motion-animator-objc/commit/4bf33e213af26511e0aca40f42ebceb0a077076a) (Jeff Verkoeyen)
* [Min SDK support.](https://github.com/material-motion/motion-animator-objc/commit/0ca2e7c7e154da62fac508d6f8c21f1ff3b37c02) (Jeff Verkoeyen)
* [Fix the banner url.](https://github.com/material-motion/motion-animator-objc/commit/966ae6769288e4913219c7de156b846af5789d96) (Jeff Verkoeyen)
* [Add banner and drop most of the preamble docs in preparation for the new readme.](https://github.com/material-motion/motion-animator-objc/commit/cf183c788fba2fef2e144674d412da67d5adc438) (Jeff Verkoeyen)

---

# 2.7.0

This minor release introduces support for the new [v1.5.0](https://github.com/material-motion/motion-interchange-objc/releases/tag/v1.5.0) MotionInterchange format.

## New features

It is now possible to additively and implicitly animate the `transform` property of both UIView and CALayer.

## Source changes

* [Fix pre-iOS 11 unit test failure. (#89)](https://github.com/material-motion/motion-animator-objc/commit/7e506cc37b7d64d010b69d4996621755ece26595) (featherless)
* [Migrate to the Objective-C interchange format (#88)](https://github.com/material-motion/motion-animator-objc/commit/573b19269e155f15e05e9b146a1c324b937cfb1c) (featherless)
* [Revert "Update with ObjC implementation."](https://github.com/material-motion/motion-animator-objc/commit/f55625d9f63e857e878eff4e7687ddd40bad0fea) (Jeff Verkoeyen)
* [Update with ObjC implementation.](https://github.com/material-motion/motion-animator-objc/commit/be7f9081c0678484e034cc976aafcdab748b58bf) (Jeff Verkoeyen)
* [Add support for additively animating transform. (#85)](https://github.com/material-motion/motion-animator-objc/commit/e54ce3a118c1e877c5ca78a7d2fed9625d0ffc67) (featherless)

## API changes

Auto-generated by running:

    apidiff origin/stable release-candidate objc src/MotionAnimator.h

#### MDMMotionAnimator

*new* method: `-animateWithTraits:animations:completion:` in `MDMMotionAnimator`

*new* method: `-animateWithTraits:between:layer:keyPath:` in `MDMMotionAnimator`

*new* method: `-animateWithTraits:animations:` in `MDMMotionAnimator`

*new* method: `-animateWithTraits:between:layer:keyPath:completion:` in `MDMMotionAnimator`

#### MDMKeyPathTransform

*new* constant: `MDMKeyPathTransform`

## Non-source changes

* [Update .travis.yml](https://github.com/material-motion/motion-animator-objc/commit/8f474dd545ec1b3e98db5ef783bca502351911e4) (featherless)
* [Enable coverage on travis](https://github.com/material-motion/motion-animator-objc/commit/45d43aa23a88c963927f4f01669e1b0ae26fb9e5) (featherless)
* [Update kokoro bazel runner for v4.](https://github.com/material-motion/motion-animator-objc/commit/67d903ed71fbc909ea06bb8097313a4218c8f566) (Jeff Verkoeyen)

# 2.6.0

This minor release increases test coverage, fixes a variety of bugs related to `beginFromCurrentState`, and generally improves the stability and robustness of the underlying implementation.

## New features

The following key paths are now officially supported: `MDMKeyPathBounds`, `MDMKeyPathShadowOffset`, `MDMKeyPathShadowOpacity`, and `MDMKeyPathShadowRadius`.

## Source changes

* [Add tests verifying the UIKit beginFromCurrentState option behavior. (#84)](https://github.com/material-motion/motion-animator-objc/commit/a91ac69ead2ac86709a67c6589e6f053ffee5aeb) (featherless)
* [Disable additive animations for backgroundColor and opacity. (#66)](https://github.com/material-motion/motion-animator-objc/commit/3c6e3385adc3a386d2481e19beb7b4530751b8e4) (featherless)
* [Run the implicit animations block when exiting early. (#81)](https://github.com/material-motion/motion-animator-objc/commit/3a563c574e915ae9edeeec90884ba24478ab9a24) (featherless)
* [Clarify when completion is invoked in the docs. (#82)](https://github.com/material-motion/motion-animator-objc/commit/e7e0ce6d07a6b27a25256068fda0b45322099b11) (featherless)
* [Implement a motion animator behavioral test. (#80)](https://github.com/material-motion/motion-animator-objc/commit/562c43b24837e399fd042d97cea65c975033cfd8) (featherless)
* [Refactor common code from explicit/implicit animation implementations. (#78)](https://github.com/material-motion/motion-animator-objc/commit/6d801b3d0077712328483a2e0af40197945c11f1) (featherless)
* [Check for divide-by-zero before calculating the initial velocity of spring animations. (#75)](https://github.com/material-motion/motion-animator-objc/commit/45f355f49c4be3818d5b646be78a500e3666af4f) (featherless)
* [Add fallback mechanism for non-additive animations when beginFromCurrentState is enabled. (#76)](https://github.com/material-motion/motion-animator-objc/commit/433eb5fa683562428c0fa44a38d85e2bd740e6c9) (featherless)
* [Fix the bounds key path docs to indicate that additive animations are not supported. (#77)](https://github.com/material-motion/motion-animator-objc/commit/efa8937c6872c0946b0679734472dc87d5fc0502) (featherless)
* [Use objcType to identify the value types. (#73)](https://github.com/material-motion/motion-animator-objc/commit/5e6b649377d4f77fbef9332350cf22551fb65986) (featherless)
* [Fix bug where beginFromCurrentState would not start from the current model/presentation value. (#71)](https://github.com/material-motion/motion-animator-objc/commit/74c0d5323220e0852afb6eb10e830f685ecdf724) (featherless)
* [Only animate CGSize and CGPoint key paths additively if additive is enabled. (#72)](https://github.com/material-motion/motion-animator-objc/commit/524b3cb34d58d5354aa84bd9e5789cfddf8ea787) (featherless)
* [Add public/private marks to the animator implementation. (#70)](https://github.com/material-motion/motion-animator-objc/commit/71d22e2d42b25bedeb6dcb5b1080cfd4e4b3cbd8) (featherless)
* [Add MDMAllAnimatableKeyPaths API for retrieving all animatable key paths. (#69)](https://github.com/material-motion/motion-animator-objc/commit/f743ca076734cbb31964946cb62178fef0601b00) (featherless)
* [Add bounds to the list of supported key paths. (#68)](https://github.com/material-motion/motion-animator-objc/commit/b0a5f373b925d4a94ebcd12b1d689d27b09cb693) (featherless)
* [Document each animatable key path. (#65)](https://github.com/material-motion/motion-animator-objc/commit/f05e787b0814dfc90ae86ad8590edb5c30b9e27c) (featherless)
* [Add shadow key paths to the animatable keypaths list. (#64)](https://github.com/material-motion/motion-animator-objc/commit/18a0edd13e2c26fc18ec20933b0bf8c8cd6905ad) (featherless)
* [Add UIKit behavioral test verifying that layer values never implicitly animate outside of an animation block. (#63)](https://github.com/material-motion/motion-animator-objc/commit/efa04ffb41552b5a83151da3778e9b073c92a44b) (featherless)
* [Add CALayer behavioral tests. (#62)](https://github.com/material-motion/motion-animator-objc/commit/e6bc2195f7dbfef146dd36101c458590ceb29c8f) (featherless)
* [Add UIKit behavioral tests. (#60)](https://github.com/material-motion/motion-animator-objc/commit/ed203c883433d8a891d931ff408f5442434982c8) (featherless)

## API changes

### MDMAnimatableKeyPaths

**new** supported key paths: `MDMKeyPathBounds`, `MDMKeyPathShadowOffset`, `MDMKeyPathShadowOpacity`, and `MDMKeyPathShadowRadius`.

## Non-source changes

* [Add literature docs.](https://github.com/material-motion/motion-animator-objc/commit/ab856f69147a781226e9db8fd4c083d5d2ec77cf) (Jeff Verkoeyen)
* [Make use of the implicit animator in the example. (#79)](https://github.com/material-motion/motion-animator-objc/commit/f505ecf8b2d85b77db5af961639a1f39437ac2fd) (featherless)
* [Fix minor wording in the readme.](https://github.com/material-motion/motion-animator-objc/commit/2d6be5f5073f9a499a48aec13f0708b457569f44) (Jeff Verkoeyen)
* [Drop cocoadocs from the readme.](https://github.com/material-motion/motion-animator-objc/commit/2692850cdf0f78a7356d867e9e4a303fd261bd31) (Jeff Verkoeyen)
* [Update travis.yml with latest supported Xcode release.](https://github.com/material-motion/motion-animator-objc/commit/5a48e0084d079997227f73596a71b5caf91c0834) (Jeff Verkoeyen)

# 2.5.0

This minor release makes CALayer implicit animation support more robust while simplifying the internal animator implementation.

## New deprecations

`MDMMotionAnimator`'s `+sharedLayerDelegate` API has been deprecated and is no longer needed to animate headless CALayer instances.

## New features

The animator now supports additive animations on CALayer's `shadowOffset` property.

## Source changes

* [Improved robustness of implicit animation support (#53)](https://github.com/material-motion/motion-animator-objc/commit/f2724c03d4c4ffb0c1cdd9b15bd8e9070c42a85b) (featherless)
* [If timeScaleFactor is 0 then exit early. (#58)](https://github.com/material-motion/motion-animator-objc/commit/68456b3fe31766baaa791fc20cec2f1eab47657e) (featherless)
* [Spring animations now take velocity into account when determining duration. (#56)](https://github.com/material-motion/motion-animator-objc/commit/a8a40ea7a25dfe74753fda6b64dce4ca5497e319) (featherless)
* [Flatten the animate internal logic. (#55)](https://github.com/material-motion/motion-animator-objc/commit/47bee419abda897a6d295006215c486c69d9ff83) (featherless)
* [Allow headless CALayers to implicitly animate when using the sharedLayerDelegate. (#57)](https://github.com/material-motion/motion-animator-objc/commit/044ad1872209b5e1bb0976786f9768c54a8ecb59) (featherless)
* [Always commit the model layer value inside a transaction with actions disabled. (#54)](https://github.com/material-motion/motion-animator-objc/commit/5a3d65e32ee990561392983d9bc9b359e903594b) (featherless)
* [Add shadowOffset to list of support CGSize properties. (#50)](https://github.com/material-motion/motion-animator-objc/commit/89abc77524057c27bae550e3badd320b8bea45fe) (featherless)

## API changes

### MDMMotionAnimator

**deprecated** method: `+sharedLayerDelegate`

# 2.4.0

This minor release introduces support for implicitly animating CALayers that have been created
independently of a UIView. To use this new functionality, consider the following example:

```swift
let layer = CALayer()
layer.delegate = MotionAnimator.sharedLayerDelegate()
animator.animate(with: timing) {
  layer.opacity = 0.5
}
```

## New features

Added support for adding implicit animations to headless CALayer instances.

## Source changes

* [Add support for headless implicit layer animations. (#45)](https://github.com/material-motion/motion-animator-objc/commit/b92bb0a26c3458b508e0ba85628aea3e1590df28) (featherless)

## API changes

### MDMMotionAnimator

**new** method: `+sharedLayerDelegate`

## Non-source changes

* [Remove references to interchange macros. (#44)](https://github.com/material-motion/motion-animator-objc/commit/a1c771b781713d6fc63e68ede73690e1f16c9624) (featherless)
* [Add missing Info.plist. (#43)](https://github.com/material-motion/motion-animator-objc/commit/41fa66f904b28058f5a968da879749d3732d6c35) (Sylvain Defresne)

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


