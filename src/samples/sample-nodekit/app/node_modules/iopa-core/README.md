# [![IOPA](http://iopa.io/iopa.png)](http://iopa.io)<br> IOPA Core

[![Build Status](https://api.shippable.com/projects/56e439729d043da07bc7a149/badge?branchName=master)](https://app.shippable.com/projects/56e439729d043da07bc7a149)
[![NPM](https://img.shields.io/badge/iopa-certified-99cc33.svg?style=flat-square)](http://iopa.io/)
[![limerun](https://img.shields.io/badge/limerun-certified-3399cc.svg?style=flat-square)](https://nodei.co/npm/limerun/)

[![NPM](https://nodei.co/npm/iopa-core.png?downloads=true&downloadRank=true)](https://nodei.co/npm/iopa-core/)

## About
The 160Kb bundle includes a full optimized bundle of the lightweight IOPA fabric.  
It is a [single javascript file](./dest/iopa-core.js) with no dependencies.

Includes:
  * IOPA server to run on both Node and NodeKit
  * IOPA router for server-side URL routing
  * IOPA static to server up static files (e.g., css, js, etc.)
  * IOPA templates engine including handlebars 
  * IOPA connect to use vanilla Node HTTP transport 
 
### Installation
``` js
npm install iopa-core
```
 
### Basic Example
``` js
const iopa = require('iopa-core'),
      static = iopa.static,
      templates = iopa.templates,
      router = iopa.router,
      handlebars = iopa.handlebars;
      
var app = new iopa.App();
       
app.use(templates);

app.use(router);

app.engine('.hbs', handlebars({
    defaultLayout: 'main', 
    views: 'views'
 }));
    
app.use(static(app, './public'));

app.get('/', function (context) {
   return context.render('home.hbs');
});

http.createServer(app.buildHttp()).listen(3000);
```
 
  
### Build
``` bash
git clone https://github.com/iopa-io/iopa-core.git 
npm install
npm run build
```

Minified version of entire IOPA fabric is placed in `dest` directory

### Distribution
Simply copy the `dest` directory to your next project for a drop in expressjs like replacement.