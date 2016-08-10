/*
* nodekit.io
*
* Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
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
    
import Foundation

import WebKit

import Cocoa

extension NKE_BrowserWindow {

    internal func WKScriptEnvironmentReady() -> Void {

        (self._webView as! WKWebView).navigationDelegate = self
        
        self._events.emit("did-finish-load", self._id)
    
    }

    internal func createWKWebView(options: Dictionary<String, AnyObject>) -> Int {

        let id = NKScriptContextFactory.sequenceNumber

        let createBlock = {() -> Void in
            
            let window = self.createWindow(options)
    
            self._window = window

            let urlAddress: String = (options[NKEBrowserOptions.kPreloadURL] as? String) ?? "about:blank"

            let width: CGFloat = CGFloat((options[NKEBrowserOptions.kWidth] as? Int) ?? 1024)
            
            let height: CGFloat = CGFloat((options[NKEBrowserOptions.kHeight] as? Int) ?? 800)
            
            let viewRect: NSRect = NSMakeRect(0,0, width, height)

            let config = WKWebViewConfiguration()
            
            let webPrefs = WKPreferences()

            webPrefs.javaEnabled = false
            
            webPrefs.plugInsEnabled = false
            
            webPrefs.javaScriptEnabled = true
            
            webPrefs.javaScriptCanOpenWindowsAutomatically = false
            
            config.preferences = webPrefs

            let webView = WKWebView(frame: viewRect, configuration: config)
            
            self._webView = webView

            webView.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
            
            let isTaskBarPopup = (options[NKEBrowserOptions.kTaskBarPopup] as? Bool) ?? false ;
       
            if isTaskBarPopup {
                
                (window as! NSPopover).contentViewController!.view = webView
                
                (window as! NSPopover).contentViewController!.preferredContentSize = CGSize(width: width, height: height)
                
            } else
            {
                
                (window as! NSWindow).contentView = webView
                
            }
            
            webView.NKcreateScriptContext(id, options: [String: AnyObject](), delegate: self)

            // PROTOCOL NOT SUPPORTED ON WKWEBVIEW
            
            //  NSURLProtocol.registerClass(NKUrlProtocolLocalFile)
            
            //  NSURLProtocol.registerClass(NKUrlProtocolCustom)

            let url = NSURL(string: urlAddress)
            
            let requestObj: NSURLRequest = NSURLRequest(URL: url!)

            webView.loadRequest(requestObj)
       
        }
        
        if (NSThread.isMainThread()) {
        
            createBlock()
        
        } else {
        
            dispatch_async(dispatch_get_main_queue(), createBlock)
       
        }

        return id
    
    }

}

extension NKE_BrowserWindow: WKNavigationDelegate {

    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {

        self._events.emit("did-finish-load", self._id)
    
    }

    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
    
        self._events.emit("did-fail-loading", (self._id, error.description))
    
    }

    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
    
        self._events.emit("did-fail-loading", (self._id, error.description))
    
    }

}

#endif
