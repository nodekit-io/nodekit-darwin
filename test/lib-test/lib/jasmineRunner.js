var path = require('path'),
util = require('util'),
glob = require('glob');

module.exports = Jasmine;
module.exports.JsonReporter = require('./jsonReporter');
module.exports.JUnitXmlReporter = require("./junit_reporter").JUnitXmlReporter;
module.exports.ConsoleReporter = require("./terminalReporter").TerminalReporter;
module.exports.CallBackReporter = require("./callbackReporter");

function Jasmine(container, options) {
    
    options = options || {};
    var jasmineCore = require('jasmine-core');
   
    this.jasmine = jasmineCore.boot(jasmineCore);
    this.projectBaseDir = options.projectBaseDir || path.dirname(module.parent.filename);
    this.specFiles = [];
    this.env = this.jasmine.getEnv();
    this.reportersCount = 0;
    this.container = container;
    this.jasmine.DEFAULT_TIMEOUT_INTERVAL = 2000;
}

Jasmine.prototype.addSpecFile = function(filePath) {
    this.specFiles.push(filePath);
};

Jasmine.prototype.addReporter = function(reporter) {
    this.env.addReporter(reporter);
    this.reportersCount++;
};

Jasmine.prototype.configureJSONReporter = function(options) {
    var jsonReporter = new module.exports.JsonReporter(this.container, options);
    this.addReporter(jsonNativeReporter);
};

Jasmine.prototype.configureJUnitXMLReporter = function(options) {
    options.savePath = process.outputDirectory;
    var  reporter = new  module.exports.JUnitXmlReporter(options);
    this.addReporter(reporter);
};

Jasmine.prototype.configureConsoleReporter = function(options) {
    options.verbosity = 3;
    var  reporter = new  module.exports.ConsoleReporter(options);
    this.addReporter(reporter);
};

Jasmine.prototype.configureCallBackReporter = function(options) {
    var  reporter = new  module.exports.CallBackReporter(options);
    this.addReporter(reporter);
};

Jasmine.prototype.addMatchers = function(matchers) {
    this.jasmine.Expectation.addMatchers(matchers);
};

Jasmine.prototype.loadSpecs = function() {
    this.specFiles.forEach(function(file) {
                           
                           // DELETE CACHED VERSION FROM NODE CACHE TO FORCE JASMINE TO (RE)LOAD SPECS
                            var files = require.cache[file];
                           
                           if (typeof files !== 'undefined') {
                           for (var i in files.children) {
                           delete require.cache[files.children[i].id];
                           }
                           delete require.cache[file];
                           }
                           
                           require(file);
                           });
};

Jasmine.prototype.loadConfig = function(config) {
     var specDir = config.spec_dir;
    var jasmineRunner = this;
    jasmineRunner.specDir = config.spec_dir;
    
    if(config.helpers) {
        config.helpers.forEach(function(helperFile) {
                               var filePaths = glob.sync(path.join(jasmineRunner.projectBaseDir, jasmineRunner.specDir, helperFile));
                               filePaths.forEach(function(filePath) {
                                                 if(jasmineRunner.specFiles.indexOf(filePath) === -1) {
                                                 jasmineRunner.specFiles.push(filePath);
                                                 }
                                                 });
                               });
    }
    
    if(config.spec_files) {
         jasmineRunner.addSpecFiles(config.spec_files);
    }
};

Jasmine.prototype.addSpecFiles = function(files) {
    var jasmineRunner = this;
    
    files.forEach(function(specFile) {
                  var filePaths = glob.sync(path.join(jasmineRunner.projectBaseDir, jasmineRunner.specDir, specFile));
                  filePaths.forEach(function(filePath) {
                                    
                                    if(jasmineRunner.specFiles.indexOf(filePath) === -1) {
                                     jasmineRunner.specFiles.push(filePath);
                                    }
                                    });
                  });
};

Jasmine.prototype.execute = function(files) {
    if(this.reportersCount === 0) {
        this.configureDefaultReporter({});
    }
    
    if (files && files.length > 0) {
        this.specDir = '';
        this.specFiles = [];
        this.addSpecFiles(files);
    }
    
    this.loadSpecs();
    this.env.execute();
};
