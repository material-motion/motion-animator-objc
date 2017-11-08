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

@interface MDMActionContext: NSObject
@property(nonatomic, readonly) NSArray<MDMImplicitAction *> *interceptedActions;
@end

// The original UIView method implementation of actionForLayer:forKey:.
static IMP sOriginalActionForLayerImp = NULL;
static NSMutableArray<MDMActionContext *> *sActionContext = nil;

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
  NSMutableArray<MDMImplicitAction *> *_interceptedActions;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _interceptedActions = [NSMutableArray array];
  }
  return self;
}

- (void)addActionForLayer:(CALayer *)layer
                  keyPath:(NSString *)keyPath
         withInitialValue:(id)initialValue {
  [_interceptedActions addObject:[[MDMImplicitAction alloc] initWithLayer:layer
                                                                  keyPath:keyPath
                                                             initialValue:initialValue]];
}

- (NSArray<MDMImplicitAction *> *)interceptedActions {
  return [_interceptedActions copy];
}

@end

static id<CAAction> ActionForLayer(id self, SEL _cmd, CALayer *layer, NSString *event) {
  NSCAssert([NSStringFromSelector(_cmd) isEqualToString:
             NSStringFromSelector(@selector(actionForLayer:forKey:))],
            @"Invalid method signature.");

  MDMActionContext *context = [sActionContext lastObject];
  NSCAssert(context != nil, @"MotionAnimator action method invoked out of implicit scope.");

  if (context == nil) {
    // Graceful handling of invalid state on non-debug builds for if our context is nil invokes our
    // original implementation:
    return ((id<CAAction>(*)(id, SEL, CALayer *, NSString *))sOriginalActionForLayerImp)
              (self, _cmd, layer, event);
  }

  // We don't have access to the "to" value of our animation here, so we unfortunately can't
  // calculate additive values if the animator is configured as such. So, to support additive
  // animations, we queue up the modified actions and then add them all at the end of our
  // MDMAnimateImplicitly invocation.
  id initialValue = [layer valueForKeyPath:event];
  [context addActionForLayer:layer keyPath:event withInitialValue:initialValue];
  return [NSNull null];
}

NSArray<MDMImplicitAction *> *MDMAnimateImplicitly(void (^work)(void)) {
  if (!work) {
    return nil;
  }

  // This method can be called recursively, so we maintain a context stack in the scope of this
  // method. Note that this is absolutely not thread safe, but neither is Core Animation.
  if (!sActionContext) {
    sActionContext = [NSMutableArray array];
  }
  [sActionContext addObject:[[MDMActionContext alloc] init]];

  SEL selector = @selector(actionForLayer:forKey:);
  Method method = class_getInstanceMethod([UIView class], selector);

  if (sOriginalActionForLayerImp == nil) {
    // Swap the original UIView implementation with our own so that we can intercept all
    // actionForLayer:forKey: events.
    sOriginalActionForLayerImp = method_setImplementation(method, (IMP)ActionForLayer);
  }

  work();

  // Return any intercepted actions we received during the invocation of work.
  MDMActionContext *context = [sActionContext lastObject];
  [sActionContext removeLastObject];

  if ([sActionContext count] == 0) {
    // Restore our original method if we've emptied the stack:
    method_setImplementation(method, sOriginalActionForLayerImp);

    sOriginalActionForLayerImp = nil;
    sActionContext = nil;
  }

  return context.interceptedActions;
}
