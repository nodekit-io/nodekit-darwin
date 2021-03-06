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

import Cocoa

let app      = NSApplication.sharedApplication()
let delegate = SampleAppDelegate()
app.delegate = delegate
app.setActivationPolicy(.Accessory)
atexit_b { app.setActivationPolicy(.Prohibited); return }


NSUserDefaults.standardUserDefaults().setBool(true, forKey: "WebKitDeveloperExtras")

NSUserDefaults.standardUserDefaults().synchronize()

app.run()