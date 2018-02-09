describe("nsBridge", function () {
  var $nsbridge;

  beforeEach(function() {
    $nsbridge = $('#nsbridge')[0];
    spyOn($nsbridge, 'dispatchEvent');
  });

  describe("init", function() {
    it("should send an event with scheme 'webviewready'", function() {

      nsBridge.init();

      expect($nsbridge.dispatchEvent).toHaveBeenCalled();
      expect($nsbridge.dispatchEvent.mostRecentCall.args[0].type).toEqual('click');
      expect($nsbridge.href).toEqual('webviewready://device///');
    });
  });

  describe("sendEvent", function () {
    it("should dispatch an event with the passed-in parameters", function() {
      nsBridge.sendEvent('testscheme', 'testresource', 'testid', 'testaction');

      expect($nsbridge.dispatchEvent).toHaveBeenCalled();
      expect($nsbridge.dispatchEvent.mostRecentCall.args[0].type).toEqual('click');
      expect($nsbridge.href).toEqual('testscheme://device/testresource/testid/testaction');
    });

    it("should add the #nsbridge element back in to the DOM if removed", function() {
      $('#nsbridge').remove();

      nsBridge.sendEvent('testscheme', 'testresource', 'testid', 'testaction');

      $nsbridge = $('#nsbridge')[0];
      expect($nsbridge).toBeDefined();
    });
  }); 
});