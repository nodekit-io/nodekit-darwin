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
import Compression

struct NKAR_Uncompressor {
    
    static func uncompressWithArchiveData(cdir: NKAR_CentralDirectory, data: NSData) -> NSData? {
        
            let bytes = unsafeBitCast(data.bytes, UnsafePointer<UInt8>.self)
            let offsetBytes = bytes.advancedBy(Int(cdir.dataOffset))
            return uncompressWithFileBytes(cdir, fromBytes: offsetBytes)
    }

    
    static func uncompressWithFileBytes(cdir: NKAR_CentralDirectory, fromBytes bytes: UnsafePointer<UInt8>) -> NSData? {
        
            let len = Int(cdir.uncompressedSize)
            
            let out = UnsafeMutablePointer<UInt8>.alloc(len)
            
            switch cdir.compressionMethod {
            
            case .None:
            
                out.assignFrom(UnsafeMutablePointer<UInt8>(bytes), count: len)
           
            case .Deflate:
                
                let streamPtr = UnsafeMutablePointer<compression_stream>.alloc(1)
                
                var stream = streamPtr.memory
                
                var status : compression_status
                
                let op : compression_stream_operation = COMPRESSION_STREAM_DECODE
                
                let flags : Int32 = 0
                
                let algorithm : compression_algorithm = Compression.COMPRESSION_ZLIB
                
                status = compression_stream_init(&stream, op, algorithm)
           
                guard status != COMPRESSION_STATUS_ERROR else {
                    // an error occurred
                    return nil
                }
                
                // setup the stream's source
                stream.src_ptr = bytes
                
                stream.src_size = Int(cdir.compressedSize)
                
                stream.dst_ptr = out
                
                stream.dst_size = len
                
                status = compression_stream_process(&stream, flags)
                
                switch status.rawValue {
                
                case COMPRESSION_STATUS_END.rawValue:
                    // OK
                    break
                    
                case COMPRESSION_STATUS_OK.rawValue:
                
                    print("Unexpected end of stream when uncompressing nkar")
                    
                    return nil
                    
                case COMPRESSION_STATUS_ERROR.rawValue:
                    
                    print("Unexpected error in stream when uncompressing nkar")
                    
                    return nil
                    
                default:
                    
                    break
                }
                
                compression_stream_destroy(&stream)
            }
            
            return NSData(bytesNoCopy: out, length: len, freeWhenDone: true)
            
     
    }
    
    
    static func uncompressWithCentralDirectory(cdir: NKAR_CentralDirectory, fromBytes bytes: UnsafePointer<UInt8>) -> NSData? {
        
            let offsetBytes = bytes.advancedBy(Int(cdir.dataOffset))
            
            let offsetMBytes = UnsafeMutablePointer<UInt8>(offsetBytes)
            
            let len = Int(cdir.uncompressedSize)
            
            let out = UnsafeMutablePointer<UInt8>.alloc(len)
            
            switch cdir.compressionMethod {
                
            case .None:
                
                out.assignFrom(offsetMBytes, count: len)
                
            case .Deflate:
                
                let streamPtr = UnsafeMutablePointer<compression_stream>.alloc(1)
                
                var stream = streamPtr.memory
                
                var status : compression_status
                
                let op : compression_stream_operation = COMPRESSION_STREAM_DECODE
                
                let flags : Int32 = 0
                
                let algorithm : compression_algorithm = Compression.COMPRESSION_ZLIB
                
                status = compression_stream_init(&stream, op, algorithm)
                
                guard status != COMPRESSION_STATUS_ERROR else {
                    // an error occurred
                    return nil
                }
                
                // setup the stream's source
                stream.src_ptr = UnsafePointer<UInt8>(offsetMBytes)
                
                stream.src_size = Int(cdir.compressedSize)
                
                stream.dst_ptr = out
                
                stream.dst_size = len
                
                status = compression_stream_process(&stream, flags)
                
                switch status.rawValue {
                    
                case COMPRESSION_STATUS_END.rawValue:
                    // OK
                    break
                    
                case COMPRESSION_STATUS_OK.rawValue:
                    
                    print("Unexpected end of stream")
                    
                    return nil
                    
                case COMPRESSION_STATUS_ERROR.rawValue:
                    
                    print("Unexpected error in stream")
                    
                    return nil
                    
                default:
                    
                    break
                }
                
                compression_stream_destroy(&stream)
            }
            
            return NSData(bytesNoCopy: out, length: len, freeWhenDone: true)
            
    }

}