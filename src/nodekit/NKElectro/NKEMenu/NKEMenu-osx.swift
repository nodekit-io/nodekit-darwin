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
    
// NKElectro MENU Placeholder code only:  on roadmap but lower priority as not supported on mobile

import Foundation

import Cocoa

extension NKE_Menu: NKScriptExport {

    static func attachTo(context: NKScriptContext) {

        let principal = NKE_Menu()
        
        context.loadPlugin(principal, namespace: "io.nodekit.electro._menu", options: [String:AnyObject]())
    
    }

    func rewriteGeneratedStub(stub: String, forKey: String) -> String {
    
        switch (forKey) {
        
        case ".global":
        
            let appjs = NKStorage.getResource("lib-electro.nkar/lib-electro/menu.js", NKElectro.self)
            
            let appjs2 = NKStorage.getResource("lib-electro.nkar/lib-electro/menu-item.js", NKElectro.self)
            
            return "function loadplugin1(){\n" + appjs! + "\n}\n" + "\n" + "function loadplugin2(){\n" + appjs2! + "\n}\n" + stub + "\n" + "loadplugin1(); loadplugin2();" + "\n"
       
        default:
        
            return stub
        
        }
    
    }

}

class NKE_Menu: NSObject, NKEMenuProtocol {

    func setApplicationMenu(menu: [String: AnyObject]) -> Void { NKE_Menu.NotImplemented(); }

    func sendActionToFirstResponder(action: String) -> Void { NKE_Menu.NotImplemented(); } //OS X

    private static func NotImplemented(functionName: String = #function) -> Void {
    
        NKLogging.log("!menu.\(functionName) is not implemented")
    
    }
}

#endif