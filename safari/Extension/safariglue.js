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
    },
  }
}
