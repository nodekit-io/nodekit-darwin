var app = require('electro').app;

app.on('ready', function(){
       console.log('STARTING TEST APPLICATION');
       io.nodekit.test.runner.ready();
    })

var path = require('path');
var JasmineRunner = require('./lib/jasmineRunner.js');
var fs = require('fs');
var util = require('util');

var parentScriptRoot = path.dirname(module.filename);
var jasmineRoot = path.join(__dirname, 'node_modules', 'jasmine-core', 'lib');

io.nodekit.test.execute = function(id, options, nativeReporter){
    var clientRoot = options.root || parentScriptRoot;
    console.log('STARTING TEST RUN');
    var jasmineRunner = new JasmineRunner(nativeReporter);
    jasmineRunner.loadConfig(options);
    jasmineRunner.configureJUnitXMLReporter({});
    jasmineRunner.configureConsoleReporter({});
    jasmineRunner.configureCallBackReporter({onComplete: io.nodekit.test.runner.complete
                                           });
    jasmineRunner.execute();
}

