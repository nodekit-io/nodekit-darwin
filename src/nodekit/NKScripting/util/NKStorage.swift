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

public class NKStorage: NSObject {
    
    // PUBLIC METHODS, ACCESSIBLE FROM JAVASCRIPT
    
    func getSourceSync(module: String) -> String {
        
        guard let data = NKStorage.getResourceData(module) else { return "" }
        
        return (data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)))
        
    }
    
    // PUBLIC METHODS NATIVE SIDE ONLY
    
    public static var mainBundle = NKStorage.mainBundle_()
    
    public class func getResource(module: String, _ t: AnyClass? = nil) -> String? {
        
        if module.lowercaseString.rangeOfString(".nkar/") != nil {
            return getNKARResource_(module, t)
        }
        
        let bundle = (t != nil) ?  NSBundle(forClass: t!) :  NKStorage.mainBundle
        
        guard let path = getPath_(bundle, module),
            
            let source = try? NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) else {
                
                return nil
                
        }
        
        return source as String
        
    }
    
    public class func getResourceData(module: String, _ t: AnyClass? = nil) -> NSData? {
        
        if module.lowercaseString.rangeOfString(".nkar/") != nil {
            return getNKARData_(module, t)
        }
        
        let bundle = (t != nil) ?  NSBundle(forClass: t!) :  NKStorage.mainBundle
        
        guard let path = getPath_(bundle, module),
            
            let data = try? NSData(
                contentsOfFile: path as String,
                options: NSDataReadingOptions(rawValue: 0)
            )
            
            else { return nil }
        
        return data
        
    }
    
    public class func getPluginWithStub(stub: String, _ module: String, _ t: AnyClass? = nil) -> String {
        
        guard let appjs = NKStorage.getResource(module, t) else {
            
            NKLogging.die("Failed to read script")
            
        }
        
        return "function loadplugin(){\n" + appjs + "\n}\n" + stub + "\n" + "loadplugin();" + "\n"
    }
    
    public class func includeBundle(bundle: NSBundle) -> Void {
        
       if !bundles.contains({ $0 === bundle })
       {
          bundles.append(bundle)
        }
    }
    
    // PRIVATE METHODS
    
    private static var unzipper_ : NKArchiveReader? = nil
    
    private static var bundles : [NSBundle] = [ NSBundle(forClass: NKStorage.self) ]
    
    private class func getNKARResource_(module: String, _ t: AnyClass? = nil) -> String? {
            
        guard let data = getNKARData_(module, t) else { return nil }
        
        return NSString(data: data, encoding: NSUTF8StringEncoding) as String?
        
    }
    
    private class func getNKARData_(module: String, _ t: AnyClass? = nil) -> NSData? {
        
        let moduleArr = module.componentsSeparatedByString(".nkar/")
        
        let nkarModule: String = moduleArr[0] + ".nkar"
        
        let resource: String = moduleArr[1]
        
        let bundle = (t != nil) ?  NSBundle(forClass: t!) :  NKStorage.mainBundle
        
        unzipper_ = unzipper_ ?? NKArchiveReader.create()
        
        guard let nkarPath = getPath_(bundle, nkarModule),
            
            let data = unzipper_?.dataForFile(nkarPath, filename: resource)
            
            else { return nil }
        
        return data
        
    }

    private class func getPath_(mainBundle: NSBundle, _ module: String) -> String? {
        
        let directory = (module as NSString).stringByDeletingLastPathComponent
        
        var fileName = (module as NSString).lastPathComponent
        
        var fileExtension = (fileName as NSString).pathExtension
        
        fileName = (fileName as NSString).stringByDeletingPathExtension
        
        if (fileExtension=="") {
        
            fileExtension = "js"
        
        }
        
        var path = mainBundle.pathForResource(fileName, ofType: fileExtension, inDirectory: directory)
        
        if (path == nil) {
            
            for _nodeKitBundle in bundles {
                
                path = _nodeKitBundle.pathForResource(fileName, ofType: fileExtension, inDirectory: directory)
                
                if !(path == nil) { break; }

            }
            
            if (path == nil) {
                
                NKLogging.log("!Error - source file not found: \(directory + "/" + fileName + "." + fileExtension)")
        
                return nil
            
            }
        
        }
        
        return path!
        
    }
    
    private class func mainBundle_() -> NSBundle {
        
        #if swift(>=3)
            
            var bundle = Bundle.main()
            
            if bundle.bundleURL.pathExtension == "appex" {
            
            // Peel off two directory levels - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
            
            if let url = try? bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent() {
            
                    if let appBundle = Bundle(url: url) {
            
                        bundle = appBundle
            
                    }
            
                }
            
            }
            
            return bundle
            
        #else
            
            var bundle = NSBundle.mainBundle()
            
            if bundle.bundleURL.pathExtension == "appex" {
                
                // Peel off two directory levels - MY_APP.app/PlugIns/MY_APP_EXTENSION.appex
                
                if let url = bundle.bundleURL.URLByDeletingLastPathComponent?.URLByDeletingLastPathComponent {
                    
                    if let appBundle = NSBundle(URL: url) {
                        
                        bundle = appBundle
                    }
                    
                }
                
            }
            
            return bundle
            
        #endif
    }
    
}

extension NKStorage:  NKScriptExport {
    
    class func attachTo(context: NKScriptContext) {
        
        context.NKloadPlugin(NKStorage(), namespace: "io.nodekit.scripting.storage", options: [String:AnyObject]())
        
    }
    
    public func rewriteGeneratedStub(stub: String, forKey: String) -> String {
        
        switch (forKey) {
            
        case ".global":
            
            return NKStorage.getPluginWithStub(stub, "lib-scripting.nkar/native_module.js", NKStorage.self)
            
        default:
            
            return stub
            
        }
    }
    
    public class func isSelectorExcludedFromScript(selector: Selector) -> Bool {
        
        return selector.description.hasPrefix("getPluginWithStub") ||
            selector.description.hasPrefix("getResource") ||
            selector.description.hasPrefix("getResourceData")
        
    }

}

