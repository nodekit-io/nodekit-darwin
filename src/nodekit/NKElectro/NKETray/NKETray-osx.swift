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

#if os(OSX)
    
import Foundation

import Cocoa

class NKE_Tray: NSObject {
    
    internal var _events: NKEventEmitter = NKEventEmitter()
    
    internal static var _trayArray: [Int: NKE_Tray] = [Int: NKE_Tray]()
   
    internal var _tray: AnyObject?
    
    internal var _id: Int = 0
    
    override init() {
    
        super.init()
    
    }
    
    // Creates a new NKE_Tray
    
    required init(imageName: String) {
    
        super.init()
        
        self._id = self.createTrayType1(imageName)
        
        NKE_Tray._trayArray[self._id] = self
    
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
        
            return "Type1"
        
        }
    
    }
    
    private static func NotImplemented(functionName: String = #function) -> Void {
    
        NKLogging.log("!tray.\(functionName) is not implemented")
    
    }
    
    private func NotImplemented(functionName: String = #function) -> Void {
    
        NKLogging.log("!tray.\(functionName) is not implemented")
    
    }
    
}

extension NKE_Tray {
    
    internal func createTrayType1(imageName: String) -> Int {
        
        let id = NKScriptContextFactory.sequenceNumber
        
        let createBlock = {() -> Void in
            
            let tray = self.createTray(imageName) as! NSStatusItem
            
            self._tray = tray
    
            self._events.emit("did-finish-load", self._id)
        
        }
        
        if (NSThread.isMainThread()) {
        
            createBlock()
        
        } else {
        
            dispatch_async(dispatch_get_main_queue(), createBlock)
        
        }
        
        return id
    
    }
    
    internal func createTray(imageName: String) -> AnyObject {
        
        let mainBundle: NSBundle = NSBundle.mainBundle()
    
        guard let image: NSImage = mainBundle.imageForResource(imageName) else { return "" }
        
        let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(24)
        
        if let statusButton = statusItem.button {
        
            statusButton.image = image
         }

        return statusItem
    }
}

extension NKE_Tray: NKScriptExport {
    
    static func attachTo(context: NKScriptContext) {
        
        let principal = NKE_Tray.self
        
        context.loadPlugin(principal, namespace: "io.nodekit.electro.Tray", options: [String:AnyObject]())
    
    }
    
    class func rewriteGeneratedStub(stub: String, forKey: String) -> String {
    
        switch (forKey) {
        
        case ".global":
        
            return NKStorage.getPluginWithStub(stub, "lib-electro.nkar/lib-electro/tray.js", NKElectro.self)
        
        default:
        
            return stub
        
        }
    
    }
    
    
    class func rewriteScriptNameForKey(name: String) -> String? {
        return (name == "initWithImageName:" ? "" : nil)
    }
    
    
    class func isExcludedFromScript(selector: String) -> Bool {
    
        return selector.hasPrefix("webView") ||
            selector.hasPrefix("createTray") ||
            selector.hasPrefix("createTrayType1") ||
            selector.hasPrefix("NKScriptEngineLoaded") ||
            selector.hasPrefix("NKApplicationReady")
    
    }

}
    
#endif