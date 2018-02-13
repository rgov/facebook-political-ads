//
//  safariglue.js
//  Created by Ryan Govostes on 2/13/18
//
//  This file maps WebExtension APIs to corresponding Safari Extension APIs.
//


// The following glue code is only for content scripts injected into the page
if (typeof safari !== 'undefined' && typeof chrome === 'undefined') {
  var chrome = {
    runtime: {
      sendMessage: function (message) {
        safari.extension.dispatchMessage('sendMessage', { body: message });
      },
    },
  };
}


// The following glue code is for code hosted in the App Extension process (such
// as the background script)
if (typeof window.webkit !== 'undefined' && typeof chrome === 'undefined') {
  var chrome = {
    runtime: {
      sendMessage: function (message) {
        window.webkit.messageHandlers.bridge.postNotification({
          message: 'sendMessage',
          body: message
        });
      },
      
      onMessage: {
        // When our App Extension wants to call back to a listener who has
        // registered with chrome.onMessage.addListener(), we will invoke
        // chrome.runtime.onMessage.__listen(message)
        __listeners: [],
        
        __listen: function (message) {
          this.__listeners.forEach(function (callback) {
            callback(message, null, function () {
              console.error('Glue code does not support sendResponse');
            });
          });
        },
        
        addListener: function(callback) {
          this.__listeners.push(callback);
        },
      },
    },
  }
}
