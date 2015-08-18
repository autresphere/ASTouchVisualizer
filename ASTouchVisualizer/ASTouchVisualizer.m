//
//  ASTouchVisualizer.m
//  ASTouchVisualizer
//
//  Created by Philippe Converset on 15/11/12.
//  Copyright (c) 2012 AutreSphere. All rights reserved.
//

#import "ASTouchVisualizer.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static CGFloat const kTouchViewAttentionScale = 3;
static CGFloat const kTouchViewSize = 60;
static CGFloat const kTouchViewAlpha = 0.5;
static NSTimeInterval const kTouchAnimationduration = 0.25;

static ASTouchVisualizer *touchVisualizer;

@class ASTouchView;

@interface ASTouchVisualizer ()
{
    CFMutableDictionaryRef touchViews;
}
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, getter=isInstalled) BOOL installed;

+ (ASTouchVisualizer *)sharedTouchVisualizer;
- (void)showTouches:(NSSet *)touches;
@end

@interface ASTouchView : UIView
@property (nonatomic, strong) UIView *markView;
@property (nonatomic, strong) UIView *attentionView;
@property (readonly, nonatomic) UIWindow *window;
@end

@implementation ASTouchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setupAttentionView];
        [self setupMarkView];
    }
    
    return self;
}

- (void)setupAttentionView
{
    self.attentionView = [[UIView alloc] initWithFrame:self.bounds];
    self.attentionView.layer.cornerRadius = kTouchViewSize/2;
    self.attentionView.layer.borderColor = [UIColor redColor].CGColor;
    self.attentionView.layer.borderWidth = 6;
    self.attentionView.alpha = 0;
    self.attentionView.layer.shadowOpacity = 0.25;
    self.attentionView.layer.shadowOffset = CGSizeMake(1, 1);
    self.attentionView.layer.shadowColor = self.attentionView.layer.borderColor;
    self.attentionView.layer.shadowRadius = 1;
    [self addSubview:self.attentionView];
}

- (void)setupMarkView
{
    self.markView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:self.markView];
    self.markView.backgroundColor = [UIColor whiteColor];
    self.markView.layer.cornerRadius = kTouchViewSize/2;
    self.markView.layer.borderWidth = 2;
    self.markView.layer.borderColor = [UIColor blackColor].CGColor;
    self.markView.layer.shadowOpacity = 0.5;
    self.markView.layer.shadowOffset = CGSizeMake(2, 2);
    self.markView.layer.shadowRadius = 2;
    self.markView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    self.markView.alpha = 0;
}

- (void)show
{
    [UIView animateWithDuration:kTouchAnimationduration
                     animations:^{
                         self.markView.alpha = kTouchViewAlpha;
                         self.markView.transform = CGAffineTransformIdentity;
                         self.attentionView.alpha = 0.75;
                         self.markView.alpha = kTouchViewAlpha;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:kTouchAnimationduration
                                          animations:^{
                                              self.attentionView.alpha = 0;
                                          }];
                     }];
    
    [UIView animateWithDuration:kTouchAnimationduration*2
                     animations:^{
                         self.attentionView.transform = CGAffineTransformMakeScale(kTouchViewAttentionScale, kTouchViewAttentionScale);
                     }
                     completion:^(BOOL finished) {
                         self.attentionView.alpha = 0;
                         self.attentionView.transform = CGAffineTransformIdentity;
                     }];
}

- (void)hide
{
    [UIView animateWithDuration:kTouchAnimationduration
                     animations:^{
                         self.markView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                         self.markView.alpha = 0;
                     }];
}

- (BOOL)isVisible
{
    return self.markView.alpha != 0;
}

@end

@interface UIWindow (TouchVisualizer)
@end

@implementation UIWindow (TouchVisualizer)

- (void)swizzled_sendEvent:(UIEvent *)event
{
    [[ASTouchVisualizer sharedTouchVisualizer] showTouches:event.allTouches];    
    [self swizzled_sendEvent:event];
}

@end

@implementation ASTouchVisualizer
+ (ASTouchVisualizer *)sharedTouchVisualizer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        touchVisualizer = [[ASTouchVisualizer alloc] init];
    });
    
    return touchVisualizer;
}

+ (void)install
{
    [[ASTouchVisualizer sharedTouchVisualizer] install];
}

+ (void)uninstall
{
    [[ASTouchVisualizer sharedTouchVisualizer] uninstall];
}

+ (BOOL)isInstalled
{
    return [[ASTouchVisualizer sharedTouchVisualizer] isInstalled];
}

- (void)setupEventHandler
{
    Method original, swizzle;
    
    original = class_getInstanceMethod([UIWindow class], @selector(sendEvent:));
    swizzle = class_getInstanceMethod([UIWindow class], @selector(swizzled_sendEvent:));
    method_exchangeImplementations(original, swizzle);
}

- (void)setupMainView
{
    self.mainView = [[UIView alloc] initWithFrame:self.window.bounds];
    self.mainView.backgroundColor = [UIColor clearColor];
    self.mainView.opaque = NO;
    self.mainView.userInteractionEnabled = NO;
    self.mainView.transform = self.window.rootViewController.view.transform;
    [self.window addSubview:self.mainView];
}

- (ASTouchView *)touchViewForTouch:(UITouch *)touch
{
    ASTouchView *touchView;
    
    touchView = (ASTouchView *)CFDictionaryGetValue(touchViews, (__bridge const void *)(touch));
    if(touchView == nil)
    {
        touchView = [[ASTouchView alloc] initWithFrame:CGRectMake(0, 0, kTouchViewSize, kTouchViewSize)];
        [self.mainView addSubview:touchView];
        CFDictionaryAddValue(touchViews, (__bridge const void *)(touch), (__bridge const void *)(touchView));
    }
    
    return touchView;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        touchViews = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
    }
    
    return self;
}

- (void)install
{
    if (self.installed) {
        return;
    }
    [self setupEventHandler];
    [self setupMainView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientationNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
    [self.window addObserver:self forKeyPath:@"rootViewController" options:NSKeyValueObservingOptionNew context:nil];
    self.installed = YES;
}

- (void)uninstall
{
    if (!self.installed) {
        return;
    }
    [self setupEventHandler];
    [self.window removeObserver:self forKeyPath:@"rootViewController"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.mainView removeFromSuperview];
    self.mainView = nil;
    for (UIView *touchView in ((__bridge NSMutableDictionary *)touchViews).objectEnumerator) {
        [touchView removeFromSuperview];
    }
    [((__bridge NSMutableDictionary *)touchViews) removeAllObjects];
    self.installed = NO;
}

- (void)showTouches:(NSSet *)touches
{
    for(UITouch *touch in touches)
    {
        [self showTouch:touch];
    }
}

- (void)showTouch:(UITouch *)touch
{
    // Make sure mainView is at the top of the view hierarchy
    [self.mainView.superview bringSubviewToFront:self.mainView];

    ASTouchView *touchView;
    CGPoint location;
    
    location = [touch locationInView:self.mainView];
    touchView = [self touchViewForTouch:touch];
    touchView.center = location;
    if(![touchView isVisible])
    {
        [touchView show];
    }
    if(touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled)
    {
        CFDictionaryRemoveValue(touchViews, (__bridge const void *)(touch));
        [touchView hide];
    }
}

- (void)hideAllTouchViews
{
    CFDictionaryRemoveAllValues(touchViews);
    [self.mainView.subviews makeObjectsPerformSelector:@selector(hide)];
}

- (UIWindow *)window {
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        return [UIApplication sharedApplication].delegate.window;
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
}

#pragma mark - Notifications
- (void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    [[ASTouchVisualizer sharedTouchVisualizer] hideAllTouchViews];
}

- (void)applicationDidChangeStatusBarOrientationNotification:(NSNotification *)notification
{
    self.mainView.transform = self.window.rootViewController.view.transform;
}

#pragma mark - KVO Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    self.mainView.transform = self.window.rootViewController.view.transform;
    [self.mainView.superview bringSubviewToFront:self.mainView];
}
@end
