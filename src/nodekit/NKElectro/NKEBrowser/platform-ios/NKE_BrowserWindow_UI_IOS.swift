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

#if os(iOS)
    
import Foundation

import WebKit

import UIKit

extension NKE_BrowserWindow {
  

    internal func UIScriptEnvironmentReady() -> Void {

        (self._webView as! UIWebView).delegate = self
        self._events.emit("did-finish-load", self._id)
        
        
        (self._webView as! UIWebView).hidden = false
    
    }

    internal func createUIWebView(options: Dictionary<String, AnyObject>) -> Int {
        
        hookKeyboard()
        
         let id = NKScriptContextFactory.sequenceNumber

        let createBlock = {() -> Void in

            let window = self.createWindow(options) as! UIWindow
            
            window.backgroundColor =  UIColor.init(netHex: 0x2A91F6)
    
            self._window = window

            let urlAddress: String = (options[NKEBrowserOptions.kPreloadURL] as? String) ?? "https://google.com"

            // create WebView
            
            let webView: UIWebView = UIWebView(frame: CGRect.zero)
            
            webView.contentMode = UIViewContentMode.Redraw
            
            webView.scalesPageToFit = false
            
            webView.scrollView.scrollEnabled = true
            
            self._webView = webView

            window.rootViewController?.view = webView
            
            NSURLProtocol.registerClass(NKE_ProtocolLocalFile)
     
            NSURLProtocol.registerClass(NKE_ProtocolCustom)

            webView.NKcreateScriptContext(id, options: [String: AnyObject](), delegate: self)

            let url = NSURL(string: urlAddress as String)

            let requestObj: NSURLRequest = NSURLRequest(URL: url!)

            
            webView.loadRequest(requestObj)
            
            window.rootViewController?.view.backgroundColor = UIColor(netHex: 0x2690F6)
            
            self._recognizer = UITapGestureRecognizer(target: self, action:#selector(self.dismissTheView))
            
            window.addGestureRecognizer((self._recognizer as! UITapGestureRecognizer))
            
            webView.hidden = true
        
        }
        
   

        if (NSThread.isMainThread()) {
        
            createBlock()
       
        } else {
        
            dispatch_async(dispatch_get_main_queue(), createBlock)
        
        }

        return id
    
    }
    
    func dismissTheView(sender:UITapGestureRecognizer) {
        
        (self._webView as! UIWebView).endEditing( true);
    }

}

extension NKE_BrowserWindow: UIWebViewDelegate {

    func webViewDidFinishLoad(webView: UIWebView) {

        self._events.emit("did-finish-load", self._id)
    
    }

    func webView(webView: UIWebView,
        didFailLoadWithError error: NSError) {
    
        self._events.emit("did-fail-loading", (self._id,  error.description ?? ""))
    
    }

}

#endif
