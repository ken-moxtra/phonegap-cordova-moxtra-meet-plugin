
phonegap-cordova-moxtra-meet-plugin 
======================
Moxtra Integration

Currently only adds MEET functionality to IOS projects. Will be updates as Moxtra adds functions and platforms.


Installation
------------



# Project Structure

<pre>
  |_src
  | |_ios
  |   |MoxtraMeetIntegration.m
  |   |MoxtraMeetIntegration.h
  |   |MoxtraSDK.sdk
  |   |	| MoxtraSDK
  |   |	| Moxtra.h
  |   |	| MXClient.h
  |   |	| MoxtraSDKResources.bundle
  |_www
  |  |_moxtra-meet.js
</pre>


Follow the [Command-line Interface Guide](http://cordova.apache.org/docs/en/edge/guide_cli_index.md.html#The%20Command-line%20Interface).

If you are not using the Cordova Command-line Interface, follow [Using Plugman to Manage Plugins](http://cordova.apache.org/docs/en/edge/plugin_ref_plugman.md.html).

Get your `APP_ID` and `CLIENT_SECRET`  and  from  [Moxtra Developer Site](http://developer.moxtra.com/)

Change the  Plugins/MoxtraMeetIntegration.m file where you insert your `APP_ID` and `CLIENT_SECRET` that you got from Moxtra.


Usage Example.


``` 
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },

    initUserSuccessCallback: function() {
        //alert('init user success!');
    },

    initUserFailedCallback: function(errorCode, errorDescription) {
        alert('init user failed! error code:' + errorCode + ' error description:' + errorDescription);
    },

    updateUserProfileSuccessCallback: function() {
        //alert('update user profile success!');
    },

    updateUserProfileFailedCallback: function(errorCode, errorDescription) {
        alert('update user profile failed! error code:' + errorCode + ' error description:' + errorDescription);
    },

    startMeetFailedCallback: function() {
        alert('start meet failed!');
    },

    startMeetCallback :function(meetID) {
        alert('start meet success! meetID:' + meetID);
    },

    endMeetCallback :function() {
        alert('meet ended!');
    },

    //customize functions.
    //customize 1: sms contents.
    getBodyOfSMSContentWithMeetLinkMethod :function(meetLink) {
        return 'This is SMS customized message, Please join meet with link: ' +meetLink;
    },
    //customize 2: email content with email link.
    getBodyOfEmailContentWithMeetLinkMethod :function(meetLink) {
        return 'This is Email customized message, Please join meet with link: ' +meetLink;
    },

    //customize 3: invite message in chat panel
    getCustomizedInviteMessageMethod :function(meetLink, beJoinedAudio, beStartedSharing) {
        return 'This is customized message in chat panel, Please join meet with link: ' +meetLink;
    },

    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');

        var meet = window.cordova.require("cordova/plugin/MoxtraMeetIntegration");

        if( meet != null )
        {
            //customize featuers
            meet.setInviteButtonHidden(false);//default is false.
            meet.setSupportAutoJoinAudio(true);//default is true.
            meet.setSupportAutoStartScreenShare(true);//default is true.
            meet.setSupportInviteContactsBySMS(true);
            meet.setSupportInviteContactsByEmail(true);
            //customize email title & contents.
            meet.setSubjectOfEmailContentTitle('This is email title');
            meet.setBodyOfEmailContentWithMeetLink(app.getBodyOfEmailContentWithMeetLinkMethod);

            //customize sms contents.
            meet.setBodyOfSMSContentWithMeetLinkMethod(app.getBodyOfSMSContentWithMeetLinkMethod);

            //customize invite message in chat panel.
            meet.setCustomizedInviteMessage(app.getCustomizedInviteMessageMethod);

            //cutomize features
            meet.setAutoHideControlBar(false);//default is false.
            meet.setSupportVoIP(true);//default is true.
            meet.setSupportChat(true);//default is true.

            //login with unique id.
            meet.initUser(app.initUserSuccessCallback, app.initUserFailedCallback, 'firstname', 'lastName', 'user unique id', '');

            //update user profile if need
            meet.updateUser(app.updateUserProfileSuccessCallback, app.updateUserProfileFailedCallback, 'Ken', 'Yu');

            //start meet
            meet.startMeet(app.startMeetCallback, app.startMeetFailedCallback, app.endMeetCallback, 'Meet topic');
            //meet.joinmeet(app.startMeetCallback, app.startMeetFailedCallback, app.endMeetCallback, 'Ken Yu', 'Meet ID');
        }
        else
            alert('error!');        
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

app.initialize();
```