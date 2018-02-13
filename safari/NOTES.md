#  Safari Extension Notes

**Author:** Ryan Govostes <rgovostes@gmail.com>

This directory contains the [Safari App Extension][docs] project for 
ProPublica's Facebook Political Ad Collector extension.

[docs]: https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/SafariAppExtension_PG/

Safari App Extensions are tightly constrained, and do not use the WebExtensions
API that is supported by Firefox and Chrome. Therefore, the Safari port makes
use of some hacky and incomplete glue code that tries to provide the necessary
functionality.

May this code be a useful starting point for porting other extensions to Safari.


## Injected User Content Script

The user content script in `extension/src/content.js` is injected into all pages
on `*.facebook.com` domains. This is configured in the `Info.plist` file.

But as the content script uses `chrome.runtime.sendMessage()`, an unavailable
WebExtensions API, we inject the `safariglue.js` script first. This sets up a 
mock `chrome` object that translates the calls to
`safari.extension.dispatchMessage()`. 

Messages are received by
`SafariExtensionHandler.messageReceived(withName:from:userInfo:)` in the App
Extension.

There is currently no need for the App Extension to communicate back to the user
content script.


## Popup Script

Safari App Extensions do not use JavaScript to display a popup. Instead, they
can optionally display a regular native popover view. In our case we have a
`SafariExtensionViewController` with a `WKWebView` that loads the `index.html`
file.

The popup script also uses WebExtensions APIs, so again we need to inject
`safariglue.js`. We do so using the web view configuration's
`WKUserContentController` to attach a user script. In this case the glue code
must invoke different APIs to communicate back to the App Extension, such as
`window.webkit.messageHandlers.*.postNotification()`.

Messages are received by the 
`SafariExtensionViewController.userContentController(_:didReceive:)` method.

The popup script registers a listener for messages sent from the content script 
using `chrome.runtime.onMessage.addListener()`. However, this design doesn't
work with Safari App Extensions; the content script cannot message the popup
directly, so we need to be a messenger.

To communicate with the popup script from within the App Extension, we can
inject a call to `chrome.runtime.onMessage.__listen()` which is glue code that
invokes the callbacks that were previously registered.


## Background Script

The background script in `extension/src/background.js` is loaded into a `WKWebView`
off-screen. Message dispatch is handled mostly the same as the popup script.
