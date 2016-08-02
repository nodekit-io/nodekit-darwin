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
import ObjectiveC
import WebKit

extension WKWebView: NKScriptContext, NKScriptContextHost {

    public var NKid: Int { get { return objc_getAssociatedObject(self, unsafeAddressOf(NKJSContextId)) as! Int; } }

    public func NKgetScriptContext(id: Int, options: [String: AnyObject] = Dictionary<String, AnyObject>(),
        delegate cb: NKScriptContextDelegate) -> Void {
     
        NKLogging.log("+NodeKit Nitro JavaScript Engine E\(id)")

        self.navigationDelegate = NKWKWebViewDelegate(id: id, webView: self, delegate: cb)
        
        self.UIDelegate = NKWKWebViewUIDelegate(webView: self)

        objc_setAssociatedObject(self, unsafeAddressOf(NKJSContextId), id, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        self.NKPrepareEnvironment()
            
        cb.NKScriptEngineDidLoad(self)
    }
    
    private func NKPrepareEnvironment() -> Void {
        
        let context = self;
        
        let handler: WKScriptMessageHandler = WKWebViewLogger.current
        
        context.configuration.userContentController.addScriptMessageHandler(handler, name: "NKScriptingBridgeLog")
        
        let appjs = NKStorage.getResource("lib-scripting.nkar/init_nitro.js", NKScriptChannel.self)
        
        let script = "function loadinit(){\n" + appjs! + "\n}\n" + "loadinit();" + "\n"
        
        context.NKinjectJavaScript(NKScriptSource(source: script, asFilename: "io.nodekit.scripting/init_nitro.js", namespace: "io.nodekit.scripting.init"))
        
        NKStorage.attachTo(context)

    }


    public func NKloadPlugin(object: AnyObject, namespace: String, options: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>() ) -> Void {

        let mainThread: Bool = (options["MainThread"] as? Bool) ?? false

        let bridge = options["PluginBridge"] as? NKScriptExportType ?? NKScriptExportType.NKScriptExport

        switch bridge {
        
        case .JSExport:
        
            NSException(name: "Not Supported", reason: "WKWebView does not support JSExport protocol", userInfo: nil).raise()
            
            return;
      
        case .NKScriptExport:
        
            let channel: NKScriptChannel
            
            if (mainThread) {
            
                channel = NKScriptChannel(context: self, queue: dispatch_get_main_queue() )
           
            } else {
            
                channel = NKScriptChannel(context: self)
           
            }
            
            channel.userContentController = self
            
            guard let pluginValue = channel.bindPlugin(object, toNamespace: namespace) else {return;}
            
            objc_setAssociatedObject(self, unsafeAddressOf(pluginValue), pluginValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        }
        
    }

    public func NKinjectJavaScript(script: NKScriptSource) -> Void {
        
        let item = NKWKUserScript(context: (self as WKWebView), script: script)
        
        objc_setAssociatedObject(self, unsafeAddressOf(item), item, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    
    }

    public func NKevaluateJavaScript(javaScriptString: String,
        completionHandler: ((AnyObject?,
        NSError?) -> Void)?) {
    
        self.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
    
    }
    
 
    public static func NKcurrentContext() -> NKScriptContext! {
    
        return NSThread.currentThread().threadDictionary.objectForKey("nk.CurrentContext") as? NKScriptContext
    
    }

    public func NKserialize(object: AnyObject?) -> String {
    
        var obj: AnyObject? = object
        
        if let val = obj as? NSValue {
        
            obj = val as? NSNumber ?? val.nonretainedObjectValue
       
        }

        if let o = obj as? NKScriptValue {
        
            return o.namespace
       
        } else if let o1 = obj as? NKScriptExport {
       
            if let o2 = o1 as? NSObject {
            
                if let scriptObject = o2.NKscriptObject {
                
                    return scriptObject.namespace
               
                } else {
                
                    let scriptObject = NKScriptValueNative(object: o2, inContext: self)
                    
                    objc_setAssociatedObject(o2, unsafeAddressOf(NKScriptValue), scriptObject, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                   
                    return scriptObject.namespace
                
                }
            
            }
       
        } else if let s = obj as? String {
        
            let d = try? NSJSONSerialization.dataWithJSONObject([s], options: NSJSONWritingOptions(rawValue: 0))
            
            let json = NSString(data: d!, encoding: NSUTF8StringEncoding)!
           
            return json.substringWithRange(NSMakeRange(1, json.length - 2))
       
        } else if let n = obj as? NSNumber {
        
            if CFGetTypeID(n) == CFBooleanGetTypeID() {
            
                return n.boolValue.description
           
            }
            
            return n.stringValue
       
        } else if let date = obj as? NSDate {
        
            return "\"\(date.toJSONDate())\""
       
        } else if let _ = obj as? NSData {
        
            // TODO: map to Uint8Array object
       
        } else if let a = obj as? [AnyObject] {
        
            return "[" + a.map(self.NKserialize).joinWithSeparator(", ") + "]"
       
        } else if let d = obj as? [String: AnyObject] {
        
            return "{" + d.keys.map {"\"\($0)\": \(self.NKserialize(d[$0]!))"}.joinWithSeparator(", ") + "}"
       
        } else if obj === NSNull() {
        
            return "null"
       
        } else if obj == nil {
        
            return "undefined"
       
        }
        
        return "'\(obj!.description)'"
    
    }

}

extension WKWebView: NKScriptContentController {

    internal func NKaddScriptMessageHandler (scriptMessageHandler: NKScriptMessageHandler, name: String) {
    
        let handler: WKScriptMessageHandler = NKWKMessageHandler(name: name, messageHandler: scriptMessageHandler, context: self)
       
        self.configuration.userContentController.addScriptMessageHandler(handler, name: name)
  
    }

    
    internal func NKremoveScriptMessageHandlerForName (name: String) {
    
        self.configuration.userContentController.removeScriptMessageHandlerForName(name)
    
    }

}

public class WKWebViewLogger: NSObject, WKScriptMessageHandler {
    
    static var current = WKWebViewLogger()
    
    public func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage)
    {
        
        guard unsafeBitCast(message.body, COpaquePointer.self) != nil else { return }
        
         NKLogging.log(message.body as! String)
    }
    
}
