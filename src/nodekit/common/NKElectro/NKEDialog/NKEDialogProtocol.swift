/*
* nodekit.io
*
* Copyright (c) -> Void -> Void 2016 OffGrid Networks. All Rights Reserved.
* Portions Copyright (c) -> Void 2013 GitHub, Inc. under MIT License
*
* Licensed under the Apache License, Version 2.0 (the "License") -> Void;
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
import WebKit
import JavaScriptCore

protocol NKE_DialogProtocol: NKScriptExport {

    func showOpenDialog(browserWindow: NKE_BrowserWindow?, options: Dictionary<String, AnyObject>?, callback: NKScriptValue?) -> Void
    func showSaveDialog(browserWindow: NKE_BrowserWindow?, options: Dictionary<String, AnyObject>?, callback: NKScriptValue?)-> Void
    func showMessageBox(browserWindow: NKE_BrowserWindow?, options: Dictionary<String, AnyObject>?, callback: NKScriptValue?) -> Void
    func showErrorBox(title: String, content: String) -> Void
}
