/*
* nodekit.io
*
* Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
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

class NKC_FileSystem: NSObject {
    
    private let _NKStorage = NKStorage()

     func statSync(module: String) -> Dictionary<String, AnyObject> {
        
        return _NKStorage.statSync(module)
        
    }

    func statAsync(module: String, completionHandler: NKScriptValue) -> Void {
        
        let ret = self.statSync(module)
        
        if (ret.count > 0) {
        
            completionHandler.callWithArguments([NSNull(), ret], completionHandler: nil)
       
        } else {
        
            completionHandler.callWithArguments(["stat error"], completionHandler: nil)
        
        }
    
    }

    func existsSync (path: String) -> Bool {
        
        return NKStorage.exists(path)
        
    }

    func getDirectoryAsync(module: String, completionHandler: NKScriptValue) -> Void {
    
        completionHandler.callWithArguments([NSNull(), self.getDirectorySync(module)], completionHandler: nil)
    
    }

    func getDirectorySync(module: String) -> [String] {
        
        return _NKStorage.getDirectorySync(module)
    
    }

    func getTempDirectorySync() -> String? {
    
        let fileURL: NSURL = NSURL.fileURLWithPath(NSTemporaryDirectory())
        
        return fileURL.path
    
    }


    func getContentAsync(storageItem: Dictionary<String, AnyObject>, completionHandler: NKScriptValue) -> Void {
    
        completionHandler.callWithArguments([NSNull(), self.getContentSync(storageItem)], completionHandler: nil)
    
    }

    func getContentSync(storageItem: Dictionary<String, AnyObject>) -> String {
    
        guard let path = storageItem["path"] as? String else {return ""}
        
        return _NKStorage.getSourceSync(path) ?? ""
        
    }

    func writeContentSync(storageItem: Dictionary<String, AnyObject>, str: String) -> Bool {
    
        guard let path = storageItem["path"] as? String else {return false}
        
        let data = NSData(base64EncodedString: str, options: NSDataBase64DecodingOptions(rawValue:0))
        
        return data!.writeToFile(path, atomically: false)
    
    }

    func writeContentAsync(storageItem: Dictionary<String, AnyObject>, str: String, completionHandler: NKScriptValue) {
    
        completionHandler.callWithArguments([ NSNull(),  self.writeContentSync(storageItem, str: str)], completionHandler: nil)
    
    }

    func mkdirSync (path: String) -> Bool {

        do {

            try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
           
            return true
        
        } catch _ {
        
            return false
        }

    }

    func rmdirSync (path: String) -> Bool {

        do {

            try NSFileManager.defaultManager().removeItemAtPath(path)
            
            return true
       
        } catch _ {
        
            return false
        
        }

    }

    func moveSync (path: String, path2: String) -> Bool {

        do {

            try NSFileManager.defaultManager().moveItemAtPath(path, toPath: path2)
            
            return true
        
        } catch _ {
        
            return false
        
        }
    
    }

    func unlinkSync (path: String) -> Bool {

         do {
    
            try NSFileManager.defaultManager().removeItemAtPath(path)
            
            return true
        
         } catch _ {
         
            return false
       
        }

    }
}

extension NKC_FileSystem: NKScriptExport {
    
    class func attachTo(context: NKScriptContext) {
        
        context.loadPlugin(NKC_FileSystem(), namespace: "io.nodekit.platform.fs", options: [String:AnyObject]())
        
    }
    
    func rewriteGeneratedStub(stub: String, forKey: String) -> String {
        
        switch (forKey) {
            
        case ".global":
            
            return NKStorage.getPluginWithStub(stub, "lib-core.nkar/lib-core/platform/fs.js", NKC_FileSystem.self)
            
        default:
            
            return stub
            
        }
        
    }
}
