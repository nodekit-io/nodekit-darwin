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

public class NodeKit: NSObject {
    
    public class func attachTo(context: NKScriptContext) {
        NodeKit.addCorePlatform(context);
        NodeKit.bootCore(context);
    }


    public class func addCorePlatform(context: NKScriptContext) {
       
        NKStorage.includeBundle(NSBundle(forClass: NodeKit.self))
        
        // PROCESS SHOULD BE FIRST CORE PLATFORM PLUGIN
        
        NKC_Process.attachTo(context)
        
        // LOAD REMAINING CORE PLATFORM PLUGINS
        
        NKC_FileSystem.attachTo(context)
        
        NKC_Console.attachTo(context)
        
        NKC_Crypto.attachTo(context)
        
        NKC_SocketTCP.attachTo(context)
        
        NKC_SocketUDP.attachTo(context)
        
        NKC_Timer.attachTo(context)
        
    }
    
    public class func bootCore(context: NKScriptContext) {
    
        guard let script = NKStorage.getResource("lib-core.nkar/lib-core/_nodekit_bootstrapper.js", NodeKit.self) else {
        
            NKLogging.die("Failed to read bootstrapper script")
        
        }

        context.injectJavaScript(NKScriptSource(source: script, asFilename: "io.nodekit.core/_nodekit_bootstrapper.js", namespace: "io.nodekit.bootstrapper"))
        
    
    }

}
