/*
* nodekit.io
*
* Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
* Portions Copyright (c) 2013 GitHub, Inc. under MIT License
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

import WebKit

// MUST INHERIT
class NKE_WebContentsBase: NSObject {

    internal weak var _window: NKE_BrowserWindow!
    
    internal var _id: Int = 0
    
    internal var _type: String = ""
    
    internal var globalEvents: NKEventEmitter = NKEventEmitter.global
    
    override init() {
    
        super.init()
   
    }
    
    required init(window: NKE_BrowserWindow) {
     
        super.init()
        
        _window = window
        
        _id = window.id
        
        _window._events.on("did-finish-load") { (id: Int) in
        
            self.NKscriptObject?.invokeMethod("emit", withArguments: ["did-finish-load"], completionHandler: nil)
        
        }
        
        _window._events.on("did-fail-loading") { (id: Int, error: String) in
        
            self.NKscriptObject?.invokeMethod("emit", withArguments: ["did-fail-loading", error], completionHandler: nil)
        
        }
        
        _initIPC()
   
    }
    
}

extension NKE_WebContentsBase: NKScriptExport {

    private static var loaded: Int = 0

    static func attachTo(context: NKScriptContext) {
    
        let principal = NKE_WebContentsUI.self
        
        context.loadPlugin(principal, namespace: "io.nodekit.electro.WebContentsUI", options: [String:AnyObject]())
        
        let principal2 = NKE_WebContentsWK.self
        
        context.loadPlugin(principal2, namespace: "io.nodekit.electro.WebContentsWK", options: [String:AnyObject]())
    
    }

    class func rewriteGeneratedStub(stub: String, forKey: String) -> String {
        
        switch (forKey) {
    
        case ".global":
        
            let temp = NKE_WebContentsBase.loaded
            
            NKE_WebContentsBase.loaded += 1
            
            if (temp < 1 ) { return stub; }
            
            return NKStorage.getPluginWithStub(stub, "lib-electro.nkar/lib-electro/web-contents.js", NKElectro.self)
        
        default:
        
            return stub
        }
    
    }

    class func rewriteScriptNameForKey(name: String) -> String? {
        return (name == "initWithWindow:" ? "" : nil)
    }

    internal class func NotImplemented(functionName: String = #function) -> Void {
    
        NKLogging.log("!WebContents.\(functionName) is not implemented")
    
    }

    internal func _getURLRequest(url: String, options: [String: AnyObject]) -> NSURLRequest {
    
        let httpReferrer = options["httpReferrer"] as? String
        
        let userAgent = options["userAgent"] as? String
        
        let extraHeaders = options["extraHeaders"] as? [String: AnyObject]

        let url = NSURL(string: url)!
        
        let request = NSMutableURLRequest(URL: url)

        if ((userAgent) != nil) {
        
            request.setValue(userAgent!, forHTTPHeaderField: "User-Agent")
        
        }

        if ((httpReferrer) != nil) {
        
            request.setValue(httpReferrer!, forHTTPHeaderField: "Referrer")
        
        }

        if ((extraHeaders != nil) && (!(extraHeaders!.isEmpty))) {
        
            for (key, value) in extraHeaders! {
            
                request.setValue(value as? String, forHTTPHeaderField: key)
            
            }
        
        }
        
        return request
    
    }

}

extension NKE_WebContentsBase {

       // Replies to main are subscribed to in the window events queue for the WebContents renderer proxy that executes in main process

    func _initIPC() {
    
        self._window?._events.on("nk.IPCReplytoMain") { (item: NKE_IPC_Event) -> Void in
        
            self.NKscriptObject?.invokeMethod("emit", withArguments: ["nk.IPCReplytoMain", item.sender, item.channel, item.replyId, item.arg[0]], completionHandler: nil)
       
        }
    
    }

}
