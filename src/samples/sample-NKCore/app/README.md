# {NK} Chat Application for IOPA and {NK} NodeKit

[![Build Status](https://api.shippable.com/projects/56e35a479d043da07bc1e3e0/badge?branchName=master)](https://app.shippable.com/projects/56e35a479d043da07bc1e3e0) 
[![IOPA](https://img.shields.io/badge/iopa-middleware-99cc33.svg?style=flat-square)](http://iopa.io)
[![NodeKit](https://img.shields.io/badge/nodekit-ready-3399cc.svg?style=flat-square)](http://nodekit.io/)

[![NPM](https://nodei.co/npm/iopa-sample-chat.png?downloads=true)](https://nodei.co/npm/iopa-sample-chat/)

Open Source Chat App 

## Running the application locally
  The application uses [Node.js](http://nodejs.org/) and [npm](https://www.npmjs.com/), so you must download and install them as part of the following steps.

  1. Go to the project folder in a terminal and run the `npm install` command.
  2. Start the application by running `npm start`.
  3. Open `http://localhost:3000` to see the running application.
  
## About the Sample
 The sample includes the lightweight IOPA fabric and includes
  * IOPA server to run on both Node and NodeKit without application changes
  * IOPA router to demonstrate URL routing
  * IOPA static to server up static files (e.g., css, js, etc.)
  * IOPA templates engine including handlebars for splitting a large single page view into multiple smaller components
  * IOPA connect to use vanilla Node HTTP transport 
  
  The sample is a fully fledged chat application using a Firebase back end.  No other dependencies other
  than the IOPA stack which is installed automatically using npm.
  * No database or other transport engines, using Google Firebase for simplicity of demonstrating the sample
  * No front-end framework (like React, or Angular), just pure DOM JQuery, again just to demonstrate the sample
  * Handlebars used as the template engine, others could easily be sustituted
  
  The application was written by OffGridNetworks to demonstrate ease of use in creating Node applications using the IOPA 
  stack instead of Express, and to provide a high fidelity sample to encourage a high quality ecosystem for both
  IOPA servers and for {NK} NodeKit applications.  It runs extremely well on NodeKit across OS X, iOS, Windows, Android and is
  responsive to different device sizes.
  
## License

  This code is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE).
  
This product includes software developed at
* The Internet of Protocols Alliance [http://iopa.io/](http://iopa.io/)
* The {NK} NodeKit Engine [http://nodekit.io/](http://nodekit.io/)
* OffGridNetworks [http://offgridnetworks.com/](http://offgridnetworks.com/)

