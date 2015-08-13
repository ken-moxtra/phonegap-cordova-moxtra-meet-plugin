


cordova.define("cordova/plugin/MoxtraMeetIntegration",
               
               function (require, exports, module) {
               
               var exec = require("cordova/exec");
               
               var MoxtraMeetIntegration = function () {
               };
               
               var initUserSuccessCallback = null;
               var initUserFailedCallback = null;
               
               var updateUserSuccessCallback = null;
               var updateUserFailedCallback = null;
               
              var unlinkAccountCompletionCallback = null;
               
               var startOrJoinMeetSuccessCallback = null;
               var startOrJoinMeetFailedCallback = null;
               var endMeetCallback = null;
               
               
               
               //callbacks
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.setupUserSuccessCallback = function () {
                    if( initUserSuccessCallback )
                        initUserSuccessCallback();
                    initUserSuccessCallback = null;
               };
               
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.setupUserFailedCallback = function (errorCode, errorDescription) {
                    if( initUserFailedCallback )
                        initUserFailedCallback(errorCode, errorDescription);
                    initUserFailedCallback = null;
               };
               
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.updateUserProfileSuccessCallback = function () {
                    if( updateUserSuccessCallback )
                        updateUserSuccessCallback();
                    updateUserSuccessCallback = null;
               };
               
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.updateUserProfileFailedCallback = function (errorCode, errorDescription) {
                    if( updateUserFailedCallback )
                        updateUserFailedCallback(errorCode, errorDescription);
                    updateUserFailedCallback = null;
               };
               
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.unlinkAccountCompletionCallback = function (success) {
                    if( unlinkAccountCompletionCallback )
                        unlinkAccountCompletionCallback(success);
                    unlinkAccountCompletionCallback = null;
               };
               
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.startMeetSuccessCallback = function (meetID) {
                    if( startOrJoinMeetSuccessCallback )
                        startOrJoinMeetSuccessCallback(meetID);
                    startOrJoinMeetSuccessCallback = null;
               };
               
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.startMeetFailedCallback = function () {
                    if( startOrJoinMeetFailedCallback )
                        startOrJoinMeetFailedCallback();
                    startOrJoinMeetFailedCallback = null;
               };
               
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.endMeetCallback = function () {
                    if( endMeetCallback  )
                        endMeetCallback();
                    endMeetCallback = null;
               };
               
               
               //customize configuations.
               //customize 1. hide invitebutton flag.
               //-------------------------------------------------------------------
               var hideInviteButtonFlag = false;
               MoxtraMeetIntegration.prototype.hideInviteButton = function() {
                    return hideInviteButtonFlag;
               };
               MoxtraMeetIntegration.prototype.setInviteButtonHidden = function(hideInviteButton ){
                    hideInviteButtonFlag = hideInviteButton;
               };
               
               //customize 2. auto join audio flag.
               //-------------------------------------------------------------------
               var supportAutoJoinAudioFlag = true;
               MoxtraMeetIntegration.prototype.supportAutoJoinAudio = function() {
                    return supportAutoJoinAudioFlag;
               };
               MoxtraMeetIntegration.prototype.setSupportAutoJoinAudio = function(supportAutoJoinAudio ){
                    supportAutoJoinAudioFlag = supportAutoJoinAudio;
               };
               
               //customize 3. auto start screen share flag.
               //-------------------------------------------------------------------
               var supportAutoStartScreenShareFlag = true;
               MoxtraMeetIntegration.prototype.supportAutoStartScreenShare = function() {
                    return supportAutoStartScreenShareFlag;
               };
               MoxtraMeetIntegration.prototype.setSupportAutoStartScreenShare = function(supportAutoStartScreenShare ){
                    supportAutoStartScreenShareFlag = supportAutoStartScreenShare;
               };
               
               //customize 4. support invite contact by sms support flag.
               //-------------------------------------------------------------------
               var supportInviteContactsBySMSFlag = true;
               MoxtraMeetIntegration.prototype.supportInviteContactsBySMS = function() {
                    return supportInviteContactsBySMSFlag;
               };
               MoxtraMeetIntegration.prototype.setSupportInviteContactsBySMS = function(supportSMS ){
                    supportInviteContactsBySMSFlag = supportSMS;
               };
               
               //customize 5. support email support flag.
               //-------------------------------------------------------------------
               var supportInviteContactsByEmailFlag = true;
               MoxtraMeetIntegration.prototype.supportInviteContactsByEmail = function() {
                    return supportInviteContactsByEmailFlag;
               };
               MoxtraMeetIntegration.prototype.setSupportInviteContactsByEmail = function(supportEmail ){
                    supportInviteContactsByEmailFlag = supportEmail;
               };

               //customize 6. customize bodyOfSMSContentWithMeetLink
               //-------------------------------------------------------------------
               var bodyOfSMSContentWithMeetLinkMethod = null;
               MoxtraMeetIntegration.prototype.getBodyOfSMSContentWithMeetLink = function(meetLink) {
                   if( bodyOfSMSContentWithMeetLinkMethod ){
                        return bodyOfSMSContentWithMeetLinkMethod(meetLink);
                   }
                    return '';
               };
               MoxtraMeetIntegration.prototype.setBodyOfSMSContentWithMeetLinkMethod = function(generateMeetLinkMethod){
                    bodyOfSMSContentWithMeetLinkMethod = generateMeetLinkMethod;
               };
               
               //customize 7. customize HTMLBodyOfEmailContentWithMeetLink
               //-------------------------------------------------------------------
               var HTMLBodyOfEmailContentWithMeetLinkMethod = null;
               MoxtraMeetIntegration.prototype.getBodyOfEmailContentWithMeetLink = function(meetLink) {
                   if( HTMLBodyOfEmailContentWithMeetLinkMethod ){
                        return HTMLBodyOfEmailContentWithMeetLinkMethod(meetLink);
                   }
                   return '';
               };
               MoxtraMeetIntegration.prototype.setBodyOfEmailContentWithMeetLink = function(generateEmailMeetLinkMethod){
                    HTMLBodyOfEmailContentWithMeetLinkMethod = generateEmailMeetLinkMethod;
               };
               
               //customize 8. email title.
               //-------------------------------------------------------------------
               var subjectOfEmailContentTitle = null;
               MoxtraMeetIntegration.prototype.subjectOfEmailContentTitle = function() {
                    return subjectOfEmailContentTitle;
               };
               MoxtraMeetIntegration.prototype.setSubjectOfEmailContentTitle = function(title){
                    subjectOfEmailContentTitle = title;
               };
               
               //customize 8. invite message in chat panel.
               //-------------------------------------------------------------------
               var customizedInviteMessageMethod = null;
               MoxtraMeetIntegration.prototype.getCustomizedInviteMessage = function(meetLink, beJoinedAudio, beStartedSharing) {
                   if( customizedInviteMessageMethod ){
                        return customizedInviteMessageMethod(meetLink, beJoinedAudio, beStartedSharing);
                   }
                   return '';
               };
               MoxtraMeetIntegration.prototype.setCustomizedInviteMessage = function(generateInviteMessageMethod){
                    customizedInviteMessageMethod = generateInviteMessageMethod;
               };
               
               //customize 9. auto hide bottom control bar flag.
               //-------------------------------------------------------------------
               var autoHideControlBarFlag = false;
               MoxtraMeetIntegration.prototype.autoHideControlBar = function() {
                    return autoHideControlBarFlag;
               };
               MoxtraMeetIntegration.prototype.setAutoHideControlBar = function(autoHideControlBar ){
                    autoHideControlBarFlag = autoHideControlBar;
               };
               
               //customize 10. support VoIP flag.
               //-------------------------------------------------------------------
               var supportVoIPFlag = true;
               MoxtraMeetIntegration.prototype.supportVoIP = function() {
                    return supportVoIPFlag;
               };
               MoxtraMeetIntegration.prototype.setSupportVoIP = function(supportVoIP ){
                    supportVoIPFlag = supportVoIP;
               };
               
               //customize 11. support chat flag.
               //-------------------------------------------------------------------
               var supportChatFlag = true;
               MoxtraMeetIntegration.prototype.supportChat = function() {
                    return supportChatFlag;
               };
               MoxtraMeetIntegration.prototype.setSupportChat = function(supportChat ){
                    supportChatFlag = supportChat;
               };
               
               //setup user.
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.initUser = function(initSuccessCallback, initFailedCallback, firstname, lastname, user_uuid, org_id){
                    if( !initSuccessCallback ) {
                       initSuccessCallback = function () {
                       }
                    }
                    if( !initFailedCallback ) {
                        initFailedCallback = function (errorCode, errorDescription) {
                        }
                    }
                    if( !firstname )
                        firstname = '';
                    if( !lastname )
                        lastname = '';
                    if( !user_uuid )
                        user_uuid = '';
                    if( !org_id )
                        org_id = '';
                    initUserSuccessCallback = initSuccessCallback;
                    initUserFailedCallback = initFailedCallback;
                    cordova.exec(function () {}, function () {}, 'MoxtraMeet', 'setUser', [firstname, lastname, user_uuid, org_id]);
               };
               
               //update user.
               MoxtraMeetIntegration.prototype.updateUser = function(updateSuccessCallback, updateFailedCallback, firstname, lastname){
                    if( !updateSuccessCallback ) {
                        updateSuccessCallback = function () {
                        }
                    }
                    if( !updateFailedCallback ) {
                        updateFailedCallback = function (errorCode, errorDescription) {
                        }
                    }
                    if( !firstname )
                        firstname = '';
                    if( !lastname )
                        lastname = '';
                    updateUserSuccessCallback = updateSuccessCallback;
                    updateUserFailedCallback = updateFailedCallback;
                    cordova.exec(function () {}, function () {}, 'MoxtraMeet', 'updateUser', [firstname, lastname]);
                };
               
               //log out.
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.logout = function (logoutCompletionCallback) {
                    if( !logoutCompletionCallback ) {
                        logoutCompletionCallback = function (success) {
                        }
                    }
                    unlinkAccountCompletionCallback = logoutCompletionCallback;
                    cordova.exec(function () {}, function () {}, 'MoxtraMeet', 'logout', [meetID,username]);
               };
               
               //start meet interface.
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.startMeet = function (startCallback, startFailedCallback, endCallback, meetTopic) {
                   if (!startCallback) {
                       startCallback = function (meetID) {
                       }
                   }
                   if (!startFailedCallback) {
                       startFailedCallback = function () {
                       }
                   }
                   if (!endCallback) {
                       endCallback = function () {
                       }
                   }
                    startOrJoinMeetSuccessCallback = startCallback;
                    startOrJoinMeetFailedCallback = startFailedCallback;
                    endMeetCallback = endCallback;
                    cordova.exec(function () {}, function () {}, 'MoxtraMeet', 'startMeet', [meetTopic]);
               };
               
               //join meet intenrface.
               //-------------------------------------------------------------------
               MoxtraMeetIntegration.prototype.joinMeet = function (joinCallback, joinFailedCallback, endCallback,meetID, username) {
               
                   if (!joinCallback) {
                       joinCallback = function (meetID) {
                       }
                   }
                   if (!joinFailedCallback) {
                       joinFailedCallback = function () {
                       }
                   }
                   if (!endMeetCallback) {
                       endMeetCallback = function () {
                       }
                   }
                   startOrJoinMeetSuccessCallback = joinCallback;
                   startOrJoinMeetFailedCallback = joinFailedCallback;
                   endMeetCallback = endCallback;
                   cordova.exec(function () {}, function () {}, 'MoxtraMeet', 'joinMeet', [meetID,username]);
               };
               
               
               
               var moxtraMeet = new MoxtraMeetIntegration();
                    module.exports = moxtraMeet;
               });