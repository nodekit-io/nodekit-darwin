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

public class NKStorage {
  
    public static func getResource(module: String, _ t: AnyClass? = nil) -> String? {

        if module.lowercaseString.rangeOfString(".nkar/") != nil {
            return getNKARResource(module, t)
        }

    
        let bundle = (t != nil) ?  NSBundle(forClass: t!) :  NKNodeKit.mainBundle
        
        guard let path = getPath_(bundle, module),
    
            let source = try? NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) else {
            
                return nil
        
        }
        
        return source as String
    
    }
    
    static var unzipper_ : NKArchiveReader? = nil
    
    public static func getNKARResource(module: String, _ t: AnyClass? = nil) -> String? {
        
        let moduleArr = module.componentsSeparatedByString(".nkar/")
        
        let nkarModule: String = moduleArr[0] + ".nkar"
        
        let resource: String = moduleArr[1]
        
        let bundle = (t != nil) ?  NSBundle(forClass: t!) :  NKNodeKit.mainBundle
       
        unzipper_ = unzipper_ ?? NKArchiveReader.create()
        
        guard let nkarPath = getPath_(bundle, nkarModule),
            
         let data = unzipper_?.dataForFile(nkarPath, filename: resource)
            
        else { return nil }
        
        return NSString(data: data, encoding: NSUTF8StringEncoding) as String?
        
    }
    
    public static func getPluginWithStub(stub: String, _ module: String, _ t: AnyClass? = nil) -> String {
        
        guard let appjs = NKStorage.getResource(module, t) else {
    
            die("Failed to read script")
        
        }
       
        return "function loadplugin(){\n" + appjs + "\n}\n" + stub + "\n" + "loadplugin();" + "\n"
    }
    
    private static func getPath_(mainBundle: NSBundle, _ module: String) -> String? {
        
        let directory = (module as NSString).stringByDeletingLastPathComponent
        
        var fileName = (module as NSString).lastPathComponent
        
        var fileExtension = (fileName as NSString).pathExtension
        
        fileName = (fileName as NSString).stringByDeletingPathExtension
        
        if (fileExtension=="") {
        
            fileExtension = "js"
        
        }
        
        var path = mainBundle.pathForResource(fileName, ofType: fileExtension, inDirectory: directory)
        
        if (path == nil) {
            
            let _nodeKitBundle: NSBundle = NSBundle(forClass: NKNodeKit.self)
        
            path = _nodeKitBundle.pathForResource(fileName, ofType: fileExtension, inDirectory: directory)
            
            if (path == nil) {
                
                log("!Error - source file not found: \(directory + "/" + fileName + "." + fileExtension)")
        
                return nil
            
            }
        
        }
        
        return path!
        
    }
    
}