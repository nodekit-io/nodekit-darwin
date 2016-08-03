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
import Darwin

/*
 central file header signature   4 bytes  (0x02014b50)
 version made by                 2 bytes
 version needed to extract       2 bytes
 general purpose bit flag        2 bytes
 compression method              2 bytes
 last mod file time              2 bytes
 last mod file date              2 bytes
 crc-32                          4 bytes
 compressed size                 4 bytes
 uncompressed size               4 bytes
 file name length                2 bytes
 extra field length              2 bytes
 file comment length             2 bytes
 disk number start               2 bytes
 internal file attributes        2 bytes
 external file attributes        4 bytes
 relative offset of local header 4 bytes
 
 file name (variable size)
 extra field (variable size)
 file comment (variable size)
 */

enum NKAR_CompressionMethod {
    case None
    case Deflate
    
    init?(_ i: UInt16) {
        if i == 0 {
            self = .None
        } else if i == 8 {
            self = .Deflate
        } else {
            return nil
        }
    }
    
}

struct NKAR_CentralDirectory {
    
    let bytes: UnsafePointer<UInt8>
    
    let compressionMethod: NKAR_CompressionMethod
    
    let lastmodTime: UInt16
    
    let lastmodDate: UInt16
    
    let compressedSize: UInt32
    
    let uncompressedSize: UInt32
    
    let fileName: String
    
    let localFileHeaderOffset: UInt32
    
}

extension NKAR_CentralDirectory {
    
    /*
     ZIP FILE FORMAT: CENTRAL DIRECTORY RECORD, INCLUDED WITHIN END RECORD
     local file header signature     4 bytes  (0x04034b50)
     version needed to extract       2 bytes
     general purpose bit flag        2 bytes
     compression method              2 bytes
     last mod file time              2 bytes
     last mod file date              2 bytes
     crc-32                          4 bytes
     compressed size                 4 bytes
     uncompressed size               4 bytes
     file name length                2 bytes
     extra field length              2 bytes
     */
    
    var dataOffset: Int {
        
        var reader = NKAR_BytesReader(bytes: bytes, index: Int(localFileHeaderOffset))
        
        reader.skip(4 + 2 * 5 + 4 * 3)
        
        let fnLen = reader.le16()
        
        let efLen = reader.le16()
        
        reader.skip(Int(fnLen + efLen))
        
        return reader.index
    }
    
    var lastmodUnixTimestamp: Int {
        
        var time = tm()
      
        time.tm_year = Int32((lastmodDate >> 9 & 0x7f) + 1980 - 1900)
        
        time.tm_mon = Int32((lastmodDate >> 5 & 0x0f) - 1 - 1)
        
        time.tm_mday = Int32(lastmodDate & 0x1f)
        
        time.tm_hour = Int32(lastmodTime >> 11 & 0x1f)
        
        time.tm_min = Int32(lastmodTime >> 5 & 0x3f)
        
        time.tm_sec = Int32((lastmodTime & 0x1f) << 1)
        
        let timestamp = mktime(&time)
        
        return timestamp
        
    }
    
}

extension NKAR_CentralDirectory {
    
    static let signature: UInt32 = 0x02014b50
    
    static func findCentralDirectoriesInBytes(bytes: UnsafePointer<UInt8>, length: Int, withEndRecord er: NKAR_EndRecord) -> [String: NKAR_CentralDirectory]? {
        
        var reader = NKAR_BytesReader(bytes: bytes, index: Int(er.centralDirectoryOffset))
        
        var dirs = [String: NKAR_CentralDirectory]()
        
        for _ in 0..<er.numEntries {
            
            let sign = reader.le32()
            
            if sign != signature { return dirs }
        
            reader.skip(2 + 2 + 2)
            
            let cMethodNum = reader.le16()
            
            let lmTime = reader.le16()
            
            let lmDate = reader.le16()
            
            reader.skip(4)
            
            let cSize = reader.le32()
        
            let ucSize = reader.le32()
            
            let fnLen = reader.le16()
            
            let efLen = reader.le16()
            
            let fcLen = reader.le16()
            
            reader.skip(2 + 2 + 4)
            
            let offset = reader.le32()
            
            if let fn = reader.string(Int(fnLen)),
            
                let cMethod = NKAR_CompressionMethod(cMethodNum) {
                
                dirs[fn] = NKAR_CentralDirectory(bytes: bytes, compressionMethod: cMethod, lastmodTime: lmTime, lastmodDate: lmDate, compressedSize: cSize, uncompressedSize: ucSize, fileName: fn, localFileHeaderOffset: offset)
            }
            
            reader.skip(Int(efLen + fcLen))
        }
        
        return dirs.count > 0 ? dirs : nil
    }
    
}