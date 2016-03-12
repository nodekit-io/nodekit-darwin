/**
 * Copyright (c) 2016 OffGrid Networks. All Rights Reserved.
 * Portions Copyright Firebase (Google) 2014 under MIT license
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

var NKChatChannel = function NKChatChannel(username, cb) {
    var self = this;
    var chatRef = new Firebase("https://firechat-demo.firebaseio.com");
    this._chat = new Firechat(chatRef);
    chatRef.authAnonymously(function(error, authData) {
        if (error) {
            console.log("Login Failed!", error);
        } else {
            self._chat.setUser(authData.uid, username, cb);
                 /*   console.log("Connecting to Digital Assistant Channel");
                  
                $.get('/chat-getassistant', { "user": self._user.id })
                    .done(function (digitalAssistant) {
                        console.log("Identified Digital Assistant Channel");
                        if ((digitalAssistant) && (digitalAssistant.name == "NKAssistant")) {
                            self._digitalAssistantUserId = digitalAssistant.user;
                            self._digitalAssistantRoomId = digitalAssistant.id;
                            self._chat.enterRoom(digitalAssistant.id)
                        }
                    }).fail(function (error) {
                        error = error.responseJSON ? error.responseJSON.error : error.statusText;
                        console.log('error:', error);
                    }); */
        }
    });
};

NKChatChannel.prototype._onUpdateUser = function(user) {
    this._invokeEventCallbacks('user-update', user);
};

NKChatChannel.prototype._onAuthRequired = function() {
    this._invokeEventCallbacks('auth-required');
};

NKChatChannel.prototype._onEnterRoom = function(room) {
    this._invokeEventCallbacks('room-enter', room);
};

NKChatChannel.prototype._onNewMessage = function(roomId, message) {
    this._invokeEventCallbacks('message-add', roomId, message);
};

NKChatChannel.prototype._onRemoveMessage = function(roomId, messageId) {
    this._invokeEventCallbacks('message-remove', roomId, messageId);
};

NKChatChannel.prototype._onLeaveRoom = function(roomId) {
    this._invokeEventCallbacks('room-exit', roomId);
};

NKChatChannel.prototype._onNotification = function(notification) {
    this._invokeEventCallbacks('notification', notification);
};

NKChatChannel.prototype._onFirechatInvite = function(invite) {
    this._invokeEventCallbacks('room-invite', invite);
};

NKChatChannel.prototype._onFirechatInviteResponse = function(invite) {
    this._invokeEventCallbacks('room-invite-response', invite);
};

NKChatChannel.prototype.setUser = function(userId, userName, callback) {
    this._chat.setUser(userId, userName, callback);
};

NKChatChannel.prototype.resumeSession = function() {
    this._chat.resumeSession();
};

NKChatChannel.prototype.on = function(eventType, cb) {
    this._chat.on(eventType, cb);
};

NKChatChannel.prototype.createRoom = function(roomName, roomType, callback) {
    this._chat.createRoom(roomName, roomType, callback);
};

NKChatChannel.prototype.enterRoom = function(roomId) {
    this._chat.enterRoom(roomId);
};

NKChatChannel.prototype.leaveRoom = function(roomId) {
    this._chat.leaveRoom(roomId);
};

NKChatChannel.prototype.sendMessage = function(roomId, messageContent, messageType, cb) {
    this._chat.sendMessage(roomId, messageContent, messageType, cb);
};

NKChatChannel.prototype.deleteMessage = function(roomId, messageId, cb) {
    this._chat.deleteMessage(roomId, messageId, cb);
};

NKChatChannel.prototype.toggleUserMute = function(userId, cb) {
    this._chat.toggleUserMute(userId, cb);
};

NKChatChannel.prototype.sendSuperuserNotification = function(userId, notificationType, data, cb) {
    this._chat.sendSuperuserNotification(userId, notificationType, data, cb);
};

NKChatChannel.prototype.warnUser = function(userId) {
    this._chat.warnUser(userId);
};

NKChatChannel.prototype.suspendUser = function(userId, timeLengthSeconds, cb) {
    this._chat.suspendUser(userId, timeLengthSeconds, cb);
};

NKChatChannel.prototype.inviteUser = function(userId, roomId) {
    this._chat.inviteUser(userId, roomId);
};

NKChatChannel.prototype.acceptInvite = function(inviteId, cb) {
    this._chat.acceptInvite(inviteId, cb);
};

NKChatChannel.prototype.declineInvite = function(inviteId, cb) {
    this._chat.declineInvite(inviteId, cb);
};

NKChatChannel.prototype.getRoomList = function(cb) {
    this._chat.getRoomList(cb);
};

NKChatChannel.prototype.getUsersByRoom = function(roomId, cb) {
    this._chat.getUsersByRoom(roomId, cb);
};

NKChatChannel.prototype.getUsersByPrefix = function(prefix, startAt, endAt, limit, cb) {
    this._chat.getUsersByPrefix
};