/*
 * nodekit.io
 *
 * Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
 * Portions Copyright (c) Joyent, Inc. and other Node contributors
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

var NativeStorage = io.nodekit.scripting.storage;

this.global = this;
    
if (!process)
{
    throw new Error("This scripting engine is missing the process global variable")
}

process.evalSync = process.evalSync || function(script, filename) {
    try {
        return eval(script);
    } catch (e) {
        if (e instanceof SyntaxError) {
            console.log("Syntax Error in " + ( filename) )
            console.log(e.message);
        } else {
            throw( e );
        }
    }
}

process.moduleLoadList = process.moduleLoadList || [];

process.sources = process.sources || [];

process.bootstrap = function(id) {
    return BootstrapModule.require(id);
};

var BootstrapModule = function BootstrapModule(id) {
   
    var file = id.substring(id.lastIndexOf('/')+1);
 
    if (file.indexOf('.') == -1)
    {
        this.__ext = 'js'
        this.__filename = id + '.js'
    } else
    {
        this.__ext = file.substring(file.lastIndexOf('.') + 1);
        this.__filename = id;
    }
        
    this.__dirname = id.substring(0, id.lastIndexOf('/'));
    
    this.id = id;
    this.exports = {};
    this.loaded = false;
    this.bootstrapper = true;
}

process.bootstrap.NativeModule = BootstrapModule

BootstrapModule.getSource = function(id) {
    
    if (id.indexOf("/") > -1)
    {
        var source = atob(NativeStorage.getSourceSync(id))
        var append = "\r\n //# sourceURL=" + id + "\r\n";
        return source + append;
    }
    
    if (BootstrapModule.preCacheSourceExists(id)) {
        return BootstrapModule.getPreCacheSource(id);
    }
    
    var source = atob(NativeStorage.getSourceSync(id))
    var append = "\r\n //# sourceURL=" + id + "\r\n";
    return source + append;
    
}

BootstrapModule.loadSource = function(id) {
    
    return atob(NativeStorage.getSourceSync(id))
    
}

BootstrapModule._cache = {};

BootstrapModule._symlink = {};

BootstrapModule.ln = function(source, dest) {
    BootstrapModule._symlink[source] = dest;
}

BootstrapModule.prototype.require = function(id)
{
  if (id == 'native_module') {
      return BootstrapModule;
  }
  
  if (BootstrapModule._symlink[id])
  {
      id = BootstrapModule._symlink[id];
  }
  else if (id[0] == ".")
  {
      id = _absolutePath(this.__dirname + '/', id);
  }
  
  var cached;
  
  var isPossibleDirectoryRequire = id.indexOf('index.js') == -1;
  var directoryIndexId = id + '/index.js';
  
  if (isPossibleDirectoryRequire) {
      
      cached = BootstrapModule.getCached(directoryIndexId);
      
      if (cached) {
          return cached.exports
      }
  }
  
  var cached = BootstrapModule.getCached(id);
  if (cached) {
      return cached.exports;
  }
  
  process.moduleLoadList.push('BootstrapModule ' + id);
  
  var bootstrapModule = new BootstrapModule(id);
  
  bootstrapModule.cache();
  
  bootstrapModule.load();
  
  if (Object.keys(bootstrapModule.exports).length == 0 && isPossibleDirectoryRequire) {
      
      return BootstrapModule.require(directoryIndexId)
  }
  
  return bootstrapModule.exports;
};

BootstrapModule.require = BootstrapModule.prototype.require

BootstrapModule.error = function(e, source)
{
    console.log("ERROR OCCURED via " + source);
    console.log("EXCEPTION: " + e);
    
    console.log(JSON.stringify(e));
    var message = "";
    var sourceFile = "unknown";
    
    if (e.sourceURL)
    {
        sourceFile = e.sourceURL.replace("file://","");
    }
    
    message += "<head></head>";
    message += "<body>";
    message += "<h1>Exception</h1>";
    message += "<h2>" + e + "</h2>";
    message += "<p><i>" + e["message"] +"</i> in file " + sourceFile + ": " + e.line;
    
    
    if (e.sourceURL)
    {
        source = global.process.sources[sourceFile];
        if (source)
        {
            message += "<h3>Source</h3>";
            message += "<pre id='preview' style='font-family: monospace; tab-size: 3; -moz-tab-size: 3; -o-tab-size: 3; -webkit-tab-size: 3;'><ol>";
            message += "<li>" + source.split("\n").join("</li><li>") + "</li>";
            message += "</ol></pre>";
        }
    }
    
    if (e.stack)
    {
        message += "<h3>Call Stack</h3>";
        message += "<pre id='preview' style='font-family: monospace;'><ul>";
        message += "<li>" + e.stack.split("\n").join("</li><li>").split("file://").join("") + "</li>";
        message += "</ul></pre>";
    }
    
    message += "</body>";
    console.loadString(message, "Debug");
    console.log("EXCEPTION: " + e);
    console.log("Source: " + sourceFile );
    console.log("Stack: " + e.stack );
};

BootstrapModule.bootstrap = function(id) {
    // process.moduleLoadList.push('BootstrapModule ' + id);
    var source = BootstrapModule.getSource(id);
    var fn = BootstrapModule.runInThisContext(source, { filename: id , displayErrors: true});
    return fn(process);
};

BootstrapModule.getCached = function(id) {
    return BootstrapModule._cache[id];
};


BootstrapModule.loadFromSource = function(id, source) {
    
    var module = new BootstrapModule(id);
    
    var source = BootstrapModule.wrap(source);
    
    var fn = BootstrapModule.runInThisContext(source, { filename: module.__filename , displayErrors: true});
    
    fn(module.exports, module.require.bind(module), module, module.__filename, module.__dirname);
    
    module.loaded = true;
    
    return module.exports;
}

BootstrapModule.runInThisContext = function(code, options) {
    options = options || {};
    
    var filename = options.filename || '<eval>';
    var displayErrors = options.displayErrors || false;
    
    try {
        return process.evalSync(code, filename);
    } catch (e) {
        console.log(e.message + " - " + filename + " - " + e.stack);
        
    }
}

BootstrapModule.wrap = function(script) {
    return BootstrapModule.wrapper[0] + script + BootstrapModule.wrapper[1];
};

BootstrapModule.wrapper = [
                           '(function (exports, require, module, __filename, __dirname) { ',
                           '\n});'
                           ];

BootstrapModule.prototype.cache = function() {
    BootstrapModule._cache[this.id] = this;
};

BootstrapModule.prototype.load = function() {
    
    if (this.__ext == 'js')
    {
        this.compile()
    }
    else if (this.__ext == 'json')
    {
        
        var source = BootstrapModule.loadSource(this.id);
        try {
            this.exports = JSON.parse(source);
        } catch (err) {
            err.message = this.__filename + ': ' + err.message;
            throw err;
        }
    }
    
    this.loaded = true;
    
};



BootstrapModule.prototype.compile = function() {
    var source = BootstrapModule.getSource(this.id);
    
    source = BootstrapModule.wrap(source);
    var fn = BootstrapModule.runInThisContext(source, { filename: this.__filename , displayErrors: true});
    fn(this.exports, this.require.bind(this), this, this.__filename, this.__dirname);
};

function _absolutePath(base, relative) {
    var stack = base.split("/"),
    parts = relative.split("/");
    stack.pop(); // remove current file name (or empty string)

    for (var i=0; i<parts.length; i++) {
        if (parts[i] == ".")
            continue;
        if (parts[i] == "..")
            stack.pop();
        else
            stack.push(parts[i]);
    }
    return stack.join("/");
}

BootstrapModule._preCache = {};

BootstrapModule.setPreCacheSources = function(preCacheSources) {
    for (var key in preCacheSources) {
        if (Object.prototype.hasOwnProperty.call(preCacheSources, key)) {
            BootstrapModule._preCache[key] = preCacheSources[key];
        }
    }
}

BootstrapModule.loadPreCacheSource = function(id, source) {
    BootstrapModule._preCache[id] = source;
}

BootstrapModule.preCacheSourceExists = function(id) {
    return BootstrapModule._preCache.hasOwnProperty(id);
}

BootstrapModule.getPreCacheSource = function(id) {
    return BootstrapModule._preCache[id];
}

// Polyfill for atob and btoa
// Copyright (c) 2011..2012 David Chambers <dc@hashify.me>
!function(){function t(t){this.message=t}var r="undefined"!=typeof exports?exports:this,e="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";t.prototype=new Error,t.prototype.name="InvalidCharacterError",r.btoa||(r.btoa=function(r){for(var o,n,a=String(r),i=0,c=e,d="";a.charAt(0|i)||(c="=",i%1);d+=c.charAt(63&o>>8-i%1*8)){if(n=a.charCodeAt(i+=.75),n>255)throw new t("'btoa' failed: The string to be encoded contains characters outside of the Latin1 range.");o=o<<8|n}return d}),r.atob||(r.atob=function(r){var o=String(r).replace(/=+$/,"");if(o.length%4==1)throw new t("'atob' failed: The string to be decoded is not correctly encoded.");for(var n,a,i=0,c=0,d="";a=o.charAt(c++);~a&&(n=i%4?64*n+a:a,i++%4)?d+=String.fromCharCode(255&n>>(-2*i&6)):0)a=e.indexOf(a);return d})}();

// See NKStorage.swift or NKStorage.cs or NKStorage.java
