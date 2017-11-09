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

#import "MDMAnimationRegistrar.h"

#import "MDMRegisteredAnimation.h"

@implementation MDMAnimationRegistrar {
  NSMapTable *_layersToRegisteredAnimation;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _layersToRegisteredAnimation = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory
                                                      valueOptions:NSPointerFunctionsStrongMemory];
  }
  return self;
}

- (void)addAnimation:(CABasicAnimation *)animation
                toLayer:(CALayer *)layer
                 forKey:(NSString *)key
             completion:(void(^)(void))completion {
  if (key == nil) {
    key = [NSUUID UUID].UUIDString;
  }

  NSMutableSet *animatedKeyPaths = [_layersToRegisteredAnimation objectForKey:layer];
  if (!animatedKeyPaths) {
    animatedKeyPaths = [[NSMutableSet alloc] init];
    [_layersToRegisteredAnimation setObject:animatedKeyPaths forKey:layer];
  }
  MDMRegisteredAnimation *keyPathAnimation =
      [[MDMRegisteredAnimation alloc] initWithKey:key animation:animation];
  [animatedKeyPaths addObject:keyPathAnimation];

  [CATransaction begin];
  [CATransaction setCompletionBlock:^{
    [animatedKeyPaths removeObject:keyPathAnimation];

    if (completion) {
      completion();
    }
  }];

  [layer addAnimation:animation forKey:key];

  [CATransaction commit];
}

- (void)forEveryAnimatedKey:(void (^)(CALayer *, CABasicAnimation *, NSString *))work {
  for (CALayer *layer in _layersToRegisteredAnimation) {
    NSSet *keyPathAnimations = [_layersToRegisteredAnimation objectForKey:layer];
    for (MDMRegisteredAnimation *keyPathAnimation in keyPathAnimations) {
      if (![keyPathAnimation.animation isKindOfClass:[CABasicAnimation class]]) {
        continue;
      }

      work(layer, [keyPathAnimation.animation copy], keyPathAnimation.key);
    }
  }
}

- (void)forEveryAnimatedKeyOnLayer:(CALayer *)layer
                                do:(void (^)(CALayer *, CABasicAnimation *, NSString *))work {
  NSSet *keyPathAnimations = [_layersToRegisteredAnimation objectForKey:layer];
  for (MDMRegisteredAnimation *keyPathAnimation in keyPathAnimations) {
    if (![keyPathAnimation.animation isKindOfClass:[CABasicAnimation class]]) {
      continue;
    }

    work(layer, [keyPathAnimation.animation copy], keyPathAnimation.key);
  }
}

- (void)removeAllAnimationsFromLayer:(CALayer *)layer withKeys:(NSSet *)keys {
  NSMutableSet *animatedKeyPaths = [_layersToRegisteredAnimation objectForKey:layer];
  for (NSString *key in keys) {
    [layer removeAnimationForKey:key];

    [animatedKeyPaths removeObject:key];
  }
}

- (void)animationDidCompleteOnLayer:(CALayer *)layer withKey:(NSString *)key {
  NSMutableSet *animatedKeyPaths = [_layersToRegisteredAnimation objectForKey:layer];
  [animatedKeyPaths removeObject:key];
}

- (void)commitCurrentAnimationValuesToAllLayers {
  [self forEveryAnimatedKey:^(CALayer *layer, CABasicAnimation *animation, NSString *key) {
    id presentationLayer = [layer presentationLayer];
    if (presentationLayer != nil) {
      id presentationValue = [presentationLayer valueForKeyPath:animation.keyPath];
      [layer setValue:presentationValue forKeyPath:animation.keyPath];
    }
  }];
}

- (void)removeAllAnimations {
  [self forEveryAnimatedKey:^(CALayer *layer, CABasicAnimation *animation, NSString *key) {
    [layer removeAnimationForKey:key];
  }];
  [_layersToRegisteredAnimation removeAllObjects];
}

@end
