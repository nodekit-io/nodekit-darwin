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


struct NKAR_EndRecord {
    
    let numEntries: UInt16
    
    let centralDirectoryOffset: UInt32
    
}

extension NKAR_EndRecord {
    
    /*
     ZIP FILE FORMAT:  CENTRAL DIRECTORY AT END OF THE FILE
     end of central dir signature    4 bytes  (0x06054b50)
     number of this disk             2 bytes
     number of the disk with the
     start of the central directory  2 bytes
     total number of entries in the
     central directory on this disk  2 bytes
     total number of entries in
     the central directory           2 bytes
     size of the central directory   4 bytes
     offset of start of central
     directory with respect to
     the starting disk number        4 bytes
     .ZIP file comment length        2 bytes
     .ZIP file comment       (variable size)
     */
    
    static let signature: [UInt8] = [0x06, 0x05, 0x4b, 0x50]
    
    static func findEndRecordInBytes(bytes: UnsafePointer<UInt8>, length: Int) -> NKAR_EndRecord? {
        
        var reader = NKAR_BytesReader(bytes: bytes, index: length - 1 - signature.count)
        
        let maxTry = Int(UInt16.max)
        
        let minReadTo = max(length-maxTry, 0)
        
        let rng = 0..<4
        
        let indexFound: Bool = {
            
            while reader.index > minReadTo {
                
                for i in rng {
                    
                    if reader.byteb() != self.signature[i] { break }
                    
                    if i == rng.endIndex.predecessor() { reader.skip(1); return true }
                }
            }
            
            return false
        }()
        
        if !indexFound { return nil }
      
        reader.skip(4)
        
        let numDisks = reader.le16()
        
        reader.skip(2)
        
        reader.skip(2)
        
        let numEntries = reader.le16()
        
        reader.skip(4)
        
        let centralDirectoryOffset = reader.le32()
        
        if numDisks > 1 { return nil }
        
        return NKAR_EndRecord(numEntries: numEntries, centralDirectoryOffset: centralDirectoryOffset)
    }
    
}