![http://nodekit.io](https://raw.githubusercontent.com/nodekit-io/nodekit/master/docs/images/banner.png?v02)
*{NK} NodeKit* is the universal, open-source, embedded engine that provides a full Node.js instance inside desktop and mobile applications for macOS, iOS, Android, Fire OS, and Windows.  

For application developers, the backend can be written in pure Node javascript code, the front-end in the architecture of your choice including but not limited to Atom Electron API, Facebook React, Express, etc.)

*{NK} NodeKit* enables applications developed for Node to developed once and then run without alteration for any of the above platforms as well as in the browser.

This repository [nodekit-io/nodekit-darwin](https://github.com/nodekit-io/nodekit-darwin) contains those components that are specific to Apple platforms (including iOS, OSX, and tvOS). 

See [nodekit-io/nodekit-windows](https://github.com/nodekit-io/nodekit-windows) for the corresponding repository for Windows platforms (including Windows 7+ Desktop, Windows 10 Desktop, Windows 10+ Mobile, Xbox, SurfaceHub and IoT device familes) 

See [nodekit-io/nodekit-android](https://github.com/nodekit-io/nodekit-android) for the corresponding repository for Android platforms.

# {NK} NodeKit

[![Circle CI](https://img.shields.io/circleci/project/nodekit-io/nodekit-darwin.svg?style=flat-square)](https://circleci.com/gh/nodekit-io/nodekit-darwin)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat-square)](https://github.com/Carthage/Carthage)
[![Join the chat at https://gitter.im/nodekit-io/nodekit](https://img.shields.io/badge/Chat-on_gitter-46BC99.svg?style=flat-square)](https://gitter.im/nodekit-io/nodekit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![{NK} Roadmap](https://img.shields.io/badge/OpenSource-roadmap-DE3B30.svg?style=flat-square)](http://roadmap.nodekit.io)
[![@Contact](https://img.shields.io/badge/Contact-@nodekitio-4DA6FD.svg?style=flat-square)](https://twitter.com/nodekitio)

## Sample Application (using Command Line Tool)

Note: Command Line Tooling coming soon:

``` bash
npm install nodekit -g 
nodekit create myapp io.nodekit.myapp myapp
cd myapp
nodekit platform add ios
nodekit platform add macos
nodekit build
nodekit run macos
```

## Tests and Sample Application (Full Build)

Tests are directly embedded as a {NK} NodeKit application.  One of the the nice things about {NK} NodeKit being in pure Swift 2.x is that it has no external dependencies.  

``` bash
git clone https://github.com/nodekit-io/nodekit.git
```

Open `src/nodekit.xcodeproj` in Xcode.  You will see 4 build targets, 2 for the frameworks (on iOS and OSX respectively) and 2 for the sample app. 

Build the nodekit-Mac-sample for My Mac or the nodekit-iOS-sample for the iOS Simulator (e.g., iPhone 6) and run.   

You should see a beautiful chat application that automatically resizes to device size, and runs without change across all platforms

## Simple Configuration

Two lines in main.swift to launch an embedded WebKit view and start the NodeKit engine (already included for you in the sample).   

``` swift
import NodeKit
NKNodeKit.start();
```

Then just make sure any standard Node application is in the app/ directory.  This application will run in the `main` process (a hidden but highly performant JavaScript engine such as Nitro WKWebView or JavaScriptCore).   The first thing the application typically does is open a `renderer` window, very similar to Atom Electron: 

``` javascript
const app = require('electro').app;
const BrowserWindow = require('electro').BrowserWindow
app.on('ready', function() {
  var window = new BrowserWindow();
});
```

The sample app includes a built in web server for serving static and dynamic content; on iOS this can be an http server over a localhost port, but on OSX you may want to use no ports at all and just use built in protocol server.

Build in Xcode for both iOS and Mac targets.


## Three Main Components in {NK} NodeKit


[![{NK} Scripting](https://raw.githubusercontent.com/nodekit-io/nodekit/master/docs/images/NKScripting.png?v01)](https://github.com/nodekit-io/nodekit/blob/master/docs/NKScripting/readme.md)
> [**{NK} Scripting**](https://github.com/nodekit-io/nodekit/blob/master/docs/NKScripting/readme.md) is an advanced JavaScript - Native (Swift, Objective-C, .NET C#) bridge for hybrid applications.   It builds upon the core platform bridges such as JavaScriptCore or ChakraCore, but abstracts the implementation details and standardizes across even multiple scripting engine families on the same platform (e.g., Nitro WKWebView and UIWebViews on iOS).
It is the foundation of {NK} NodeKit and can be used without {NK} Electro or {NK} Core or with substitutes.

[![{NK} Electro](https://raw.githubusercontent.com/nodekit-io/nodekit/master/docs/images/NKElectro.png?v01)](https://github.com/nodekit-io/nodekit/blob/master/docs/NKElectro/readme.md)
> [**{NK} Electro**](https://github.com/nodekit-io/nodekit/blob/master/docs/NKElectro/readme.md) is an API for [{NK} NodeKit](http://nodekit.io) applications that facilitates application lifecycle and user interface tasks.  It is inspired by the Atom Electron API, and is generally a lighter-weight but code-compatible subset.  It requires {NK} Scripting but can be used without {NK} Core if you dont need all the Node features and just want a lightweight way of building universal desktop and mobile apps, a bit like Cordova but with {NK} Scripting features.

[![{NK} Core](https://raw.githubusercontent.com/nodekit-io/nodekit/master/docs/images/NKCore.png?v01)](https://github.com/nodekit-io/nodekit/blob/master/docs/NKCore/readme.md)
 > [**{NK} Core**](https://github.com/nodekit-io/nodekit/blob/master/docs/NKCore/readme.md) takes the above a step further and provides a light-weight but fully functional version of Node for [{NK} NodeKit](http://nodekit.io) applications.  It leverages the original Node source for all the Javascript components, but generally backs with different bindings to leverage each platform's built-in javascript engine(s) instead of the V8 engine.  Where possible native code has been moved to Javascript.  It requires {NK} Scripting and is generally paired with {NK} Electro as here, but technically you could replace {NK} Electro with your own code or plugin to open and manage the window lifecycle.


## Distribution

The {NK} NodeKit repository contains an XCode project with all the above components (zero dependencies) that compiles to an iOS 8 + and macOS 10.9 + dynamic framework.  Versions for Windows 10 and Android are in active development.

The single framework file (containing binary code and embedded resources like the core Node.js javascript code) can just be included in any iOS or macOS application.    See the sample app for an example.   You can thus compile and create your own projects;  no app store consumer really needs to know how you built it unless you want to tell them or modify the {NK} NodeKit source. 

## Is it really Node ?

*YES* for all the javascript portions (and most of Node is written in javascript, of course).  *NO* for all the V8 bindings.  

We include the direct source files from Node.js source directly in NodeKit (you can find them in the framework package in a folder called lib).  Then we add our own bindings to replace the V8 native ones, writing them in javascript as much as possible, with a few native calls for the really platform specific stuff like sockets, timers, and the file system.  These bindings have exactly the same API signatures as the Node versions so are plugin replacements.

This means most Node packages will work without modification.  Those that require node-gyp native bindings to V8 would require an alternative. 

## How does it relate to Cordova, Electron, CrossWalk, XWebView and NW ? 

Actually, we've built upon the shoulders of all of these and similarly on the excellent Nodelike and Nodyn projects (both no longer maintained) and even Microsoft's Node fork for ChakraCore, by taking the approach of re-writing the bindings to V8.  However, we've written or re-used as much code in JavaScript as far as possible.  The whole theory of the Node ecosystem is that JavaScript is pretty fast, in fact when compiled like we can with the Nitro engine used by {NK} NodeKit its really really fast.  Bridging back and forth to native tends to introduce latency which we like to avoid except where essential or where done for us by the emerging HTML5 / ES5 /ES6 features of most modern JavaScript engines.

The real motivation for us however, wasn't speed of execution, but rather we didnt want to include a large 48Mb executable for Chromium or its javascript engines in every app download... when most modern operating systems already include an ES5 engine.

So on iOS and Macs we use JavaScriptCore or Nitro... on Windows we use Chakra or ChakraCore... and on Android and Linux we use Chromium/V8.   Since the Node JavaScript source runs on each without patching (in some cases we add some polyfills), the only things we had to write (once per platform) were the bindings and again really just the primary four (TCP sockets, UDP sockets, timers and the file system).  Others like buffers, cryptography etc., are replaced by javascript only versions (ok for those following this far, actually for cryptography we just didnt like the idea of random generator being the javascript engine variant, so we dip into the OS for just that one random bytes call for improved security, no OpenSSL dependency just native platform)

## Debugging

Just use Safari Web Inspector to set breakpoints, inspect variables, etc. in both the JavaScriptScore and Nitro script engines (for the main process) as well as the UI and javascript environment of the renderer processes. 
![Safari WebInspector](https://raw.githubusercontent.com/nodekit-io/nodekit/master/docs/images/screenshot1.png?v01)

## Supports

* iOS 8+, 9+, 10+
* macOS 10.9, 10.10, 10.11, 10.12
* Android 4.4+, 5.0+, 6.0+
* Windows 10 Universal Platform (October 2015 update or more recent)
* Node.js ~0.12.x

## Still In development

* Windows 7, Vista, 8, 8.1 for desktop applications
* Node.js 4.x/5.x updates (we run a very stable 0.12.x for broadest package compatibility, and are currently testing the 4.x LTS version in a development branch).

## License

Apache 2.0

## Contributions (MasterFlow)

* Fork the repository.
* There is one eternal branch -- master.  
* All other branches (feature, release, hotfix, and whatever else we need) are temporary and only used as a convenience to share code with other developers and as a backup measure. They are always removed once the changes present on them land on master.
* Features are integrated onto the master branch primarily in a way which keeps the history linear
* Releases are done similarly to GitFlow. We create a new branch for the release, branching off at the point in master that you decide has all the necessary features. From then on new work, aimed for the next release, is pushed to master as always, and any urgent necessary changes are pushed to the release branch (avoided as far as possible)
* Finally, once the release is ready, we tag the top of the release branch. Then, because there is one eternal branch, there is only one way to get your release to be versioned permanently - and that is to merge the release branch into master and push that changed master. 
* After that, all the changes that were made during the release are now part of master, and the release branch is deleted.
* Hotfixes are very similar to releases, except you don't branch from an arbitrary commit on master, but from the release tag that you want to make the fix in. Again, work on master continues as always, and the necessary fixes are pushed to the hotfix branch. Once the fix is ready, the procedure is exactly the same as for a release - tag the top of the branch creating a new release, merge it into master, then delete the hotfix branch
* Submit pull request.

## Related Repositories on GitHub
* [nodekit-io/nodekit](https://github.com/nodekit-io/nodekit) contains the core documents and issues tracker
* [nodekit-io/nodekit-cli](https://github.com/nodekit-io/nodekit-cli) contains the command line tool
* [nodekit-io/nodekit-darwin](https://github.com/nodekit-io/nodekit-darwin), [nodekit-io/nodekit-windows](https://github.com/nodekit-io/nodekit-windows), and [nodekit-io/nodekit-android](https://github.com/nodekit-io/nodekit-android) contain the platform specific versions of {NK} NodeKit source

We went for platform specific code to allow searching by language on GitHub to show up appropriately (e.g., trending repositories in Swift, C#), to allow separate version numbers for minor platform-specific changes, and because the repositories are in essence not dependent on each other, but rather complementary language ports with the same functionality and API.

## News
* (October 2016) Command line tooling added for Android
* (September 2016) Initial Android release (NKScripting and NKElectro only)
* (March 2016) Added sample application, a beautiful lightweight chat application to highlight how to use {NK} NodeKit 
* (February 2016) Split platform versions into their own repositories on GitHub
* (February 2016) Initial release of NKScripting using the Chakra engine on Windows 10 platforms;  other engines coming
* (February 2016) Added [roadmap](http://roadmap.nodekit.io) for tracking contributions and future plans
* (February 2016) Removed the last of the Objective-C and C code;  the entire framework on Darwin platforms is now pure Swift 2.x including the rewritten POSIX sockets layer that makes full use of GCD, is non blocking, and contains no external dependencies;  we may end up releasing as `{NK} Sockets` as while there are lots of good Objective-C libraries, there are fewer Swift versions (and almost none without a tiny C dependency which we've eliminated) and we had to cobble this together from a few complementary sources. 
* (January 2016) Updated to use all core darwin JavaScript Engines, harmonized the API to industry standard (e.g, Electron subset for front end, JavaScriptCore like for back end) and refactored out {NK} Scripting and {NK} Electro and associated docs in the process
* (December 2015) Updated for Swift 2.0 and refactored for iOS and macOS.
* Master branch contains Node.js v0.12.x (working).   
* Node.js V4.x branch available but not in accelerated development.




