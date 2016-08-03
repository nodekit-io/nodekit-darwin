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
import NodeKit

class myNKDelegate: NSObject, NKScriptContextDelegate {
    func NKScriptEngineDidLoad(context: NKScriptContext) -> Void {
        SamplePlugin.attachTo(context)
        NodeKit.attachTo(context)
     }
    
    func NKScriptEngineReady(context: NKScriptContext) -> Void {
      
    }
}

NSUserDefaults.standardUserDefaults().setBool(true, forKey: "WebKitDeveloperExtras")
NSUserDefaults.standardUserDefaults().synchronize()

/*NKEventEmitter.global.once("nkt.Ready") { (count: Int) -> Void in
    
    NKT_TestRunner.current._start() { (passed: Bool) -> Void in
        if (!passed)
        {
            NKLogging.log(":::::::::JavaScript Tests Did Not Pass")
            exit(255)
        } else
        {
            NKLogging.log(":::::::::JavaScript Tests Passed")
            exit(0)
            
        }
        
    }
} */

NKElectroHost.start([String: AnyObject](), delegate: myNKDelegate() )



