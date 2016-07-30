# NodeKit Archive (NKAR) Reader (NKArchiveReader)

A pure Swift NKAR (Zip) File Reader that is fast and low energy on iOS and macOS plaforms.

* Uses the latest libcompression library from Apple
* No dependency on minizip or libz
* No bloat for encryption or files larger than 4Gb
* Deflate or no decompression only
* Uses random access file seeking to minimize data that is read into memory
* Intended for servers that read directory of zip files once, cache all the directory information, and then get accessed on a file by file basis, without having to unzip the whole archive to temporary folders
* Uses least recently used cache (NSCache) for both directory (until low memory), and for full Zip Contents (last 2 zip files read)

## Usage


```js
var unzipper = NKArchiveReader.create()

var data = unzipper.dataForFile( "//Volumes/data/test.nkar", filename: "test/package.json")
```

## Installation

Copy the 6 NKZ* Swift files to your project

Make sure that `libcompression` is listed under XCode -> Targets -> Build Phases -> `Link Binary with Libraries` (no need to download its on every modern Apple developer machine but has to be explicitly added for the linker)

## Requirements
iOS 9 or later, OS X 10.10 or later, or macOS


## License

Apache 2 (see LICENSE)
Copyright (c) 2016 OffGrid Networks. All Rights Reserved.


