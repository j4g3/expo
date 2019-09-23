/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI34_0_0RCTStatusBarManager.h"

#import "ABI34_0_0RCTEventDispatcher.h"
#import "ABI34_0_0RCTLog.h"
#import "ABI34_0_0RCTUtils.h"

#if !TARGET_OS_TV
@implementation ABI34_0_0RCTConvert (UIStatusBar)

ABI34_0_0RCT_ENUM_CONVERTER(UIStatusBarStyle, (@{
  @"default": @(UIStatusBarStyleDefault),
  @"light-content": @(UIStatusBarStyleLightContent),
  @"dark-content": @(UIStatusBarStyleDefault),
}), UIStatusBarStyleDefault, integerValue);

ABI34_0_0RCT_ENUM_CONVERTER(UIStatusBarAnimation, (@{
  @"none": @(UIStatusBarAnimationNone),
  @"fade": @(UIStatusBarAnimationFade),
  @"slide": @(UIStatusBarAnimationSlide),
}), UIStatusBarAnimationNone, integerValue);

@end
#endif

@implementation ABI34_0_0RCTStatusBarManager

static BOOL ABI34_0_0RCTViewControllerBasedStatusBarAppearance()
{
  static BOOL value;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    value = [[[NSBundle mainBundle] objectForInfoDictionaryKey:
              @"UIViewControllerBasedStatusBarAppearance"] ?: @YES boolValue];
  });

  return value;
}

ABI34_0_0RCT_EXPORT_MODULE()

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"statusBarFrameDidChange",
           @"statusBarFrameWillChange"];
}

#if !TARGET_OS_TV

- (void)startObserving
{
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc addObserver:self selector:@selector(applicationDidChangeStatusBarFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
  [nc addObserver:self selector:@selector(applicationWillChangeStatusBarFrame:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

- (void)stopObserving
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

- (void)emitEvent:(NSString *)eventName forNotification:(NSNotification *)notification
{
  CGRect frame = [notification.userInfo[UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
  NSDictionary *event = @{
    @"frame": @{
      @"x": @(frame.origin.x),
      @"y": @(frame.origin.y),
      @"width": @(frame.size.width),
      @"height": @(frame.size.height),
    },
  };
  [self sendEventWithName:eventName body:event];
}

- (void)applicationDidChangeStatusBarFrame:(NSNotification *)notification
{
  [self emitEvent:@"statusBarFrameDidChange" forNotification:notification];
}

- (void)applicationWillChangeStatusBarFrame:(NSNotification *)notification
{
  [self emitEvent:@"statusBarFrameWillChange" forNotification:notification];
}

ABI34_0_0RCT_EXPORT_METHOD(getHeight:(ABI34_0_0RCTResponseSenderBlock)callback)
{
  callback(@[@{
    @"height": @(ABI34_0_0RCTSharedApplication().statusBarFrame.size.height),
  }]);
}

ABI34_0_0RCT_EXPORT_METHOD(setStyle:(UIStatusBarStyle)statusBarStyle
                  animated:(BOOL)animated)
{
  if (ABI34_0_0RCTViewControllerBasedStatusBarAppearance()) {
    ABI34_0_0RCTLogError(@"ABI34_0_0RCTStatusBarManager module requires that the \
                UIViewControllerBasedStatusBarAppearance key in the Info.plist is set to NO");
  } else {
    [ABI34_0_0RCTSharedApplication() setStatusBarStyle:statusBarStyle
                                     animated:animated];
  }
}

ABI34_0_0RCT_EXPORT_METHOD(setHidden:(BOOL)hidden
                  withAnimation:(UIStatusBarAnimation)animation)
{
  if (ABI34_0_0RCTViewControllerBasedStatusBarAppearance()) {
    ABI34_0_0RCTLogError(@"ABI34_0_0RCTStatusBarManager module requires that the \
                UIViewControllerBasedStatusBarAppearance key in the Info.plist is set to NO");
  } else {
    [ABI34_0_0RCTSharedApplication() setStatusBarHidden:hidden
                                 withAnimation:animation];
  }
}

ABI34_0_0RCT_EXPORT_METHOD(setNetworkActivityIndicatorVisible:(BOOL)visible)
{
  ABI34_0_0RCTSharedApplication().networkActivityIndicatorVisible = visible;
}

#endif //TARGET_OS_TV

@end