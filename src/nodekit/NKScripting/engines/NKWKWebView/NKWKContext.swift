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

public class NKWKContext: NSObject {
    
    private let _wkContext: WKWebView
    private let _id: Int
    
    internal init(_ context: WKWebView, id: Int) {
        _wkContext = context
        _id = id

        super.init()
        
        objc_setAssociatedObject(context, unsafeAddressOf(NKWKContext), self, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
    }

    internal func prepareEnvironment() -> Void {
        
        let handler: WKScriptMessageHandler = WKWebViewLogger.current
        
        _wkContext.configuration.userContentController.addScriptMessageHandler(handler, name: "NKScriptingBridgeLog")
        
        let appjs = NKStorage.getResource("lib-scripting.nkar/lib-scripting/init_nitro.js", NKScriptChannel.self)
        
        let script = "function loadinit(){\n" + appjs! + "\n}\n" + "loadinit();" + "\n"
        
        self.injectJavaScript(NKScriptSource(source: script, asFilename: "io.nodekit.scripting/init_nitro.js", namespace: "io.nodekit.scripting.init"))
        
        NKStorage.attachTo(self)

    }
}

extension NKWKContext: NKScriptContext {

    public var id: Int {
        get { return self._id }
    }

    public func loadPlugin(object: AnyObject, namespace: String, options: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>() ) -> Void {

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

    public func injectJavaScript(script: NKScriptSource) -> Void {
        
        let wkscript = WKUserScript(source: script.source,
                                     injectionTime: WKUserScriptInjectionTime.AtDocumentStart,
                                     forMainFrameOnly: true)
        
        _wkContext.configuration.userContentController.addUserScript(wkscript)

        objc_setAssociatedObject(script, unsafeAddressOf(wkscript), wkscript, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        objc_setAssociatedObject(self, unsafeAddressOf(script), script, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        script.inject(self)
        
    }

    public func evaluateJavaScript(javaScriptString: String,
        completionHandler: ((AnyObject?,
        NSError?) -> Void)?) {
        
        if _wkContext.URL != nil {
            
            self.evaluateJavaScript(javaScriptString, completionHandler: completionHandler)
        
        } else {
            
            completionHandler?(nil, nil)
        
        }
    
    }
    

    public func serialize(object: AnyObject?) -> String {
    
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
        
            return "[" + a.map(self.serialize).joinWithSeparator(", ") + "]"
       
        } else if let d = obj as? [String: AnyObject] {
        
            return "{" + d.keys.map {"\"\($0)\": \(self.serialize(d[$0]!))"}.joinWithSeparator(", ") + "}"
       
        } else if obj === NSNull() {
        
            return "null"
       
        } else if obj == nil {
        
            return "undefined"
       
        }
        
        return "'\(obj!.description)'"
    
    }

}

extension NKWKContext: NKScriptContentController {

    internal func addScriptMessageHandler (scriptMessageHandler: NKScriptMessageHandler, name: String) {
    
        let handler: WKScriptMessageHandler = NKWKMessageHandler(name: name, messageHandler: scriptMessageHandler, context: self)
       
        self._wkContext.configuration.userContentController.addScriptMessageHandler(handler, name: name)
  
    }

    
    internal func removeScriptMessageHandlerForName (name: String) {
    
        self._wkContext.configuration.userContentController.removeScriptMessageHandlerForName(name)
    
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
