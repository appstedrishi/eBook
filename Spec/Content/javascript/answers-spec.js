describe("Answers", function () {

  beforeEach(function() {
    loadFixtureDocument();
    Halo.answers.init();
  });

  describe("on load", function() {
    it("should hide the #minusButton and #detail divs", function() {
      expect($('#minusButton').css('display')).toEqual('none');
      expect($('#detail').css('display')).toEqual('none');
    });
  });

  describe("clicking the #plusButton", function() {
    beforeEach(function() {
      $('#plusButton').trigger('touchend');
    });

    it("should hide the #plusButton and #summary divs", function() {
      expect($('#plusButton').css('display')).toEqual('none');
      expect($('#summary').css('display')).toEqual('none');
    });

    it("should show the #minusButton and #detail divs", function() {
      expect($('#minusButton').css('display')).not.toEqual('none');
      expect($('#detail').css('display')).not.toEqual('none');
    });
  });

  describe("clicking the #minusButton button", function() {
    beforeEach(function() {
      $('#plusButton').trigger('touchend');
      $('#minusButton').trigger('touchend');
    });

    it("should show the #plusButton and #summary divs", function() {
      expect($('#plusButton').css('display')).not.toEqual('none');
      expect($('#summary').css('display')).not.toEqual('none');
    });

    it("should hide the #minusButton and #detail divs", function() {
      expect($('#minusButton').css('display')).toEqual('none');
      expect($('#detail').css('display')).toEqual('none');
    });
  });

  function loadFixtureDocument() {
    $.ajax({
      async:false,
      url:"Spec/Content/fixtures/answer-page.html",
      success: function(data) {
        $('#jasmine_content').html(data);
      }
    });
  }
});

