//
//  HMSideMenu.m
//  HMSideMenu
//
//  Created by Hesham Abd-Elmegid on 4/24/13.
//  Copyright (c) 2013 Hesham Abd-Elmegid. All rights reserved.
//

#import "HMSideMenu.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationDelay 0.08

typedef CGFloat (^EasingFunction)(CGFloat, CGFloat, CGFloat, CGFloat);

@interface HMSideMenu ()

@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, assign) CGFloat menuHeight;

@end

@implementation HMSideMenu

- (id)initWithItems:(NSArray *)items {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        self.items = items;
        [self setAnimationDuration:1.0f];
        [self setPosition:HMSideMenuPositionRight];
        [self setBackgroundColor:[UIColor grayColor]];
    }
    
    return self;
}

- (void)setItems:(NSArray *)items {
    // Remove all current items in case we are changing the menu items.
    for (HMSideMenuItem *item in items) {
        [item removeFromSuperview];
    }
    
    _items = items;
    
    for (HMSideMenuItem *item in items) {
        [self addSubview:item];
    }
}

- (void)open {
    _isOpen = YES;
    
    for (HMSideMenuItem *item in self.items) {
        [self performSelector:@selector(showItem:) withObject:item afterDelay:kAnimationDelay * [self.items indexOfObject:item]];
    }
}

- (void)close {
    _isOpen = NO;
    
    for (HMSideMenuItem *item in self.items) {
        [self performSelector:@selector(hideItem:) withObject:item afterDelay:kAnimationDelay * [self.items indexOfObject:item]];
    }
}

- (void)showItem:(HMSideMenuItem *)item {
    if (self.position == HMSideMenuPositionRight) {
        [self animateLayer:item.layer
               withKeyPath:@"position.x"
                        to:item.layer.position.x - self.menuWidth];
        
        item.layer.position = CGPointMake(item.layer.position.x - self.menuWidth, item.layer.position.y);
    } else if (self.position == HMSideMenuPositionLeft) {
        [self animateLayer:item.layer
               withKeyPath:@"position.x"
                        to:item.layer.position.x + self.menuWidth];
        
        item.layer.position = CGPointMake(item.layer.position.x + self.menuWidth, item.layer.position.y);
    } else if (self.position == HMSideMenuPositionTop) {
        [self animateLayer:item.layer
               withKeyPath:@"position.y"
                        to:item.layer.position.y + self.menuHeight];
        
        item.layer.position = CGPointMake(item.layer.position.x, item.layer.position.y + self.menuHeight);
    }
}

- (void)hideItem:(HMSideMenuItem *)item {
    if (self.position == HMSideMenuPositionRight) {
        [self animateLayer:item.layer
               withKeyPath:@"position.x"
                        to:item.layer.position.x + self.menuWidth];
        
        item.layer.position = CGPointMake(item.layer.position.x + self.menuWidth, item.layer.position.y);
    } else if (self.position == HMSideMenuPositionLeft) {
        [self animateLayer:item.layer
               withKeyPath:@"position.x"
                        to:item.layer.position.x - self.menuWidth];
        
        item.layer.position = CGPointMake(item.layer.position.x - self.menuWidth, item.layer.position.y);
    } else if (self.position == HMSideMenuPositionTop) {
        [self animateLayer:item.layer
               withKeyPath:@"position.y"
                        to:item.layer.position.y - self.menuHeight];
        
        item.layer.position = CGPointMake(item.layer.position.x, item.layer.position.y - self.menuHeight);
    }
}

#pragma mark - UIView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.isOpen) {
        for (HMSideMenuItem *item in self.items)
            if (CGRectContainsPoint(item.frame, point)) return YES;
    } else if (!self.isOpen && CGRectContainsPoint(self.frame, point)) {
        return YES;
    }
   
    return NO;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.menuWidth = 0;
    self.menuHeight = 0;
    CGFloat __block biggestHeight = 0;
    CGFloat __block biggestWidth = 0;
    
    if (self.position == HMSideMenuPositionLeft || self.position == HMSideMenuPositionRight) {
        [self.items enumerateObjectsUsingBlock:^(HMSideMenuItem *item, NSUInteger idx, BOOL *stop) {
            self.menuWidth = MAX(item.frame.size.width, self.menuWidth);
            biggestHeight = MAX(item.frame.size.height, biggestHeight);
        }];
        
        self.menuHeight = (biggestHeight * self.items.count) + (self.spacing * (self.items.count - 1));
    } else if (self.position == HMSideMenuPositionTop || self.position == HMSideMenuPositionBottom) {
        [self.items enumerateObjectsUsingBlock:^(HMSideMenuItem *item, NSUInteger idx, BOOL *stop) {
            biggestWidth = MAX(item.frame.size.width, biggestWidth);
            self.menuHeight = MAX(item.frame.size.height, self.menuHeight);
        }];
        
        // To do: add spacing
        self.menuWidth = (biggestWidth * self.items.count);
//        self.menuHeight = biggestHeight;
    }
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat itemInitialX = 0;
    
    if (self.position == HMSideMenuPositionRight) {
        x = self.superview.frame.size.width;
        y  = (self.superview.frame.size.height / 2) - (self.menuHeight / 2);
        itemInitialX = self.menuWidth / 2;
    } else if (self.position == HMSideMenuPositionLeft) {
        x = 0 - self.menuWidth;
        y = (self.superview.frame.size.height / 2) - (self.menuHeight / 2);
        itemInitialX = self.menuWidth / 2;
    } else if (self.position == HMSideMenuPositionTop) {
        x = self.superview.frame.size.width / 2 - (self.menuWidth / 2);
        y = 0 - self.menuHeight;
        itemInitialX = 0;
    }
    
    self.frame = CGRectMake(x, y, self.menuWidth, self.menuHeight);;
    
    [self.items enumerateObjectsUsingBlock:^(HMSideMenuItem *item, NSUInteger idx, BOOL *stop) {
        if (self.position == HMSideMenuPositionLeft || self.position == HMSideMenuPositionRight)
            [item setCenter:CGPointMake(itemInitialX, (idx * biggestHeight) + (idx * self.spacing) + (biggestHeight / 2))];
        else
            [item setCenter:CGPointMake((idx * biggestWidth) + (idx * self.spacing) + (biggestWidth / 2), self.menuHeight / 2)];
    }];
}

#pragma mark - Animation

- (void)animateLayer:(CALayer *)layer
         withKeyPath:(NSString *)keyPath
                  to:(CGFloat)endValue {
    CGFloat startValue = [[layer valueForKeyPath:keyPath] floatValue];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:keyPath];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = self.animationDuration;
    
    CGFloat steps = 100;
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:steps];
    CGFloat delta = endValue - startValue;
    EasingFunction function = easeOutElastic;
    
    for (CGFloat t = 0; t < steps; t++) {
        [values addObject:@(function(animation.duration * (t / steps), startValue, delta, animation.duration))];
    }
    
    animation.values = values;
//    layer.position = CGPointMake(endValue, layer.position.y);
    [layer addAnimation:animation forKey:nil];
}

static EasingFunction easeOutElastic = ^CGFloat(CGFloat t, CGFloat b, CGFloat c, CGFloat d) {
    CGFloat amplitude = 5;
    CGFloat period = 0.6;
    CGFloat s = 0;
    if (t == 0) {
        return b;
    }
    else if ((t /= d) == 1) {
        return b + c;
    }
    
    if (!period) {
        period = d * .3;
    }
    
    if (amplitude < abs(c)) {
        amplitude = c;
        s = period / 4;
    }
    else {
        s = period / (2 * M_PI) * sin(c / amplitude);
    }
    
    return (amplitude * pow(2, -10 * t) * sin((t * d - s) * (2 * M_PI) / period) + c + b);
};

@end
