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

public enum NKEngineType: Int {
 
    case JavaScriptCore  = 0
    
    case Nitro = 1
    
    case UIWebView = 2

}

public class NKScriptContextFactory: NSObject {

    internal static var _contexts: Dictionary<Int, AnyObject> = Dictionary<Int, AnyObject>()

    public class var sequenceNumber: Int {

        struct sequence {
        
            static var number: Int = 0
        
        }
       
        let temp = sequence.number
       
        sequence.number += 1
       
        return temp
    
    }

    public func createScriptContext(options: [String: AnyObject] = Dictionary<String, AnyObject>(), delegate cb: NKScriptContextDelegate) {
    
        let engine = NKEngineType(rawValue: (options["Engine"] as? Int)!) ?? NKEngineType.JavaScriptCore

        switch engine {
        
        case .JavaScriptCore:
        
            self.createContextJavaScriptCore(options, delegate: cb)
         
        case .Nitro:
        
            self.createContextWKWebView(options, delegate: cb)
        
        case .UIWebView:
        
            self.createContextUIWebView(options, delegate: cb)
        
        }
    
    }
    
    public static var defaultQueue: dispatch_queue_t = {
        
        let label = "io.nodekit.scripting.default-queue"
        
        return dispatch_queue_create(label, DISPATCH_QUEUE_SERIAL)
        
    }()

}


public protocol NKScriptContextHost: class {
    
    func NKcreateScriptContext(id: Int, options: [String: AnyObject], delegate cb: NKScriptContextDelegate) -> Void
    
}
