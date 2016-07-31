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

var NKChatUI = function NKChatUI() {  
    // JQUERY UI ELEMENTS
    this.$chatInput = $('.nkchat-window--message-input');
    this.$chatInputButton = $('#nkchat-window--message-button');
    this.$chatPane = $('.nkchat-box--pane');
    this.$$chatItemClass = "nkchat-box--item";
    this.$$chatItemHiddenClass = "nkchat-box--item_HIDDEN";
    this.$$chatItemPrefix = "nkchat-box--item_";
    this.$$chatItemTitleClass = "nkchat-box--message-title";
   
    this.$roomCreate = $('#nkchat-create-room-input');
    this.$roomCreateButton = $('#nkchat-create-room-button');
   
    this.$loading = $('.loader');
        
    this.$roomList = $('#nkchat-room-list');
    this.$roomTitle = $('#nkchat-current-room');
    this.$roomTitle2 = $('#nkchat-current-room-2');
    
    this.$currentUserDivs = $('.nkchat-current-user');
    this.$messageTemplates = $('.nkchat-box--item_HIDDEN');
    this.$currentUserAvatars = $('.nkchat-current-avatar');
    this.$userList = $('#nkchat-user-list');
    
    // CURRENT CONTEXT
    
    this._roomId = null;
    this._digitalAssistantUserId = null;
    this._digitalAssistantRoomId = null;
    
    // CONSTANTS AND REGEX HELPERS
    this.maxLengthUsername = 15;
    this.maxLengthUsernameDisplay = 13;
    this.maxLengthRoomName = 15;
    this.maxLengthMessage = 120;
    this.maxUserSearchResults = 100;
    
    this.urlPattern = /\b(?:https?|ftp):\/\/[a-z0-9-+&@#\/%?=~_|!:,.;]*[a-z0-9-+&@#\/%=~_|]/gim;
    this.pseudoUrlPattern = /(^|[^\/])(www\.[\S]+(\b|$))/gim;

    var self = this;

    // Initialize the UI
    this.UIbindElements();
    this.UIScrollToInput();
  
     // Initialize the Chat
    this._chat = new NKChatChannel('Noddy KitKat', function(user){
                self._user = user;
                self.refreshRooms();
                self.UIPaintPrimaryUser();
                self._chat.on('room-enter', self._onEnterRoom.bind(self));
                self._chat.on('message-add', self._onNewMessage.bind(self));
                self._chat.on('message-remove', self._onRemoveMessage.bind(self));      
    });
};

Object.defineProperty(NKChatUI.prototype, "userid", {get: function() { return this._user.id; } });
Object.defineProperty(NKChatUI.prototype, "roomid", {get: function() { return this._roomId; } });

NKChatUI.prototype.UIbindElements = function () {
    var self = this;
    var _converse = function(userText) {
        self.$loading.show();
        self.sendMessage(userText, function() {
            self.$loading.hide();
            self.UIClearInput();
        });
    }

    this.$chatInput.keyup(function (event) {
        if (event.keyCode === 13) {
            _converse($(this).val());
        }
    });
    
    this.$chatInputButton.bind('click', { self: this }, function(event) {
        _converse(self.$chatInput.val());
    });

    var _createRoom = function(roomName) {
        self.$loading.show();
        self.createRoom(roomName, function() {
            self.$loading.hide();
            self.$roomCreate.val('');
        });
    }
   
    this.$roomCreateButton.bind('click', { self: this }, function(event) {
       _createRoom($roomCreate.val());
    });
  
    this.$roomCreate.keyup(function (event) {
        if (event.keyCode === 13) {
            _createRoom($(this).val());
        }
    });
};

NKChatUI.prototype.UIScrollChatToBottom = function() {
    var element = this.$chatPane;
    element.animate({
        scrollTop: element[0].scrollHeight
    }, 420);
};

NKChatUI.prototype.UIScrollToInput = function() {
    var element = this.$chatInput;
    $('body, html').animate({
        scrollTop: (element.offset().top - window.innerHeight + element[0].offsetHeight) + 20 + 'px'
    });
};

NKChatUI.prototype.UIClearInput = function() {
    this.$chatInput.val('');
};

NKChatUI.prototype.UIPaintRoomList = function(rooms, cb) {
    var self = this;

    var template = function(obj) { obj || (obj = {}); var __t, __p = '', __e = _.escape, __j = Array.prototype.join; function print() { __p += __j.call(arguments, '') } with (obj) { __p += '<li data-room-type=\'' + __e(type) + '\' data-room-id=\'' + __e(id) + '\' data-room-name=\'' + __e(name) + '\'>\n<a href=\'#!\' class=\'clearfix '; if (isRoomOpen) { ; __p += ' highlight '; }; __p += '\'>\n<i class=\'fa fa-hashtag\'></i><span class=\'left\' title=\'' + __e(name) + '\'>' + __e(nameTrimmed) + '</span><small class=\'label pull-right bg-green\'>public</small>\n</a>\n</li>'; } return __p };

    var selectRoomListItem = function(e) {
        var parent = $(this).parent(),
            roomId = parent.data('room-id'),
            roomName = parent.data('room-name');
        self._chat.leaveRoom(self._roomId);
        self._roomId = roomId;
        self._chat.enterRoom(roomId, roomName);
        return false;
    };

    var count = 0;
    this.$roomList.empty();
    var keys = Object.keys(rooms);
    for (var i = keys.length - 1; i >= 0; i--) {
        var roomId = keys[i];
        var room = rooms[roomId];

        if (room.name == "MyNewRoom")
            room.name = "Public"
        else if (room.name.substr(0, 2) == "NK" && room.name.length > 2)
            room.name = room.name.substr(2);
        else
            continue;

        if (count >= 4 && room.name != "Public") continue;

        if (self._roomId == null && room.name == "Public") self._roomId = roomId;
        room.isRoomOpen = (roomId == self._roomId);
        room.nameTrimmed = _trimWithEllipsis(room.name, self.maxLengthRoomName);

        var $roomItem = $(template(room));
        $roomItem.children('a').bind('click', selectRoomListItem);

        count++;

        this.$roomList.append($roomItem.toggle(true));

    }
    _sortListLexicographically(self.$roomList);
    cb();
};

NKChatUI.prototype.UIPaintUserList = function (users, cb) {
    
        var template = function (obj) { obj || (obj = {}); var __t, __p = '', __e = _.escape, __j = Array.prototype.join; function print() { __p += __j.call(arguments, '') } with (obj) { 
             __p += '<li class=\'list-group-item\' data-user-id=\'' + __e(id) + '\'><b>' + __e(nameTrimmed) + '</b>';
             __p += '<span class=\'pull-right\'><img style=\'height: 25px; width: auto\' src=\'img\/avatar-peer' + avatar + '.svg\' alt=\'User profile picture\'></span>'; 
             __p += '\n</li>'; } return __p };
        this.$userList.empty();
  
        for (var username in users) {
            var user = users[username];
            user.disableActions = (!this._user || user.id === this._user.id);
            if (user.name.substring(0,1) == '@')
            {
                user.avatar = user.name.substring(1,2);
                user.name = user.name.substring(3);
            } else
            {
                var s = "0" + _hashCode(user.name);
                user.avatar = s.substr(s.length-2);
            }
            user.nameTrimmed = _trimWithEllipsis(user.name, this.maxLengthUsernameDisplay);
            user.isMuted = (this._user && this._user.muted && this._user.muted[user.id]);
            this.$userList.append(template(user));
        }
        _sortListLexicographically(this.$userList);
    
    cb();  
};

NKChatUI.prototype.UIPaintPrimaryUser = function () {
    var self = this;
    if (!self._user.avatar)
    {
                var s = "0" + _hashCode(self._user.name);
                self._user.avatar = s.substr(s.length-2);
    }
    this.$currentUserDivs.each(function()
    {
        $( this ).html(self._user.name);
    })   
     this.$currentUserAvatars.each(function()
    {
        $( this ).attr('src', 'img\/avatar-peer' + self._user.avatar + '.svg');
    })   
};

NKChatUI.prototype.UIClearMessages = function () {
    $('.' + this.$$chatItemClass).not('.' + this.$$chatItemHiddenClass).remove();
};

var _scrollTime = (new Date()).getTime(); 
NKChatUI.prototype.UIPaintChatMessage = function(message) {
    var self = this;
  
    var $chatBox = $('.' + this.$$chatItemPrefix + message.origin).first().clone();

    $chatBox.find('p').html('<div>' + message.message + '<div class=\'' + this.$$chatItemTitleClass + '\'>' + message.name + '</div>' + ' </div>')

    $chatBox.attr('data-message-id', message.messageId);

    if (message.avatar)
        $chatBox.find("img").eq(0).attr("src", "img/avatar-peer" + message.avatar + ".svg");

    $chatBox.insertBefore(this.$loading);
    setTimeout(function() {
        $chatBox.removeClass(self.$$chatItemHiddenClass);
    }, 100);

    var newScrollTime = (new Date()).getTime();

    if ((newScrollTime - _scrollTime) > 500)
        this.UIScrollChatToBottom();

    _scrollTime = newScrollTime;

    if (!message.messageId)
        this.$loading.hide();
};

NKChatUI.prototype.UIRemoveChatMessage = function (messageId) {
       $('.' + this.$$chatItemClass + '[data-message-id="' + messageId + '"]').remove()
};

// BRIDGE METHODS BETWEEN CHAT API AND UI METHODS ABOVE

NKChatUI.prototype.refreshRooms = function() {
    var self = this;
    
    this._chat.getRoomList(function(rooms) {
        self.UIPaintRoomList(rooms, function() {
            self._chat.enterRoom(self._roomId);
        });
    });
};

NKChatUI.prototype.refreshUsers = function () {
     var self = this;
 
     this._chat.getUsersByRoom(self._roomId, function(users){
         self.UIPaintUserList(users, function(){});
     });
};

NKChatUI.prototype.sendMessage = function (msg, cb) {
    this._chat.sendMessage(this._roomId, msg, 'default', cb);
};

NKChatUI.prototype.createRoom = function (roomName, cb) {
    this._chat.createRoom('NK' + roomName, 'public', cb);
};

NKChatUI.prototype._onEnterRoom = function(room) {
    var self = this;

     if (room.name == "MyNewRoom")
        room.name = "Public";

    this.$roomTitle.html(room.name);
    this.$roomTitle2.html(room.name);

    this._roomId = room.id;

    this.UIClearMessages();
    this.refreshRooms();
    this.refreshUsers();
   
    setTimeout(function() {
        var element = self.$chatPane;
        element.animate({
            scrollTop: element[0].scrollHeight
        }, 420);
    }, 500);
};

NKChatUI.prototype._onNewMessage = function(roomId, rawMessage) {
    if (roomId == this._digitalAssistantRoomId) {
        if (rawMessage.message.userid != this._user.id)
            return;

        rawMessage.isDigitalAssistant = true;
    } else
        rawMessage.isDigitalAssistant = false;

    var userId = rawMessage.userId;

    if (!this._user || !this._user.muted || !this._user.muted[userId]) {

        var self = this;
        var origin;
        if (rawMessage.isDigitalAssistant)
            origin = "ASSISTANT"
        else
            origin = (this._user && rawMessage.userId == this._user.id) ? "YOU" : "PEER";

        // Setup defaults
        var message = {
            id: rawMessage.id,
            localtime: _formatTime(rawMessage.timestamp),
            message: (rawMessage.isDigitalAssistant) ? rawMessage.message.body : rawMessage.message || '',
            userId: rawMessage.userId,
            name: rawMessage.name,
            origin: origin,
            type: rawMessage.type || 'default',
            disableActions: (!self._user || rawMessage.userId == self._user.id)
        };

        if (!rawMessage.isDigitalAssistant) {
            if (message.name.substring(0, 1) == '@') {
                message.avatar = message.name.substring(1, 2);
                message.name = message.name.substring(3);
            } else {
                var s = "0" + _hashCode(message.name);
                message.avatar = s.substr(s.length - 2);
            }
        }

        if (!rawMessage.isDigitalAssistant) {

            message.message = _.map(message.message.split(' '), function(token) {
                if (self.urlPattern.test(token) || self.pseudoUrlPattern.test(token)) {
                    return _linkify(encodeURI(token));
                } else {
                    return _.escape(token);
                }
            }).join(' ');

            message.message = _trimWithEllipsis(message.message, self.maxLengthMessage);
        }

        this.UIPaintChatMessage(message);
    }
};

NKChatUI.prototype._onRemoveMessage = function (roomId, messageId) {
     this.UIRemoveChatMessage(messageId);
};

// private helper functions
function _trimWithEllipsis(str, length) {
    str = str.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
    return (length && str.length <= length) ? str : str.substring(0, length) + '...';
};

function _sortListLexicographically(selector) {
    $(selector).children("li").sort(function (a, b) {
        var upA = $(a).text().toUpperCase();
        var upB = $(b).text().toUpperCase();
        return (upA < upB) ? -1 : (upA > upB) ? 1 : 0;
    }).appendTo(selector);
};

function _formatTime(timestamp) {
    var date = (timestamp) ? new Date(timestamp) : new Date(),
        hours = date.getHours() || 12,
        minutes = '' + date.getMinutes(),
        ampm = (date.getHours() >= 12) ? 'pm' : 'am';

    hours = (hours > 12) ? hours - 12 : hours;
    minutes = (minutes.length < 2) ? '0' + minutes : minutes;
    return '' + hours + ':' + minutes + ampm;
  };

function _linkify(str) {
    return str
      .replace(self.urlPattern, '<a target="_blank" href="$&">$&</a>')
      .replace(self.pseudoUrlPattern, '$1<a target="_blank" href="http://$2">$2</a>');
  };
  
function _hashCode(str){
    var hash = 0;
    if (str.length == 0) return hash;
    for (var i = 0; i < str.length; i++) {
        var char = str.charCodeAt(i);
        hash = ((hash<<5)-hash)+char;
        hash = hash & hash; // Convert to 32bit integer
    }
    return ((hash + 2147483647 + 1) % 6) + 1;
}