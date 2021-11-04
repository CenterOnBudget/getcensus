/* open external links in new tab
   from https://github.com/rstudio/rmarkdown/blob/gh-pages/js/external-links.js 
   see also https://yihui.org/en/2018/09/target-blank/
*/

(function() {
  var links = document.getElementsByTagName('a');
  for (var i = 0; i < links.length; i++) {
    if (/^(https?:)?\/\//.test(links[i].getAttribute('href'))) links[i].target = '_blank';
  }
})();