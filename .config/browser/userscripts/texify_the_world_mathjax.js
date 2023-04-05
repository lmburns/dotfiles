// ==UserScript==
// @name       TeXify the World MathJax
// @namespace  
// @version    1.0
// @description Enables MathJax to process LaTeX on all websites. Based off SOUP (Stack Overflow Unofficial Patch) and http://www.math.ucla.edu/~robjohn/math/mathjax.html.
// @include *
// @copyright
// ==/UserScript==
/*
var mathjaxVersion = "http://cdn.mathjax.org";
if ('https:' === location.protocol) {
    var mjs = $('script[src^="http://cdn.mathjax.org/"]').remove();
    var mjEncrypt = "https://c328740.ssl.cf1.rackcdn.com";
    if (mjs.length > 0) $.ajax( {
        dataType: "script", cache: true,
        url: mjs[0].src.replace(mathjaxVersion, mjEncrypt)
    } );
    mathjaxVersion = mjEncrypt;    
    console.log("https");
}*/

var script = document.createElement("script");
script.type = "text/javascript";
script.src = "//cdn.mathjax.org/mathjax/latest/MathJax.js" //(mathjaxVersion + "/mathjax/latest/MathJax.js?config=TeX-AMS_HTML");
var config = 'MathJax.Hub.Config({ ' + 'extensions: ["tex2jax.js"], ' + 'tex2jax: { skipTags: ["script","noscript","style","textarea"],inlineMath: [ ["[;", ";]"], ["$$","$$"]], displayMath: [["[(;",";)]"]], processEscapes: true }, ' + 'jax: ["input/TeX", "output/HTML-CSS"] ' + ' }); ' + 'MathJax.Hub.Startup.onload();';
config += 'function reMathJax() {"use strict"; MathJax.Hub.Queue(["Typeset", MathJax.Hub]);}'
config += 'var mathJaxIntervalId; window.onload = window.onfocus = function(){ mathJaxIntervalId = setInterval(reMathJax, 5000); }; window.onblur = function(){ clearInterval(mathJaxIntervalId) };'
script.text = config;
document.getElementsByTagName("head")[0].appendChild(script);
console.log("The TeX-ification is complete!");