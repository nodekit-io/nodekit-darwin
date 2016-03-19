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
@testable import NodeKit

class NKT_TestRunner: NSObject, NKScriptExport {
    
    static var current: NKT_TestRunner = NKT_TestRunner()
    
    class func attachTo(context: NKScriptContext) {
        context.NKloadPlugin(NKT_TestRunner.current, namespace: "io.nodekit.test.runner", options: [String:AnyObject]())
    }
    
    func rewriteGeneratedStub(stub: String, forKey: String) -> String {
        switch (forKey) {
        case ".global":
            let url = NSBundle(forClass: NKT_TestRunner.self).pathForResource("testrunner", ofType: "js", inDirectory: "lib-test")
            let appjs = try? NSString(contentsOfFile: url!, encoding: NSUTF8StringEncoding) as String
            return "function loadplugin(){\n" + appjs! + "\n}\n" + stub + "\n" + "loadplugin();" + "\n"
        default:
            return stub
        }
    }
    
    override init() {
        done = nil;
    }
    
    private var done: ((Bool) -> Void)?
    
    func ready() -> Void {
        NKEventEmitter.global.emit("nkt.Ready", 0);
    }
    
    func _start(callback: (Bool) -> Void) -> Void {
        self.done = callback
        self.NKscriptObject!.invokeMethod("emit", withArguments: ["nk.TestStart", 0], completionHandler: nil)
    }
    
    func complete(passed: Bool) {
        done?(passed)
    }
}