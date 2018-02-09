var nsBridge = function() {
  var self = {};

  var $nsbridge = getBridgeElement();

  self.init = function() {
    self.sendEvent('webviewready');
  };

  self.sendEvent = function(scheme, resource, id, action) {
    $nsbridge = getBridgeElement();
    $nsbridge.attr("href", scheme + '://' + ['device', resource, id, action].join('/'));
    var event = document.createEvent('HTMLEvents');
    event.initEvent('click');
    $nsbridge[0].dispatchEvent(event);
  };

  return self;

  function getBridgeElement() {
    var $nsbridge = $("#nsbridge");
    if (!$nsbridge.length) {  // check for and insert element each time in case was previously removed
      $(document.body).append('<a id="nsbridge" style="display: none" onclick="">nsbridge</a>');
      $nsbridge = $("#nsbridge");
      if (!window.navigator.appVersion.match(/ipad/gi) || window.navigator.appVersion.match(/safari/gi)) {
        $nsbridge.click(function() {
          return false;
        });
      }
    }
    return $nsbridge;
  }
}();

$(document).ready(function() {
  nsBridge.init();
});
