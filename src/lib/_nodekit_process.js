/*
 * Copyright 2015 Domabo
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

(function(process) {
    
  process._nextTick = (function () {
                       
                     var canSetTimeOut = typeof window !== 'undefined'
                     && window.setTimeout;
                    
                     var canSetImmediate = typeof window !== 'undefined'
                     && window.setImmediate;
                     
                     var canPost = typeof window !== 'undefined'
                     && window.postMessage && window.addEventListener;
                     
                     if (canSetImmediate) {
                       
                     return function (f) { return window.setImmediate(f) };
                     }
                     
                     if (canPost) {
                       
                         var queue = [];
                         window.addEventListener('message', function (ev) {
                                                 var source = ev.source;
                                                 if ((source === window || source === null) && ev.data === 'process-tick') {
                                                 ev.stopPropagation();
                                                 if (queue.length > 0) {
                                                 var fn = queue.shift();
                                                 fn();
                                                 }
                                                 }
                                                 }, true);
                         
                         return function nextTick(fn) {
                         queue.push(fn);
                         window.postMessage('process-tick', '*');
                         };
                    }
                     
                     if (canSetImmediate) {
                       
                        return function nextTick(fn) {setTimeout(fn, 0);};
                     }
                       
                       return function(f) {
                       
                          var args = Array.prototype.slice.call(arguments, 1);
                       return io.nodekit.console.nextTick(function(){
                                                          f.apply(null, args);
                                                          });
                       };
                     
                     })();

    process._asyncFlags = {};
    process.moduleLoadList = [];
    
    process._setupAsyncListener = function(asyncFlags, runAsyncQueue, loadAsyncQueue, unloadAsyncQueue) {
        process._runAsyncQueue = runAsyncQueue;
        process._loadAsyncQueue = loadAsyncQueue;
        process._unloadAsyncQueue = unloadAsyncQueue;
    };
    
    process._setupNextTick = function(_tickCallback, _runMicrotasks) {
        _runMicrotasks.runMicrotasks = function(){};
        process._tickCallback = _tickCallback;
        process.nextTick = process._nextTick;
        return {};
    //    _tickCallback();
    };
 
 process._setupPromises = function(fn){};
    
    process._setupDomainUse = function() {};
    process.cwd = function cwd() { return  process.workingDirectory; };
    process.isatty = false;
 
  process.versions = {"http_parser":"2.5.0","node":"4.2.3","v8":"4.5.103.35","uv":"1.7.5","zlib":"1.2.8","ares":"1.10.1-DEV","icu":"56.1","modules":"46","openssl":"1.0.2e"}
 
    process.version = 'v4.2.3';
   process.execArgv = ['--nodekit'];
 
 if (Error.captureStackTrace === undefined) {
 Error.captureStackTrace = function (obj) {
 if (Error.prepareStackTrace) {
 var frame = {
 isEval: function () { return false; },
 getFileName: function () { return "filename"; },
 getLineNumber: function () { return 1; },
 getColumnNumber: function () { return 1; },
 getFunctionName: function () { return "functionName" }
 };
 
 obj.stack = Error.prepareStackTrace(obj, [frame, frame, frame]);
 } else {
 obj.stack = obj.stack || obj.name || "Error";
 }
 };

 }
 
 
});
