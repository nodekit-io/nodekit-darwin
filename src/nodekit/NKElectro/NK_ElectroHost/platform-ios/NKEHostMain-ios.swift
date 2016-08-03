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

#if os(iOS)
    
import UIKit

public class NKEHostMain {

    public class func start (options: Dictionary<String, AnyObject>, delegate: NKScriptContextDelegate?) {
        
        NKEAppDelegate.options = options;
    
        NKEAppDelegate.delegate = delegate;

        UIApplicationMain(Process.argc, Process.unsafeArgv, NSStringFromClass(UIApplication),
                          
            NSStringFromClass(NKEAppDelegate))

        }
    
}

#endif