// ==UserScript==
// @name        ChatJax
// @namespace   http://stackexchange.com/
// @description Rendering ChatJax
// @include     http://chat.stackexchange.com/*
// @author      Bass
// @license     Beerware
// @version     1
// @grant       GM_addStyle
// ==/UserScript==

function main() {
  window.doChatJax = function () {
    window.setTimeout(doChatJax, 2000);
    window.MathJax.Hub.Queue(['Typeset',window.MathJax.Hub]);
  };
  if (window.MathJax === undefined) {
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = 'https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_HTML';
    var config = 'MathJax.Hub.Config({' + 'extensions: ["tex2jax.js"],' + 'tex2jax: { inlineMath: [["$","$"],["\\\\\\\\\\\\(","\\\\\\\\\\\\)"]], displayMath: [["$$","$$"],["\\\\[","\\\\]"]], processEscapes: true },' + 'jax: ["input/TeX","output/HTML-CSS"]' + '});' + 'MathJax.Hub.Startup.onload();';
    if (window.opera) {
      script.innerHTML = config
    } else {
      script.text = config
    }
    document.getElementsByTagName('head') [0].appendChild(script);
    window.setTimeout(doChatJax, 500);
  }
};
var script = document.createElement('script');
script.appendChild(document.createTextNode('('+ main +')();'));
(document.body || document.head || document.documentElement).appendChild(script);