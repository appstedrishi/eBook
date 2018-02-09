describe("TouchEventHandler", function() {
  var highlighter, touchEventHandler;

  beforeEach(function() {
    loadFixtureDocument();

    highlighter = jasmine.createSpyObj('highlighter', ['beginHighlighting', 'createPersistentHighlightWithStartAndEndElements']);
    touchEventHandler = new Halo.TouchEventHandler(highlighter);
  });

  describe("touchesBeganAtPoint", function() {
    var $touchedElement;

    describe("when the point is inside a section paragraph", function() {
      beforeEach(function() {
        $touchedElement = $("#section2-1-1");

        var paragraphChild = $touchedElement.children()[0];
        expect(paragraphChild).toBeDefined();
        spyOn(document, 'elementFromPoint').andReturn(paragraphChild);
      });

      it("should return true", function() {
        expect(touchEventHandler.touchesBeganAtPoint(1, 2)).toEqual("true");
      });

      it("should add touchable spans inside the paragraph", function() {
        expect($(".touchable", $touchedElement).length).toEqual(0);
        touchEventHandler.touchesBeganAtPoint(1, 2);
        expect($(".touchable", $touchedElement).length).toBeGreaterThan(0);
      });

      it("should not change the text content of the paragraph", function() {
        var originalTextContent = $touchedElement.text().replace(/\s+/mg, ' ');
        touchEventHandler.touchesBeganAtPoint(1, 2);
        var newTextContent = $touchedElement.text().replace(/\s+/mg, ' ');
        expect(newTextContent).toEqual(originalTextContent);
      });
    });

    describe("when the point is not inside a paragraph", function() {
      beforeEach(function() {
        $touchedElement = $("#several-highlights");
        expect($touchedElement.closest("p")[0]).toBeUndefined();

        spyOn(document, 'elementFromPoint').andReturn($touchedElement);
      });

      it("should return false", function() {
        expect(touchEventHandler.touchesBeganAtPoint(1, 2)).toEqual("false");
      });

      it("should not add any touchable spans", function() {
        touchEventHandler.touchesBeganAtPoint(1, 2);
        expect($(".touchable").length).toEqual(0);
      });
    });
  });

  describe("startHighlightAtPoint", function() {
    var touchedParagraph;

    beforeEach(function() {
      touchedParagraph = $("#section2-1-1")[0];
      spyOn(document, 'elementFromPoint').andReturn(touchedParagraph);
      touchEventHandler.touchesBeganAtPoint(1, 2);
    });

    describe("when the touched element is a touchable", function() {
      var touchable;

      beforeEach(function() {
        touchable = $(".touchable", touchedParagraph)[0];
        document.elementFromPoint.andReturn(touchable);
      });

      it("should begin highlighting", function() {
        touchEventHandler.startHighlightAtPoint(1, 2);
        expect(highlighter.beginHighlighting).toHaveBeenCalled();
      });

      it("should return true", function() {
        expect(touchEventHandler.startHighlightAtPoint(1, 2)).toEqual("true");
      });
    });

    describe("when the touched element is not a touchable", function() {
      beforeEach(function() {
        expect($(document.elementFromPoint()).hasClass("touchable")).toBeFalsy();
      });

      it("should not begin highlighting", function() {
        touchEventHandler.startHighlightAtPoint(1, 2);
        expect(highlighter.beginHighlighting).not.toHaveBeenCalled();
      });

      it("should return false", function() {
        expect(touchEventHandler.startHighlightAtPoint(1, 2)).toEqual("false");
      });
    });
  });

  describe("touchesEnded", function() {
    var $touchedElement, touchedSpan;

    beforeEach(function() {
      $touchedElement = $("#section2-1-1");
      spyOn(document, 'elementFromPoint').andReturn($touchedElement[0]);
    });

    describe("when the user has not touched a touchable element", function() {
      beforeEach(function() {
        touchEventHandler.touchesBeganAtPoint(1, 2);
        expect($(".touchable").length).toBeGreaterThan(0);
        touchEventHandler.startHighlightAtPoint(1, 2);
        touchEventHandler.touchesEnded();
      });

      it("should not create a persistent highlight", function() {
        expect(highlighter.createPersistentHighlightWithStartAndEndElements).not.toHaveBeenCalled();
      });

      it("should unwrap the touchable spans", function() {
        expect($(".touchable").length).toEqual(0);
      });
    });

    describe("when the user has started and ended on touchable elements", function() {
      beforeEach(function() {
        highlighter = new Halo.Highlighter();
        touchEventHandler = new Halo.TouchEventHandler(highlighter);

        touchEventHandler.touchesBeganAtPoint(1, 2);
        touchedSpan = $(".touchable", $touchedElement[0])[0];
        document.elementFromPoint.andReturn(touchedSpan);
        touchEventHandler.startHighlightAtPoint(1, 2);
        touchEventHandler.updateHighlightFeedbackToPoint(1, 2);
      });

      it("should remove any touchable elements", function() {
        expect($(".touchable").length).toBeGreaterThan(0);
        touchEventHandler.touchesEnded();
        expect($(".touchable").length).toEqual(0);
      });

      it("should not change the text content of the paragraph", function() {
        var originalTextContent = $touchedElement.text().replace(/\s+/mg, ' ');
        touchEventHandler.touchesEnded();
        var newTextContent = $touchedElement.text().replace(/\s+/mg, ' ');
        expect(newTextContent).toEqual(originalTextContent);
      });

      it("should create a highlight", function() {
        spyOn(highlighter, 'createPersistentHighlightWithStartAndEndElements');
        touchEventHandler.touchesEnded();
        expect(highlighter.createPersistentHighlightWithStartAndEndElements).toHaveBeenCalled();
      });

      it("should NOT focus the created highlight", function() {
        touchEventHandler.touchesEnded();
        expect($('#' + highlighter.currentHighlight.id).hasClass('focused')).toBeFalsy();
      });
    });
  });

  describe("updateHighlightingFeedbackToPoint", function() {
    var $touchedElement, unhighlightableElement;
    var paragraphChild, touchable;

    beforeEach(function() {
      highlighter = new Halo.Highlighter();
      touchEventHandler = new Halo.TouchEventHandler(highlighter);

      $touchedElement = $("#section2-1-1");

      paragraphChild = $touchedElement.children()[0];
      unhighlightableElement = $touchedElement[0];

      expect(paragraphChild).toBeDefined();
      spyOn(document, 'elementFromPoint').andReturn(paragraphChild);
      spyOn(highlighter, 'createHighlightWithStartAndEndElements').andCallThrough();

      touchEventHandler.touchesBeganAtPoint(1, 2);

      touchable = $(".touchable", paragraphChild)[0];
      document.elementFromPoint.andReturn(touchable);
      touchEventHandler.startHighlightAtPoint(1, 2);
    });

    it("should not change the text content of the paragraph", function() {
      var originalTextContent = $touchedElement.text().replace(/\s+/mg, ' ');
      touchEventHandler.updateHighlightFeedbackToPoint(1, 2);
      var newTextContent = $touchedElement.text().replace(/\s+/mg, ' ');
      expect(newTextContent).toEqual(originalTextContent);
    });

    describe("when the touched point is a touchable", function() {
      it("should update the endElement and create the highlight", function() {
        touchEventHandler.updateHighlightFeedbackToPoint(1, 2);
        expect(highlighter.createHighlightWithStartAndEndElements).toHaveBeenCalled();
      });

      it("should focus the created highlight", function() {
        touchEventHandler.updateHighlightFeedbackToPoint(1, 2);
        expect($('#' + highlighter.currentHighlight.id).hasClass('focused')).toBeTruthy();
      });
    });

    describe("when the touched point is not a touchable", function() {
      beforeEach(function() {
        document.elementFromPoint.andReturn(unhighlightableElement);
        expect($(unhighlightableElement).hasClass('touchable')).toBeFalsy();
      });

      it("should do nothing", function() {
        touchEventHandler.updateHighlightFeedbackToPoint(3, 4);
        expect(highlighter.createHighlightWithStartAndEndElements).not.toHaveBeenCalled();
        expect(touchEventHandler.endElement).not.toEqual(unhighlightableElement);
      });
    });

    it("should add a temporary highlight from the touches began point to the current point", function() {
      touchEventHandler.updateHighlightFeedbackToPoint(1, 2);
      expect(highlighter.createHighlightWithStartAndEndElements).toHaveBeenCalledWith(touchable, touchable);
    });
  });

  function loadFixtureDocument() {
    $.ajax({
      async:false,
      url:"Spec/Content/fixtures/touch-event-handler.html",
      success: function(data) {
        $('#jasmine_content').html(data);
      }
    });
  }

});
