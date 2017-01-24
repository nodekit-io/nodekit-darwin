/*
* nodekit.io
*
* Copyright (c) 2016-7 OffGrid Networks. All Rights Reserved.
* Portions Copyright (c) 2013 GitHub, Inc. under MIT License
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

import UIKit
import WebKit

    extension NKE_BrowserWindow {
        
        internal func createWindow(options: Dictionary<String, AnyObject>) -> AnyObject {
            let window = UIApplication.sharedApplication().delegate!.window!
            
            return window!
            
        }
        
    }
    
    extension NKE_BrowserWindow {
        
        internal func hookKeyboard() {
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIKeyboardWillChangeFrameNotification, object: nil)
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDeviceOrientationDidChangeNotification, object: nil)
            
        }
        
        
        internal func unhookKeyboard() {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        }
        
        func keyboardWillChangeFrame(notification: NSNotification) {
            self.shrinkViewKeyboardWillChangeFrame(notification)
        }
        
        func deviceOrientationDidChange(notification: NSNotification) {
            
            if self._keyboardIsVisible {
                return;
            }
            
            let webView = self._webView as! UIView
            
            let viewController = (self._window as! UIWindow).rootViewController!
            
            var screen = webView.frame.origin.y > 0 ? viewController.view.convertRect(UIScreen.mainScreen().applicationFrame, fromView: nil) : viewController.view.convertRect(UIScreen.mainScreen().bounds, fromView: nil)
            
            webView.frame = screen
            
        }
        
        
        func shrinkViewKeyboardWillChangeFrame(notification: NSNotification) {
            // No-op on iOS7.0.  It already resizes webview by default, and this plugin is causing layout issues
            // with fixed position elements.
            // iOS 7.1+ behave the same way as iOS 6
            if NSFoundationVersionNumber == NSFoundationVersionNumber_iOS_7_0 {
                return
            }
            
            let webView = (self._webView as! UIView)
            
            let scrollView: UIScrollView
            
            switch self._browserType {
                
            case .WKWebView:
                
                scrollView = (self._webView as! WKWebView).scrollView
                
            case .UIWebView:
                
                scrollView = (self._webView as! UIWebView).scrollView
            }
            
            
            let viewController = (self._window as! UIWindow).rootViewController!
            
            var screen = webView.frame.origin.y > 0 ? viewController.view.convertRect(UIScreen.mainScreen().applicationFrame, fromView: nil) : viewController.view.convertRect(UIScreen.mainScreen().bounds, fromView: nil)
            
            var keyboard = viewController.view.convertRect((notification.userInfo!["UIKeyboardFrameEndUserInfoKey"] as! NSValue).CGRectValue(), fromView: nil)
            
            var keyboardIntersection = CGRectIntersection(screen, keyboard)
            
            let keyboardisVisible = CGRectContainsRect(screen, keyboardIntersection) && !CGRectIsEmpty(keyboardIntersection)
            
            if keyboardisVisible {
                
                screen.size.height -= min(keyboardIntersection.size.height, keyboardIntersection.size.width)
                
                screen.size.height +=  self._accessoryBarHeight
                
                scrollView.scrollEnabled = false
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0 * (Double)(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    var newFrame : CGRect = scrollView.frame;
                    newFrame.size.height += self._accessoryBarHeight
                    scrollView.frame = newFrame;
                    
                }
                
            }
            
            webView.frame = screen
            
            scrollView.scrollEnabled = true
            
            self._keyboardIsVisible = keyboardisVisible
            
            
        }
        
        func keyboardWillShow(notification:NSNotification) -> Void {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0 * (Double)(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.removeAccessoryBar(notification)
            }
            
        }
        
        func keyboardWillHide(notification:NSNotification) -> Void {
            self._keyboardIsVisible = false
        }
        
        
        func removeAccessoryBar(notification:NSNotification) -> Void {
            
            let webView = self._webView as! UIView
            
            let FIRSTLEVELIDENTIFIER : String
            
            if #available(iOS 8.0, *) {
                FIRSTLEVELIDENTIFIER = "UIInputSetContainerView"
            } else{
                FIRSTLEVELIDENTIFIER = "UIPeripheralHostView"
            }
            
            let THIRDLEVELIDENTIFIER : String
            
            
            switch self._browserType {
                
            case .WKWebView:
                
                THIRDLEVELIDENTIFIER = "WKContentView"
                
            case .UIWebView:
                
                THIRDLEVELIDENTIFIER = "UIKBInputBackdropView"
            }
            
            
            for window in UIApplication.sharedApplication().windows {
                if !window.isMemberOfClass(UIWindow.self) {
                    let keyboardWindow = window
                    
                    for possibleFormView:UIView in keyboardWindow.subviews {
                        
                        if possibleFormView.isMemberOfClass(NSClassFromString(FIRSTLEVELIDENTIFIER)!) {
                            
                            for subviewOfInputSetContainerView in possibleFormView.subviews {
                                
                                if subviewOfInputSetContainerView.isMemberOfClass(NSClassFromString("UIInputSetHostView")!) {
                                    
                                    for subviewOfInputSetHostView in subviewOfInputSetContainerView.subviews {
                                        
                                        // hides the accessory bar
                                        if subviewOfInputSetHostView.isMemberOfClass(NSClassFromString("UIWebFormAccessory")!) {
                                            
                                            _accessoryBarHeight = subviewOfInputSetHostView.frame.size.height;
                                            
                                            if #available(iOS 8.0, *) {
                                                subviewOfInputSetHostView.layer.opacity = 0
                                                subviewOfInputSetHostView.frame = CGRectZero
                                                
                                            } else
                                            {
                                                subviewOfInputSetHostView.removeFromSuperview()
                                            }
                                            
                                        }
                                        
                                        // hides the backdrop (iOS 7)
                                        if subviewOfInputSetHostView.isMemberOfClass(NSClassFromString(THIRDLEVELIDENTIFIER)!) && subviewOfInputSetHostView.frame.size.height < 100  {
                                            
                                            // check that this backdrop is for the accessory bar (at the top),
                                            // sparing the backdrop behind the main keyboard
                                            
                                            let rect : CGRect = subviewOfInputSetHostView.frame;
                                            if (rect.origin.y == 0) {
                                                subviewOfInputSetHostView.layer.opacity = 0
                                                subviewOfInputSetHostView.userInteractionEnabled = false
                                            }
                                        }
                                        
                                        
                                        // hides the thin grey line used to adorn the bar (iOS 6)
                                        if subviewOfInputSetHostView.isMemberOfClass(NSClassFromString("UIImageView")!)
                                        {
                                            subviewOfInputSetHostView.layer.opacity = 0
                                        }
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    
    extension NKE_BrowserWindow: NKE_BrowserWindowProtocol {
        
        func destroy() -> Void { NotImplemented(); }
        
        func close() -> Void {NotImplemented()
            
            self._window = nil
            
            NKE_BrowserWindow._windowArray[self._id] = nil
            
            _context = nil
            
            _webView = nil
            
        }
        
        func focus() -> Void { NotImplemented(); }
        
        func isFocused() -> Bool { NotImplemented(); return false; }
        
        func show() -> Void { NotImplemented(); }
        
        func showInactive() -> Void { NotImplemented(); }
        
        func hide() -> Void { NotImplemented(); }
        
        func isVisible() -> Bool { NotImplemented(); return true; }
        
        func maximize() -> Void { NotImplemented(); }
        
        func unmaximize() -> Void { NotImplemented(); }
        
        func isMaximized() -> Bool { NotImplemented(); return false; }
        
        func minimize() -> Void { NotImplemented(); }
        
        func isMinimized() -> Bool { NotImplemented(); return false; }
        
        func setFullScreen(flag: Bool) -> Void { NotImplemented(); }
        
        func isFullScreen() -> Bool { NotImplemented(); return false; }
        
        func setAspectRatio(aspectRatio: NSNumber, extraSize: [Int]) -> Void { NotImplemented(); } //OS X
        
        func setBounds(options: [NSObject : AnyObject]!) -> Void { NotImplemented(); }
        
        func getBounds() -> [NSObject : AnyObject]! { NotImplemented(); return [NSObject : AnyObject](); }
        
        func setSize(width: Int, height: Int) -> Void { NotImplemented(); }
        
        func getSize() -> [NSObject : AnyObject]! { NotImplemented(); return [NSObject : AnyObject](); }
        
        func setContentSize(width: Int, height: Int) -> Void { NotImplemented(); }
        
        func getContentSize() -> [Int] { NotImplemented(); return [Int](); }
        
        func setMinimumSize(width: Int, height: Int) -> Void { NotImplemented(); }
        
        func getMinimumSize() -> [Int] { NotImplemented(); return [Int](); }
        
        func setMaximumSize(width: Int, height: Int) -> Void { NotImplemented(); }
        
        func getMaximumSize() -> [Int] { NotImplemented(); return [Int](); }
        
        func setResizable(resizable: Bool) -> Void { NotImplemented(); }
        
        func isResizable() -> Bool { NotImplemented(); return false; }
        
        func setAlwaysOnTop(flag: Bool) -> Void { NotImplemented(); }
        
        func isAlwaysOnTop() -> Bool { NotImplemented(); return false; }
        
        func center() -> Void { NotImplemented(); }
        
        func setPosition(x: Int, y: Int) -> Void { NotImplemented(); }
        
        func getPosition() -> [Int] { NotImplemented(); return [Int]() }
        
        func setTitle(title: String) -> Void { NotImplemented(); }
        
        func getTitle() -> Void { NotImplemented(); }
        
        func flashFrame(flag: Bool) -> Void { NotImplemented(); }
        
        func setSkipTaskbar(skip: Bool) -> Void { NotImplemented(); }
        
        func setKiosk(flag: Bool) -> Void { NotImplemented(); }
        
        func isKiosk() -> Bool { NotImplemented(); return false; }
        
        // func hookWindowMessage(message: Int,callback: AnyObject) -> Void //WINDOWS
        
        // func isWindowMessageHooked(message: Int) -> Void //WINDOWS
        
        // func unhookWindowMessage(message: Int) -> Void //WINDOWS
        
        // func unhookAllWindowMessages() -> Void //WINDOWS
        
        func setRepresentedFilename(filename: String) -> Void { NotImplemented(); } //OS X
        
        func getRepresentedFilename() -> String { NotImplemented(); return "" } //OS X
        
        func setDocumentEdited(edited: Bool) -> Void { NotImplemented(); } //OS X
        
        func isDocumentEdited() -> Bool { NotImplemented(); return false; } //OS X
        
        
        func focusOnWebView() -> Void { NotImplemented(); }
        
        func blurWebView() -> Void { NotImplemented(); }
        
        func capturePage(rect: [NSObject : AnyObject]!, callback: AnyObject) -> Void { NotImplemented(); }
        
        func print(options: [NSObject : AnyObject]) -> Void { NotImplemented(); }
        
        func printToPDF(options: [NSObject : AnyObject], callback: AnyObject) -> Void { NotImplemented(); }
        
        func loadURL(url: String, options: [NSObject : AnyObject]) -> Void { NotImplemented(); }
        
        func reload() -> Void { NotImplemented(); }
        
        // func setMenu(menu) -> Void //LINUX WINDOWS
        
        func setProgressBar(progress: Double) -> Void { NotImplemented(); }
        
        // func setOverlayIcon(overlay, description) -> Void //WINDOWS 7+
        
        // func setThumbarButtons(buttons) -> Void //WINDOWS 7+
        
        func showDefinitionForSelection() -> Void { NotImplemented(); } //OS X
        
        func setAutoHideMenuBar(hide: Bool) -> Void { NotImplemented(); }
        
        func isMenuBarAutoHide() -> Bool { NotImplemented(); return false;  }
        
        func setMenuBarVisibility(visible: Bool) -> Void { NotImplemented(); }
        
        func isMenuBarVisible() -> Bool { NotImplemented(); return false; }
        
        func setVisibleOnAllWorkspaces(visible: Bool) -> Void { NotImplemented(); }
        
        func isVisibleOnAllWorkspaces() -> Bool { NotImplemented(); return false; }
        
        func setIgnoreMouseEvents(ignore: Bool) -> Void { NotImplemented(); } //OS X
        
        private static func NotImplemented() -> Void {
            
            NSException(name: "NotImplemented", reason: "This function is not implemented", userInfo: nil).raise()
            
        }
        
        private func NotImplemented() -> Void {
            
            NSException(name: "NotImplemented", reason: "This function is not implemented", userInfo: nil).raise()
            
        }
        
    }
    
    public extension UIColor {
        
        convenience public init(red: Int, green: Int, blue: Int) {
            
            assert(red >= 0 && red <= 255, "Invalid red component")
            
            assert(green >= 0 && green <= 255, "Invalid green component")
            
            assert(blue >= 0 && blue <= 255, "Invalid blue component")
            
            self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
            
        }
        
        convenience public init(netHex: Int) {
            
            self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
            
        }
        
    }
    
#endif
