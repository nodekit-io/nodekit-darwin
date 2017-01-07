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
import JavaScriptCore

extension NKScriptContextFactory {
    
    func createContextJavaScriptCore(options: [String: AnyObject] = Dictionary<String, AnyObject>(), delegate cb: NKScriptContextDelegate) {
        
        NKScriptContextFactory.defaultQueue = dispatch_get_main_queue()
        
        dispatch_async(NKScriptContextFactory.defaultQueue) {
            
            let vm = JSVirtualMachine()
            
            let context = JSContext(virtualMachine: vm)
            
            let id = NKScriptContextFactory.sequenceNumber
            
            context.NKcreateScriptContext(id, options: options, delegate: cb)
            
            var item = Dictionary<String, AnyObject>()
            
            NKScriptContextFactory._contexts[id] = item
            
            item["JSVirtualMachine"] = vm
            
            item["context"] = context
        }
    }
}

extension JSContext: NKScriptContextHost {
    
    public func NKcreateScriptContext(id: Int, options: [String: AnyObject] = Dictionary<String, AnyObject>(), delegate cb: NKScriptContextDelegate) -> Void {
        
        let context = NKJSContext(self, id: id)
        
        NKLogging.log("+NodeKit JavaScriptCore JavaScript Engine E\(id)")
        
        objc_setAssociatedObject(context, unsafeAddressOf(NKJSContextId), id, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        
        context.prepareEnvironment()
        
        cb.NKScriptEngineDidLoad(context)
        
        cb.NKScriptEngineReady(context)
        
    }
    
}
