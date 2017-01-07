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

#if os(OSX)
    
    import WebKit
    
    extension WebView: NKScriptContextHost {
        
        public func NKcreateScriptContext(id: Int, options: [String: AnyObject] = Dictionary<String, AnyObject>(),
                                          delegate cb: NKScriptContextDelegate) -> Void {
            
            NKLogging.log("+NodeKit WebView-JavaScriptCore JavaScript Engine E\(id)")
            
            objc_setAssociatedObject(self, unsafeAddressOf(NKJSContextId), id, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            var item = Dictionary<String, AnyObject>()
            
            item["WebView"] = self
            
            NKScriptContextFactory._contexts[id] = item
            
            
            self.frameLoadDelegate =  NKWVWebViewDelegate(id: id, webView: self, delegate: cb)
            
        }
        
    }
    
    extension WebView {
        
        var currentJSContext: JSContext? {
            
            get {
                
                return objc_getAssociatedObject(self, unsafeAddressOf(JSContext)) as? JSContext
                
            }
            
            set(context) {
                
                objc_setAssociatedObject(self, unsafeAddressOf(JSContext), context, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
            }
            
        }
        
    }
    
#endif
