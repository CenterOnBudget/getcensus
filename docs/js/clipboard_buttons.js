/* adapted from https://github.com/r-lib/pkgdown/blob/master/inst/assets/BS4/pkgdown.js */

if(Clipboard.isSupported()) {
  $(document).ready(function() {
    var copyButton = "<button type='button' class='btn btn-primary btn-copy-ex' title='Copy to clipboard' aria-label='Copy to clipboard' data-toggle='tooltip' data-trigger='hover' data-clipboard-copy><i class='glyphicon glyphicon-copy'></i></button>";
    
    $("pre").addClass("hasCopyButton");

    // Insert copy buttons:
    $(copyButton).prependTo(".hasCopyButton");

    // Initialize clipboard:
    var clipboardBtnCopies = new Clipboard('[data-clipboard-copy]', {
      text: function(trigger) {
        return trigger.parentNode.textContent;
      }
    });
  });
}
