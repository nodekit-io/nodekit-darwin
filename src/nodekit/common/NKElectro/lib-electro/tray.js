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

var Tray = io.nodekit.electro.Tray

var _trays = {}

Tray.prototype._init = function() {
    this._id = this.id;
    _trays["w" + this._id] = this;
};

Tray.prototype._deinit = function() {
    delete _trays["w" + this._id];
     this._id = nil;
};


Tray.fromId = function(id) {
    return _trays["w" + id];
};
