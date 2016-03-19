/*
 * Copyright (c) 2016 OffGrid Networks
 *
 * Portions Copyright (c) 2008-2014 Pivotal Labs
 * Portions Copyright (C) 2011-2014 Ivan De Marino
 * Portions Copyright (C) 2014 Alex Treppass
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

module.exports = exports = CallBackReporter;
function CallBackReporter(options)  {
    var timer,
    overallPassed,
    oncomplete = options.onComplete || function(){}
    status = 'loaded';
    
    this.started = false;
    this.finished = false;
    this.runDetails = {};
    
    this.jasmineStarted = function() {
        this.started = true;
        overallPassed = true;
        status = 'started';
        timer = new Timer().start();
    };
    
    var executionTime;
    
    this.jasmineDone = function(runDetails) {
        this.finished = true;
        this.runDetails = runDetails;
        executionTime = timer.elapsed();
        status = 'done';
        oncomplete(overallPassed);
    };
    
    this.status = function() {
        return status;
    };
    
    var suites = [],
    suites_hash = {};
    
    this.suiteStarted = function(result) {
        suites_hash[result.id] = result;
    };
    
    this.suiteDone = function(result) {
        storeSuite(result);
    };
    
    this.suiteResults = function(index, length) {
        return suites.slice(index, index + length);
    };
    
    function storeSuite(result) {
        suites.push(result);
        suites_hash[result.id] = result;
    }
    
    this.suites = function() {
        return suites_hash;
    };
    
    var specs = [];
    
    this.specDone = function(result) {
        result.skipped = result.status === 'pending';
        result.passed = result.skipped || result.status === 'passed';
        overallPassed = overallPassed && result.passed;
        
        specs.push(result);
    };
    
    this.specResults = function(index, length) {
        return specs.slice(index, index + length);
    };
    
    this.specs = function() {
        return specs;
    };
    
    this.executionTime = function() {
        return executionTime;
    };
    
}

var Timer = function () {};

Timer.prototype.start = function () {
    this.startTime = new Date().getTime();
    return this;
};

Timer.prototype.elapsed = function () {
    if (this.startTime == null) {
        return -1;
    }
    return new Date().getTime() - this.startTime;
};
