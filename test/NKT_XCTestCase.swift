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

import Foundation
import XCTest
@testable import NodeKit

class NKT_XCTestCase: XCTestCase {
    
    override class func setUp() {
        
        super.setUp()
        
        var finished = false
        
        let options: [String: AnyObject] = [
            "nk.MainBundle": NSBundle(forClass: NKT_XCTestCase.self),
            "nk.Test": true
        ]
        
        NKNodeKit.start(options, delegate: myDelegate())
        
        NKEventEmitter.global.once("nkt.Ready") { (count: Int) -> Void in
            finished = true
        }
        
        while !finished {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture())
        }
        
    }
    
    func testNodeKit(){
        let expectation = expectationWithDescription("NodeKit Expectation")
        NKT_TestRunner.current._start() { (passed: Bool) -> Void in
            if (!passed)
            {
                XCTFail("JavaScript Tests Did Not Pass")
            }
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(10.0, handler:nil)
        
    }
}

class myDelegate: NKScriptContextDelegate {
    
    func NKScriptEngineDidLoad(context: NKScriptContext) -> Void {
        NKT_TestRunner.attachTo(context)
    }
    
    func NKScriptEngineReady(context: NKScriptContext) -> Void {
    }
}