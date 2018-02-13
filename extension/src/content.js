import { parser, TIMELINE_SELECTOR, SIDEBAR_SELECTOR } from "parser";
import debounce from "lodash/debounce";

let running = false;
const sendAds = function() {
  if (running) return;
  running = true;
  let posts = Array.from(document.querySelectorAll(SIDEBAR_SELECTOR)).concat(
    Array.from(document.querySelectorAll(TIMELINE_SELECTOR))
  );

  let results = [];
  let scraper = posts.reduce(
    (p, i) =>
      p.then(() => {
        let timeout = new Promise(resolve =>
          setTimeout(() => resolve(false), 5000)
        );
        return Promise.race([
          parser(i).then(it => results.push(it), e => console.log(e)),
          timeout
        ]);
      }),
    Promise.resolve(null)
  );

  scraper.then(() => {
    let message = results.filter(i => i);
    chrome.runtime.sendMessage(message);
    running = false;
  });
};

// On Safari, document.body is null until the document has been loaded
document.addEventListener("DOMContentLoaded", function(event) {
  let f = debounce(sendAds, 5000);
  let mo = new MutationObserver(f);
  mo.observe(document.body, { childList: true, subtree: true });
  f(); // run immediately, don't wait for a mutation
});
