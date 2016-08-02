/*
 * nodekit.io
 *
 * Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
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

var native = io.nodekit.platform;

if (!process || !process.bootstrap)
{
    throw new Error("This Scripting Engine is missing Bootstrap Storage Module")
}

process.binding = function(id) {
    return process.bootstrap.NativeModule._load('lib-core.nkar/lib-core/bindings/' + id + '.js');
};

process.bootstrap.NativeModule.setPreCacheSources(process.binding('natives'));

console.log = native.console.log;

// run vanilla node.js startup
process.bootstrap.NativeModule.bootstrap('lib-core.nkar/lib-core/node.js');

global.setImmediate = function(fn){ process.nextTick(fn.bind.apply(fn, arguments)) }

console.log = native.console.log;
console.warn = console.log;
console.error = native.console.error;

try
{
    process._tickCallback();
}
catch (e)
{
    console.error( "tickCallBack in nodekit_bootstrapper" + e.toString());
}
