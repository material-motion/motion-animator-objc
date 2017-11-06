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

#import "MDMBlockAnimations.h"

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static IMP sOriginalActionForLayerImp = NULL;

@interface MDMActionContext: NSObject
@property(nonatomic, strong, readonly) NSArray<MDMImplicitAction *> *actions;
@end

@implementation MDMImplicitAction

- (instancetype)initWithLayer:(CALayer *)layer
                      keyPath:(NSString *)keyPath
                 initialValue:(id)initialValue {
  self = [super init];
  if (self) {
    _layer = layer;
    _keyPath = [keyPath copy];
    _initialValue = initialValue;
  }
  return self;
}

@end

@implementation MDMActionContext {
  NSMutableArray<MDMImplicitAction *> *_actions;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _actions = [NSMutableArray array];
  }
  return self;
}

- (void)addActionForLayer:(CALayer *)layer
                  keyPath:(NSString *)keyPath
         withInitialValue:(id)initialValue {
  [_actions addObject:[[MDMImplicitAction alloc] initWithLayer:layer
                                                       keyPath:keyPath
                                                  initialValue:initialValue]];
}

- (NSArray<MDMImplicitAction *> *)actions {
  return _actions;
}

@end

static NSMutableArray *sActionContext = nil;

static id<CAAction> ActionForLayer(id self, SEL _cmd, CALayer *layer, NSString *event) {
  NSCAssert([NSStringFromSelector(_cmd) isEqualToString:
             NSStringFromSelector(@selector(actionForLayer:forKey:))],
            @"Invalid method signature.");

  MDMActionContext *context = [sActionContext lastObject];

  if (context == nil) {
    return ((id<CAAction>(*)(id,SEL,CALayer *, NSString *))
            sOriginalActionForLayerImp)(self, _cmd, layer, event);
  }

  // We don't have access to the "to" value of our animation here, so we unfortunately can't
  // calculate additive values if the animator is configured as such. So, to support additive
  // animations, we queue up the modified actions and then add them all at the end of our
  // MDMAnimateBlock invocation.
  id initialValue = [layer valueForKeyPath:event];
  [context addActionForLayer:layer keyPath:event withInitialValue:initialValue];
  return [NSNull null];
}

NSArray<MDMImplicitAction *> *MDMAnimateBlock(void (^work)(void)) {
  if (!work) {
    return nil;
  }

  SEL selector = @selector(actionForLayer:forKey:);
  Method method = class_getInstanceMethod([UIView class], selector);

  if (sOriginalActionForLayerImp == nil) {
    sOriginalActionForLayerImp = method_setImplementation(method, (IMP)ActionForLayer);
  }

  if (!sActionContext) {
    sActionContext = [NSMutableArray array];
  }
  [sActionContext addObject:[[MDMActionContext alloc] init]];

  work();

  MDMActionContext *context = [sActionContext lastObject];
  [sActionContext removeLastObject];

  if ([sActionContext count] == 0) {
    method_setImplementation(method, sOriginalActionForLayerImp);
    sOriginalActionForLayerImp = nil;
  }

  return context.actions;
}
