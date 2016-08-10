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
    
    private static let fileManager = NSFileManager.defaultManager()
    
    public class func getResourceData(module: String, _ t: AnyClass? = nil) -> NSData? {
        
        if module.lowercaseString.rangeOfString(".nkar/") != nil {
            return getDataNKAR_(module, t)
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
    
    public class func includeSearchPath(path: String) -> Void {
        
        if !searchPaths.contains(path)
        {
            searchPaths.append(path)
        }
    }
    
    public class func exists(module: String, _ t: AnyClass? = nil) -> Bool {
        
        if module.lowercaseString.rangeOfString(".nkar/") != nil {
            return existsNKAR_(module, t)
        }
        
        let bundle = (t != nil) ?  NSBundle(forClass: t!) :  NKStorage.mainBundle
        
        if (getPath_(bundle, module) != nil) { return true } else { return false}
        

    }
    
    // PRIVATE METHODS
    
    private static var unzipper_ : NKArchiveReader? = nil
    
    private static var bundles : [NSBundle] = [ NSBundle(forClass: NKStorage.self) ]
    
    private static var searchPaths : [String] = [String]()
    
    private class func getNKARResource_(module: String, _ t: AnyClass? = nil) -> String? {
            
        guard let data = getDataNKAR_(module, t) else { return nil }
        
        return NSString(data: data, encoding: NSUTF8StringEncoding) as String?
        
    }
    
    private class func existsNKAR_(module: String, _ t: AnyClass? = nil) -> Bool {
        
        let moduleArr = module.componentsSeparatedByString(".nkar/")
        
        let nkarModule: String = moduleArr[0] + ".nkar"
        
        var resource: String = moduleArr[1]
        
        let bundle = (t != nil) ?  NSBundle(forClass: t!) :  NKStorage.mainBundle
        
        unzipper_ = unzipper_ ?? NKArchiveReader.create()
        
        let fileExtension = (resource as NSString).pathExtension
        
        if (fileExtension=="") {
            
            resource += ".js"
            
        }
        
        guard let nkarPath = getPath_(bundle, nkarModule)   else { return false }
        
        return  unzipper_!.exists(nkarPath, filename: resource)
        
    }
    
    private class func statNKAR_(module: String, _ t: AnyClass? = nil) -> Dictionary<String, AnyObject> {
        
        let moduleArr = module.componentsSeparatedByString(".nkar/")
        
        let nkarModule: String = moduleArr[0] + ".nkar"
        
        let resource: String = moduleArr[1]
        
        let bundle = (t != nil) ?  NSBundle(forClass: t!) :  NKStorage.mainBundle
        
        unzipper_ = unzipper_ ?? NKArchiveReader.create()
        
        guard let nkarPath = getPath_(bundle, nkarModule) else { return Dictionary<String, AnyObject>() }
        
        return  unzipper_!.stat(nkarPath, filename: resource)
        
    }
    
    private class func getDirectoryNKAR_(module: String, _ t: AnyClass? = nil) -> [String] {
        
        let moduleArr = module.componentsSeparatedByString(".nkar/")
        
        let nkarModule: String = moduleArr[0] + ".nkar"
        
        let resource: String = moduleArr[1]
        
        let bundle = (t != nil) ?  NSBundle(forClass: t!) :  NKStorage.mainBundle
        
        unzipper_ = unzipper_ ?? NKArchiveReader.create()
        
        guard let nkarPath = getPath_(bundle, nkarModule) else { return [String]() }
        
        return  unzipper_!.getDirectory(nkarPath, foldername: resource)
        
    }


    
    private class func getDataNKAR_(module: String, _ t: AnyClass? = nil) -> NSData? {
        
        let moduleArr = module.componentsSeparatedByString(".nkar/")
        
        let nkarModule: String = moduleArr[0] + ".nkar"
        
        var resource: String = moduleArr[1]
        
        let bundle = (t != nil) ?  NSBundle(forClass: t!) :  NKStorage.mainBundle
        
        unzipper_ = unzipper_ ?? NKArchiveReader.create()
        
        let fileExtension = (resource as NSString).pathExtension
        
        if (fileExtension=="") {
            
            resource += ".js"
            
        }
        
        guard let nkarPath = getPath_(bundle, nkarModule),
            
            let data = unzipper_?.dataForFile(nkarPath, filename: resource)
            
            else { return nil }
        
        return data
        
    }
    
    private class func getPath_(mainBundle: NSBundle, _ module: String) -> String? {
     
        if module.hasPrefix("/")
        {
            return module
        }
        
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
        }
        
        if (path == nil) {
            
            for _searchPath in self.searchPaths {
                
                path = ((_searchPath as NSString).stringByAppendingPathComponent(directory) as NSString).stringByAppendingPathComponent(fileName + "." + fileExtension)
                
                if fileManager.fileExistsAtPath(path!)
                { break; }
                
                path = nil
                
            }
        }
        
        if (path == nil) {
            
            path = module
            
            if ((path! as NSString).pathComponents.count < 3) || (!NSFileManager.defaultManager().fileExistsAtPath(path!)) {
                
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
    
    
    // PUBLIC METHODS, ACCESSIBLE FROM JAVASCRIPT
    
    public func getSourceSync(module: String) -> String {
        
        guard let data = NKStorage.getResourceData(module) else { return "" }
        
        return (data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0)))
        
    }
    
    public func existsSync(module: String) -> Bool {
        
        return NKStorage.exists(module)
        
    }
    
    public func statSync(module: String) -> Dictionary<String, AnyObject> {
        
        if module.lowercaseString.rangeOfString(".nkar/") != nil {
            
            return NKStorage.statNKAR_(module)
            
        }
        
        var storageItem  = Dictionary<String, NSObject>()
        var path: String
        
        if module.hasPrefix("/")
        {
            path = module
        } else
        {
            path = (NKStorage.mainBundle.resourcePath! as NSString).stringByAppendingPathComponent(module)
        }
        
        let attr: [String : AnyObject]
        
        do {
            
            attr = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
            
        } catch _ {
            
            return storageItem
            
        }
        
        storageItem["birthtime"] = attr[NSFileCreationDate] as! NSDate
        
        storageItem["size"] = attr[NSFileSize] as! NSNumber
        
        storageItem["mtime"] = attr[NSFileModificationDate] as! NSDate
        
        storageItem["path"] = path as String
        
        switch attr[NSFileType] as! String {
            
        case NSFileTypeDirectory:
            
            storageItem["filetype"] = "Directory"
            
            break
            
        case NSFileTypeRegular:
            
            storageItem["filetype"] = "File"
            
            break
            
        case NSFileTypeSymbolicLink:
            
            storageItem["filetype"] = "SymbolicLink"
            
            break
            
        default:
            
            storageItem["filetype"] = "File"
            
            break
            
        }
        
        return storageItem
    }
    
    public func getDirectorySync(module: String) -> [String] {
        
        if module.lowercaseString.rangeOfString(".nkar/") != nil {
            
            return NKStorage.getDirectoryNKAR_(module)
            
        }
        
        var path: String
        
        if module.hasPrefix("/")
        {
            path = module
        } else
        {
            path = (NKStorage.mainBundle.resourcePath! as NSString).stringByAppendingPathComponent(module)
        }
        
        let dirContents = (try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)) ?? [String]()
        
        return dirContents
        
    }
    
    
    class func attachTo(context: NKScriptContext) {
        
        context.loadPlugin(NKStorage(), namespace: "io.nodekit.scripting.storage", options: [String:AnyObject]())
        
    }
    
    public func rewriteGeneratedStub(stub: String, forKey: String) -> String {
        
        switch (forKey) {
            
        case ".global":
            
            return NKStorage.getPluginWithStub(stub, "lib-scripting.nkar/lib-scripting/native_module.js", NKStorage.self)
            
        default:
            
            return stub
            
        }
    }
    
    public class func isExcludedFromScript(name: String) -> Bool {
        
        return name.hasPrefix("getPluginWithStub") ||
            name.hasPrefix("getResource") ||
            name.hasPrefix("getResourceData") ||
            name.hasPrefix("mainBundle") ||
            name.hasPrefix("includeBundle") ||
            name.hasPrefix("exists")
    }

}

