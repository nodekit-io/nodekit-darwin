/*
* nodekit.io
*
* Copyright (c) 2016-7 OffGrid Networks. All Rights Reserved.
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

class NKE_ProtocolFileDecode: NSObject {

    var resourcePath: NSString?   // The path to the bundle resource
  
    var urlPath: NSString  // The relative path from root
    
    var fileName: NSString // The filename, with extension
    
    var fileBase: NSString   // The filename, without the extension
    
    var fileExtension: NSString // The file extension
    
    var mimeType: NSString?    // The mime type
    
    var textEncoding: NSString?   // The text encoding

    init(url: NSURL) {
    
        resourcePath = nil

        var _fileTypes: [NSString: NSString] = [
            "html": "text/html" ,
            "js" : "text/plain" ,
            "css": "text/css",
            "svg": "image/svg+xml"]

        urlPath = (url.path! as NSString).stringByDeletingLastPathComponent
        
        if urlPath.substringToIndex(1) == "/"
        {
            urlPath = urlPath.substringFromIndex(1)
        }
        
        urlPath = ("renderer.nkar" as NSString).stringByAppendingPathComponent(urlPath as String)

        fileExtension = url.pathExtension!.lowercaseString
        
        fileName = url.lastPathComponent!
        
        if (fileExtension.length == 0) {
        
            fileBase = fileName
       
        } else {
        
            fileBase = fileName.substringToIndex(fileName.length - fileExtension.length - 1)
            
        }

        mimeType = nil
        
        textEncoding = nil

        super.init()

        if (fileName.length > 0) {

            resourcePath = urlPath.stringByAppendingPathComponent(fileName as String)

            if (!NKStorage.exists(resourcePath as! String)) { resourcePath = nil }

            if ((resourcePath == nil) && (fileExtension.length > 0)) {
        
                resourcePath = (("app" as NSString).stringByAppendingPathComponent(urlPath as String) as NSString).stringByAppendingPathComponent(fileName as String)
                
                 if (!NKStorage.exists(resourcePath as! String)) { resourcePath = nil }
            
            }
            
            if ((resourcePath == nil) && (fileExtension.length == 0)) {
                
                resourcePath = (("app" as NSString).stringByAppendingPathComponent(urlPath as String) as NSString).stringByAppendingPathComponent((fileBase as String) + ".html")
                
                if (!NKStorage.exists(resourcePath as! String)) { resourcePath = nil }
                
            }
            
            
            if ((resourcePath == nil) && (fileExtension.length == 0)) {
                
                resourcePath = (("app" as NSString).stringByAppendingPathComponent(urlPath as String) as NSString).stringByAppendingPathComponent("index.html")
                
                if (!NKStorage.exists(resourcePath as! String)) { resourcePath = nil }
                
            }
            

            mimeType = _fileTypes[fileExtension]

            if (mimeType != nil) {
            
                if mimeType!.hasPrefix("text") {
                
                    textEncoding = "utf-8"
                
                }
            
            }
        
        }

    }

    func exists() -> Bool {
        
        return (resourcePath != nil)
    
    }

}
