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

public class NKArchive {
    
    var path: String
    
    var _cdirs: [String: NKAR_CentralDirectory]
    
    init(path: String, _cdirs: [String: NKAR_CentralDirectory]) {
        
        self.path = path
     
        self._cdirs = _cdirs
    
    }
    
    static func createFromPath(path: String) -> (NKArchive, NSData)? {
        
        guard let data = NSFileManager.defaultManager().contentsAtPath(path)
    
            else { return nil }
        
        let bytes = unsafeBitCast(data.bytes, UnsafePointer<UInt8>.self)
        
        let len = data.length
        
        guard let _endrec = NKAR_EndRecord.findEndRecordInBytes(bytes, length: len)
            
            else { return nil }
        
        guard let _cdirs = NKAR_CentralDirectory.findCentralDirectoriesInBytes(bytes, length: len, withEndRecord: _endrec)
            
            else { return nil }
        
        return (NKArchive(path: path, _cdirs: _cdirs), data)

    }
    
}

public extension NKArchive {
    
    func dataForFile(filename: String) -> NSData? {
        
        guard let _cdir = self._cdirs[filename] else { return nil }
        
        guard let file: NSFileHandle = NSFileHandle(forReadingAtPath: self.path) else { return nil }
        
        file.seekToFileOffset(UInt64(_cdir.dataOffset))
        
        let data = file.readDataOfLength(Int(_cdir.compressedSize))
        
        file.closeFile()
        
        let bytes = unsafeBitCast(data.bytes, UnsafePointer<UInt8>.self)
        
        return NKAR_Uncompressor.uncompressWithFileBytes(_cdir, fromBytes: bytes)
        
    }
    
    func dataForFileWithArchiveData(filename: String, data: NSData) -> NSData? {
        
        guard let _cdir = self._cdirs[filename] else { return nil }
        
        return NKAR_Uncompressor.uncompressWithArchiveData(_cdir, data: data)
        
    }
    
    
    var files: [String] {
        
        return Array(self._cdirs.keys)
        
    }
    
    func containsFile(file: String) -> Bool {
        
        return self._cdirs[file] != nil
        
    }
    
}


public extension NKArchive {
    
    subscript(file: String) -> NSData? {
        
        return dataForFile(file)
        
    }
    
    subscript(file: String, withArchiveData data: NSData) -> NSData? {
        
        return dataForFileWithArchiveData(file, data: data)
        
    }
    
}