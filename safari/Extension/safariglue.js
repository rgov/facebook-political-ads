//
//  safariglue.js
//  Created by Ryan Govostes on 2/13/18
//
//  This file maps WebExtension APIs to corresponding Safari Extension APIs.
//
//  To use within a Safari Web Extension, the first SFSafariContentScript in
//  the app extension's Info.plist should point to this script.
//
//  To use within a WKWebView, inject this file as a WKUserScript.
//

var glue = undefined;


// Glue code for content scripts injected into the page
if (typeof safari !== 'undefined' && typeof chrome === 'undefined') {
  glue = {
    sendMessage: function (name, message) {
      safari.extension.dispatchMessage(name, {
        sender: this.uuid,
        body: JSON.stringify(message),
      });
    },
    
    receiveMessage: function (sender, message) {
      // TODO: Unpack the message, etc.
      // There are currently no messages sent from the App Extension to the
      // content scripts.
    },
  };
  
  // Listen to messages sent to us with SafariWebPageProxy.dispatchMessage()
  safari.self.addEventListener('message', glue.receiveMessage, false);
}


// Glue code is for code hosted inside WKWebViews
if (typeof window.webkit !== 'undefined' && typeof chrome === 'undefined') {
  glue = {
    sendMessage: function (name, message) {
      window.webkit.messageHandlers.bridge.postMessage({
        name: name,
        sender: this.uuid,
        body: JSON.stringify(message),
      });
    },
    
    receiveMessage: function (sender, message) {
      // FIXME: I don't like the structure here one bit.
      if (sender == this.uuid) { return }
      chrome.runtime.onMessage.__listen(JSON.parse(message))
    },
  };
  
  // When we want to send a message to the WKWebView, we should use
  // <<TODO...>>
}


// Now we can implement some of the WebExtensions API using our primitives
if (typeof glue !== 'undefined') {
  function uuid() {
    return '00000000-0000-0000-0000-000000000000'.replace(/0/g, c =>
      (crypto.getRandomValues(new Uint8Array(1))[0] & 15).toString(16)
    )
  }
  
  // We give the glue object a unique UUID that is attached to all outgoing
  // messages; this way, we can avoid posting messages to ourselves
  glue.uuid = uuid()
  
  var chrome = {
    runtime: {
      
      sendMessage: function (a, b, c) {
        // The rules for this one are confusing, see
        // https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/runtime/sendMessage
        
        let message = undefined;
        let warnExtensionId = false;
        let warnOptions = false;
        
        if (arguments.length == 1) {
          message = a;
        } else if (arguments.length == 2) {
          if (typeof b == 'string') {
            warnExtensionId = true;
            message = b;
          } else {
            warnOptions = true;
            message = a;
          }
        } else if (arguments.length == 3) {
          warnExtensionId = warnOptions = true;
          message = b;
        }
        
        // Whine about features we don't support
        if (warnExtensionId) {
          console.warn('Glue: Message passing between extensions is not '
                     + 'supported, sending locally');
        }
        if (warnOptions) {
          console.warn('Glue: Message options are ignored')
        }
        
        // Return a Promise to wait for a reply
        return new Promise(function (resolve, reject) {
          // TODO: Make a way for the message to be resolved
          glue.sendMessage('dispatchMessage', message);
        });
      }, /* end chrome.runtime.sendMessage */
        
      onMessage: {
        // When our App Extension wants to call back to a listener who has
        // registered with chrome.onMessage.addListener(), we will invoke
        // chrome.runtime.onMessage.__listen(message)
        __listeners: [],
        
        __listen: function (message) {
          console.log('Received message', message);
          this.__listeners.forEach(function (callback) {
            callback(message, null, function () {
              console.error('Glue: Does not support sendResponse');
            });
          });
        },
        
        addListener: function (callback) {
          this.__listeners.push(callback);
        },
      }, /* end chrome.runtime.onMessage */
      
    }, /* end chrome.runtime */
    
    browserAction: {
      
      setBadgeText: function (details) {
        // Another confusing one
        // https://developer.mozilla.org/en-US/Add-ons/WebExtensions/API/browserAction/setBadgeText
        
        if (typeof details.tabId !== 'undefined') {
          console.warn('Glue: Tab-specific badge text is not supported')
        }
        
        if (details.text === null) {
          glue.sendMessage('setBadgeText', '');
        } else {
          glue.sendMessage('setBadgeText', details.text);
        }
      }, /* end chrome.browserAction.setBadgeText */
        
    }, /* end chrome.browserAction */
    
  }  /* end chrome */
}
