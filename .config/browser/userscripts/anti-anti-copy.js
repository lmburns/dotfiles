// ==UserScript==
// @name        anti-anti-copy
// @description some websites prevent you from copying text. this script bypass it.
// @namespace   https://greasyfork.org
// @include     http://www.studytonight.com/*
// @version     0.1
// @grant       none
// @run-at      document-end
// ==/UserScript==

document.onselectstart = function(){return true;};
if(window.sidebar)
{
    document.onmousedown = document.onclick = function(){return true;};
}
window.onkeydown = function(){return true;};
