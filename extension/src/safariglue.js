//
//  safaricompat.js
//  Created by Ryan Govostes on 2/13/18
//
//  This file maps WebExtension APIs to corresponding Safari Extensions APIs.
//

if (typeof safari !== 'undefined' && typeof chrome === 'undefined') {
  global.chrome = {
    runtime: {
      sendMessage: function (message) {
        safari.extension.dispatchMessage('sendMessage', message);
      }
    },
    
    browserAction: {
      setBadgeText: function (details) {
        safari.extension.dispatchMessage('setBadgeText', details);
      }
    }
  };
}
