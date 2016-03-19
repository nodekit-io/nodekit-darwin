/*
* nodekit.io
*
* Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
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

// Bindings
// func testComplete(id: Int, pass: Bool, res: Dictionary<String, AnyObject>) -> Void {
// event nk.TestCase {id: Int, spec: String}


var plugin = io.nodekit.test.runner

var options =  {
    'spec_dir': 'spec-node',
    'spec_files': [
                   'assertSpec.js',
                   'consoleSpec.js',
                   'cryptoHashSpec.js',
                   'cryptoRandomSpec.js',
                   'cryptoHmacSpec.js',
                   'cryptoPbkdf2Spec.js',
                   'cryptoSignCommonSpec.js',
                   'dgramSpec.js',
                   'fsSpec.js',
                   'globalSpec.js',
                   'modulesSpec.js',
                   'osSpec.js',
                   'pathSpec.js',
                   'queryStringSpec.js',
                   'streamBigPacketSpec.js',
                   'streamDuplexSpec.js',
                   'streamEndPauseSpec.js',
                   'streamPipeAfterEndSpec.js',
                   'streamPipeCleanupSpec.js',
                   'streamPipeErrorHandlingSpec.js',
                   'streamPipeEventSpec.js',
                   'streamTransformSpec.js',
                   'stringDecoderSpec.js',
                   'urlSpec.js',
                   'utilSpec.js',
                   'zlibSpec.js',
                   
                   'netServerSpec.js' ,
                   'tcpSpec.js',
                   'httpAgentSpec.js',
                   'httpClientSpec.js',
                   'httpSpec.js',
                   
                   /* 'timersSpec.js',  uncomment for time-intensive tests, excluded for performance benchmarks */
                  
                   ],
    'spec_todo': [
                  
                  'netPauseSpec.js',
                  'bufferSpec.js',
                  'childProcessSpec.js',
                  'clusterSpec.js',
                  'cryptoCipherSpec.js',
                  'cryptoDHSpec.js',
                  'cryptoSignSpec.js',
                  'dnsSpec.js',
                  'fsStatSpec.js',
                  'fsStreamSpec.js',
                  'fsWatchSpec.js',
                  'processSpec.js',
                  'tlsSpec.js',
                  'vmSpec.js',
                  
                  ],
    
    'helpers': ['specHelper.js',
                'helpers/*.js'
                ]
}

plugin._init = function(options) {
    var self = this;
    
    this.on('nk.TestStart', function(id) {
            io.nodekit.test.execute(id, options, self);
            });
}

plugin._init(options);
