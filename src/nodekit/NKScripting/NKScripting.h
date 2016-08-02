/*
 * nodekit.io
 *
 * Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
 * Portions Copyright 2015 XWebView
 * Portions Copyright (c) 2014 Intel Corporation.  All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// The workaround for using NSInvocation and NSMethodSignature in Swift.
@protocol _NSMethodSignatureFactory <NSObject>

- (NSMethodSignature *)signatureWithObjCTypes:(const char *)types;

@end

@interface NSMethodSignature (Swift) <_NSMethodSignatureFactory>

@end

@protocol _NSInvocationFactory <NSObject>

- (NSInvocation *)invocationWithMethodSignature:(NSMethodSignature *)sig;

@end

@interface NSInvocation (Swift) <_NSInvocationFactory>

@end

// Special selectors which can't be referenced directly in Swift.
@protocol _SpecialSelectors

// NSObject
- (instancetype)alloc;

- (void)dealloc;

// NSInvocation
- (void)invokeWithTarget:(id)target;

@end

// Special init which can't be reference directly in Swift, but cannot be a protocol either.
@interface _InitSelector: NSObject

// Init with script
- (id)initByScriptWithArguments:(NSArray *)args;

@end

NS_ASSUME_NONNULL_END