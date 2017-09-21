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

#import <Availability.h>
#import <Foundation/Foundation.h>

// This macro is introduced in Xcode 9.
#ifndef CF_TYPED_ENUM // What follows is backwards compat for Xcode 8 and below.
#if __has_attribute(swift_wrapper)
#define CF_TYPED_ENUM __attribute__((swift_wrapper(enum)))
#else
#define CF_TYPED_ENUM
#endif
#endif

/**
 A representation of an animatable key path. Likely not exhaustive.
 */
NS_SWIFT_NAME(AnimatableKeyPath)
typedef NSString * const MDMAnimatableKeyPath CF_TYPED_ENUM;

FOUNDATION_EXPORT MDMAnimatableKeyPath MDMKeyPathCornerRadius NS_SWIFT_NAME(cornerRadius);
FOUNDATION_EXPORT MDMAnimatableKeyPath MDMKeyPathHeight NS_SWIFT_NAME(height);
FOUNDATION_EXPORT MDMAnimatableKeyPath MDMKeyPathOpacity NS_SWIFT_NAME(opacity);
FOUNDATION_EXPORT MDMAnimatableKeyPath MDMKeyPathScale NS_SWIFT_NAME(scale);
FOUNDATION_EXPORT MDMAnimatableKeyPath MDMKeyPathWidth NS_SWIFT_NAME(width);
FOUNDATION_EXPORT MDMAnimatableKeyPath MDMKeyPathX NS_SWIFT_NAME(x);
FOUNDATION_EXPORT MDMAnimatableKeyPath MDMKeyPathY NS_SWIFT_NAME(y);
