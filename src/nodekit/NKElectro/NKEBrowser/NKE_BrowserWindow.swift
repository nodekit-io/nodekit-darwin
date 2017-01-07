/*
 * nodekit.io
 *
 * Copyright (c) 2016-7 OffGrid Networks. All Rights Reserved.
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

class NKE_BrowserWindow: NSObject {
    
    internal var _events: NKEventEmitter = NKEventEmitter()
    
    internal static var _windowArray: [Int: NKE_BrowserWindow] = [Int: NKE_BrowserWindow]()
    
    internal var _window: AnyObject?
    
    internal weak var _context: NKScriptContext?
    
    internal weak var _webView: AnyObject?
    
    internal var _browserType: NKEBrowserType = NKEBrowserType.WKWebView
    
    internal var _id: Int = 0
    
    private var _type: String = ""
    
    internal var _options: Dictionary <String, AnyObject> =  Dictionary <String, AnyObject>()
    
    private var _nke_renderer: AnyObject?
    
    internal var _webContents: NKE_WebContentsBase? = nil
    
    override init() {
        
        super.init()
        
    }
    
    // Creates a new BrowserWindow with native properties as set by the options.
    
    required init(options: Dictionary<String, AnyObject>) {
        
        super.init()
        
        // PARSE & STORE OPTIONS
        
        NSLog("BROWSERWINDOW");
        
        self._options["nk.InstallElectro"] = options["nk.InstallElectro"] as? Bool ?? true
        self._options["nk.ScriptContextDelegate"] = options["nk.ScriptContextDelegate"] as? NKScriptContextDelegate
        
        let allowCustomProtocol: Bool = options[NKEBrowserOptions.nkAllowCustomProtocol] as? Bool ?? false
        
        let defaultBrowser: String = allowCustomProtocol ? NKEBrowserType.UIWebView.rawValue : NKEBrowserType.UIWebView.rawValue
        
        self._browserType = NKEBrowserType(rawValue: (options[NKEBrowserOptions.nkBrowserType] as? String) ?? defaultBrowser)!
        
        switch self._browserType {
            
        case .WKWebView:
            
            NKLogging.log("+creating Nitro Renderer")
            
            self._id = self.createWKWebView(options)
            
            self._type = "Nitro"
            
            let webContents: NKE_WebContentsWK = NKE_WebContentsWK(window: self)
            
            self._webContents = webContents
            
        case .UIWebView:
            
            NKLogging.log("+creating JavaScriptCore Renderer")
            
            self._id = self.createUIWebView(options)
            
            self._type = "JavaScriptCore"
            
            let webContents: NKE_WebContentsUI = NKE_WebContentsUI(window: self)
            
            self._webContents = webContents
            
        }
        
        NKE_BrowserWindow._windowArray[self._id] = self
    }
    
    // class functions (for Swift/Objective-C use only, equivalent functions exist in .js helper )
    static func fromId(id: Int) -> NKE_BrowserWindowProtocol? { return NKE_BrowserWindow._windowArray[id] }
    
    var id: Int {
        
        get {
            
            return _id
            
        }
        
    }
    
    var type: String {
        
        get {
            
            return _type
            
        }
        
    }
    
    var webContents: NKE_WebContentsBase {
        
        get {
            
            return _webContents!
            
        }
        
    }
    
    private static func NotImplemented(functionName: String = #function) -> Void {
        
        NKLogging.log("!browserWindow.\(functionName) is not implemented")
        
    }
    
    private func NotImplemented(functionName: String = #function) -> Void {
        
        NKLogging.log("!browserWindow.\(functionName) is not implemented")
        
    }
    
}


extension NKE_BrowserWindow: NKScriptExport {
    
    static func attachTo(context: NKScriptContext) {
        
        let principal = NKE_BrowserWindow.self
        
        context.loadPlugin(principal, namespace: "io.nodekit.electro.BrowserWindow", options: [String:AnyObject]())
        
    }
    
    class func rewriteGeneratedStub(stub: String, forKey: String) -> String {
        
        switch (forKey) {
            
        case ".global":
            
            return NKStorage.getPluginWithStub(stub, "lib-electro.nkar/lib-electro/browser-window.js", NKElectro.self)
            
        default:
            
            return stub
            
        }
        
    }
    
    class func rewriteScriptNameForKey(name: String) -> String? {
        return (name == "initWithOptions:" ? "" : nil)
    }
    
    class func isExcludedFromScript(selector: String) -> Bool {
        
        return selector.hasPrefix("webView") ||
            selector.hasPrefix("NKScriptEngineLoaded") ||
            selector.hasPrefix("NKApplicationReady")
        
    }
    
}

extension NKE_BrowserWindow: NKScriptContextDelegate {
    
    internal func NKScriptEngineDidLoad(context: NKScriptContext) -> Void {
        
        NKLogging.log("+E\(context.id) Renderer Loaded")
        
        self._context = context
        
        // INSTALL JAVASCRIPT ENVIRONMENT ON RENDERER CONTEXT
        
        if (self._options["nk.InstallElectro"] as! Bool)
        {
            NKElectro.bootToRenderer(context)
        }
        
        (self._options["nk.ScriptContextDelegate"] as? NKScriptContextDelegate)?.NKScriptEngineDidLoad(context)
        
        
        
    }
    
    internal func NKScriptEngineReady(context: NKScriptContext) -> Void {
        
        switch self._browserType {
            
        case .WKWebView:
            
            WKScriptEnvironmentReady()
            
        case .UIWebView:
            
            UIScriptEnvironmentReady()
            
        }
        
        (self._options["nk.ScriptContextDelegate"] as? NKScriptContextDelegate)?.NKScriptEngineReady(context)
        
        NKLogging.log("+E\(id) Renderer Ready")
        
    }
    
}
