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

import Foundation

public protocol NKScriptContext: class {
    
    var id: Int { get }

    func loadPlugin(object: AnyObject, namespace: String, options: Dictionary<String, AnyObject>) -> Void
    
    func injectJavaScript(script: NKScriptSource) -> Void
    
    func evaluateJavaScript(javaScriptString: String, completionHandler: ((AnyObject?,NSError?) -> Void)?)
    
    func serialize(object: AnyObject?) -> String

}


internal protocol NKScriptContentController: class {

    func addScriptMessageHandler (scriptMessageHandler: NKScriptMessageHandler, name: String)
    
    func removeScriptMessageHandlerForName (name: String)

}

public protocol NKScriptContextDelegate: class {

    func NKScriptEngineDidLoad(context: NKScriptContext) -> Void
    
    func NKScriptEngineReady(context: NKScriptContext) -> Void

}

public enum NKScriptExportType: Int {
    
    case NKScriptExport = 0
    
    case JSExport
    
}

@objc public protocol NKScriptExport : class {
    
    optional func rewriteGeneratedStub(stub: String, forKey: String) -> String
    
    optional static func rewriteScriptNameForKey(name: String) -> String?
    
    optional static func isExcludedFromScript(name: String) -> Bool
    
    //   optional static func initializeForContext(context: NKScriptContext, completionHandler:)
 
}


public class NKJSContextId {}
