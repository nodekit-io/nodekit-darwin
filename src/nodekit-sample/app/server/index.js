/**
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

const useHttp = true;

const iopa = require('iopa-core'),
 static = iopa.static,
 templates = iopa.templates,
 handlebars = iopa.handlebars,
 router = iopa.router;

const http = require('http');

var fs = require('fs');
var path = require('path');

const BrowserWindow = require('electro').BrowserWindow,
    nodekit = require('electro').app;

console.log("STARTING SAMPLE APPLICATION");

var app = new iopa.App();

app.use(templates);

app.use(router);

app.engine('.hbs', handlebars({
    defaultLayout: 'main',
    views: 'views'
}));

app.use(static(app, './renderer'));

app.get('/', function(context) {
    return context.render('home', {
        data: {
            appname: 'NodeKit'
        }
    });
});

nodekit.on("ready", function() {
           var server;
           if (useHttp)
           {
           server = http.createServer(app.buildHttp());
           server.listen(null, "localhost", function(){
                         var port = server.address().port;
                         var p = new BrowserWindow({
                                                   'preloadURL': 'http://localhost:' + port,
                                                   'nk.allowCustomProtocol': false });
                         });
           }
           else
           {
           server = io.nodekit.electro.protocol.createServer('nodekit', app.buildHttp());
           server.listen();
           var p = new BrowserWindow({ 'preloadURL': 'nodekit://localhost',
                                     'nk.allowCustomProtocol': true });
           }
           
           console.log("Server running");
           });
