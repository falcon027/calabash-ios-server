//
//  ScrollOperation.m
//  Created by Karl Krukow on 05/09/11.
//  Copyright 2011 LessPainful. All rights reserved.
//

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "LPScrollOperation.h"
#import "UIWebView+LPWebView.h"
#import "LPIsWebView.h"
#import "LPWebViewProtocol.h"

@implementation LPScrollOperation
- (NSString *) description {
  return [NSString stringWithFormat:@"Scroll: %@", _arguments];
}


- (id) performWithTarget:(UIView *) _view error:(NSError *__autoreleasing*) error {
  NSString *dir = [_arguments objectAtIndex:0];

  if ([_view isKindOfClass:[UIScrollView class]]) {
    UIScrollView *sv = (UIScrollView *) _view;
    CGSize size = sv.bounds.size;
    CGPoint offset = sv.contentOffset;
    CGFloat fraction = 2.0;
    if ([sv isPagingEnabled]) {
      fraction = 1.0;
    }

    CGPoint point;

    if ([@"up" isEqualToString:dir]) {
      CGFloat scrollAmount = MIN((size.height)/fraction, offset.y + sv.contentInset.top);
      point = CGPointMake(offset.x, offset.y - scrollAmount);
    } else if ([@"down" isEqualToString:dir]) {
      CGFloat scrollAmount = MIN(size.height/fraction, sv.contentSize.height + sv.contentInset.bottom - offset.y - size.height);
      point = CGPointMake(offset.x, offset.y + scrollAmount);
    } else if ([@"left" isEqualToString:dir]) {
      CGFloat scrollAmount = MIN(size.width/fraction, offset.x + sv.contentInset.left);
      point = CGPointMake(offset.x - scrollAmount, offset.y);
    } else if ([@"right" isEqualToString:dir]) {
      CGFloat scrollAmount = MIN(size.width/fraction, sv.contentSize.width + sv.contentInset.right - offset.x - size.width);
      point = CGPointMake(offset.x + scrollAmount, offset.y);
    } else {
      point = CGPointZero;
    }

    if ([[NSThread currentThread] isMainThread]) {
      [sv setContentOffset:point animated:YES];
    } else {
      dispatch_sync(dispatch_get_main_queue(), ^{
        [sv setContentOffset:point animated:YES];
      });
    }

    return _view;
  } else if ([LPIsWebView isWebView:_view]) {
    UIView<LPWebViewProtocol> *webView = (UIView<LPWebViewProtocol> *)_view;
    NSString *scrollJS = @"window.scrollBy(%@,%@);";
    if ([@"up" isEqualToString:dir]) {
      scrollJS = [NSString stringWithFormat:scrollJS, @"0", @"-100"];
    } else if ([@"down" isEqualToString:dir]) {
      scrollJS = [NSString stringWithFormat:scrollJS, @"0", @"100"];
    } else if ([@"left" isEqualToString:dir]) {
      scrollJS = [NSString stringWithFormat:scrollJS, @"-100", @"0"];
    } else if ([@"right" isEqualToString:dir]) {
      scrollJS = [NSString stringWithFormat:scrollJS, @"100", @"0"];
    }
    NSString *res = [webView calabashStringByEvaluatingJavaScript:scrollJS];
    NSLog(@"RES:%@", res);
    return _view;
  }
  return nil;
}

@end
