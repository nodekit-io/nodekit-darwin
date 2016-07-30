/*
 * nodekit.io
 *
 * Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
 * Portions Copyright (c) 2013 GitHub, Inc. under MIT License
 * Portions Copyright (c) 2015 lazyapps. All rights reserved.
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

public struct NKArchiveReader {
    
    var _cacheCDirs: NSCache
    
    var _cacheArchiveData: NSCache

}

public extension NKArchiveReader {
    
    static func create() -> NKArchiveReader {
        
        let cacheArchiveData2 = NSCache()

        cacheArchiveData2.countLimit = 2
        
        return NKArchiveReader( _cacheCDirs: NSCache(), _cacheArchiveData: cacheArchiveData2)
    
    }
    
    mutating func dataForFile(archive: String, filename: String) -> NSData? {
        
        if let nkArchive = _cacheCDirs.objectForKey(archive) as? NKArchive {
            
            if let data = _cacheArchiveData.objectForKey(archive) as? NSData {
                
                print ("READING FROM CACHE")
                
                return nkArchive[filename, withArchiveData: data]
                
            } else
                
            {
                print ("LOADING FROM DISK WITH CACHED DIRECTORY")

                return nkArchive[filename]
            }
            
        } else {
            
               print ("LOADING FROM DISK")
            
            guard let (nkArchive, data) = NKArchive.createFromPath(archive) else { return nil }
            
            _cacheCDirs.setObject(nkArchive, forKey: archive)
            _cacheArchiveData.setObject(data, forKey: archive)
            
            return nkArchive[filename, withArchiveData: data]
        }
    }
    
}


extension NSCache {
  
    subscript(key: AnyObject) -> AnyObject? {
    
        get {
        
            return objectForKey(key)
       
        }
        
        set {
        
            if let value: AnyObject = newValue {
            
                setObject(value, forKey: key)
            
            } else {
            
                removeObjectForKey(key)
            
            }
        
        }
    
    }

}