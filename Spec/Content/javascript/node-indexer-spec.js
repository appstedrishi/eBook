describe("Node", function() {
  beforeEach(function() {
    $.ajax({
      async:false,
      url:"Spec/Content/fixtures/ranges.html",
      success: function(data) {
        $('#jasmine_content').empty().append($(data));
      }
    });
  });

  describe(".fixedOffsetForNodeInParentWithoutHighlights", function() {
    var touchEventHandler, highlighter;

    beforeEach(function() {
      highlighter = jasmine.createSpy('highlighter');
      touchEventHandler = new Halo.TouchEventHandler(highlighter);
    });

    describe("when the DOM node does not have a previous sibling which is a highlight element", function() {
      var domNode, parent;

      beforeEach(function() {
        parent = $("#range-before-highlight")[0];
        expect(parent).toBeDefined();

        domNode = $("> p", parent)[1];
        expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);
      });

      describe("when the content is not wrapped in touchable spans", function() {
        it("should return the passed-in offset", function() {
          expect(Halo.NodeIndexer.fixedOffsetForNodeInParentWithoutHighlights(parent, 1)).toEqual(1);
        });
      });

      describe("when the content has been wrapped in touchable spans", function() {
        beforeEach(function() {
          parent = $("#range-with-spans-inserted")[0];
          domNode = $("> p", parent)[0];
          expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);
        });

        it("should return the original offset", function() {
          expect(Halo.NodeIndexer.fixedOffsetForNodeInParentWithoutHighlights(domNode, 0)).toEqual(0);
          expect(Halo.NodeIndexer.fixedOffsetForNodeInParentWithoutHighlights(domNode, 1)).toEqual(0);
          expect(Halo.NodeIndexer.fixedOffsetForNodeInParentWithoutHighlights(domNode, 2)).toEqual(0);
          expect(Halo.NodeIndexer.fixedOffsetForNodeInParentWithoutHighlights(domNode, 3)).toEqual(0);
          expect(Halo.NodeIndexer.fixedOffsetForNodeInParentWithoutHighlights(domNode, 5)).toEqual(0);
        });
      });

      describe("when the DOM node has a previous sibling which is a highlight element", function() {
        var domNode, parent;

        beforeEach(function() {
          parent = $('#range-with-previous-highlight')[0];
          expect(parent).toBeDefined();

          domNode = $("> p", parent)[1];
          expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);
        });

        it("should return a correct offset irrespective of previously highlighted elements", function() {
          spyOn(document, 'elementFromPoint').andReturn(domNode);
          touchEventHandler.touchesBeganAtPoint(1,2);
          //unwrapTextChildren()
          $(".touchable", domNode).contents().unwrap();

          expect(Halo.NodeIndexer.fixedOffsetForNodeInParentWithoutHighlights(domNode, 6)).toEqual(0);
        });
      });
    });
  });

  describe(".indexOfNodeInParentWithoutHighlights", function() {
    describe("when the DOM node does not have a previous sibling which is a highlight element", function() {
      var domNode;

      beforeEach(function() {
        var parent = $("#range-before-highlight")[0];
        expect(parent).toBeDefined();

        domNode = $("> p", parent)[0];
        expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);
      });

      it("should return the index of the DOM node in its parent's children", function() {
        expect(Halo.NodeIndexer.indexOfNodeInParentWithoutHighlights(domNode)).toEqual(Halo.NodeIndexer.indexOfNodeInParent(domNode));
      });
    });

    describe("when the DOM node has a previous sibling which is a highlight element", function() {
      var domNode;

      beforeEach(function() {
        var parent = $("#range-with-highlighted-element")[0];
        expect(parent).toBeDefined();

        domNode = $("> p", parent).last()[0];
        expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);
      });

      it("should return the *original* index of the DOM node in its parent's children, before the highlight was added", function() {
        var parentBeforeHighlight = $("#range-before-highlight");
        var domNodeBeforeHighlight = $("> p", parentBeforeHighlight).last()[0];

        expect(Halo.NodeIndexer.indexOfNodeInParentWithoutHighlights(domNode)).toEqual(Halo.NodeIndexer.indexOfNodeInParent(domNodeBeforeHighlight));
      });
    });

    describe("when the DOM node has a previous sibling which is a highlight element which has split a text node at its start", function() {
      var domNode;

      beforeEach(function() {
        var parent = $("#range-with-highlight-splitting-text-at-start")[0];
        expect(parent).toBeDefined();

        domNode = $("> p", parent).last()[0];
        expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);
      });

      it("should return the *original* index of the DOM node in its parent's children, before the highlight was added", function() {
        var parentBeforeHighlight = $("#range-before-highlight");
        var domNodeBeforeHighlight = $("> p", parentBeforeHighlight).last()[0];

        expect(Halo.NodeIndexer.indexOfNodeInParentWithoutHighlights(domNode)).toEqual(Halo.NodeIndexer.indexOfNodeInParent(domNodeBeforeHighlight));
      });
    });

    describe("when the DOM node has a previous sibling which is a highlight element which has split a text node at its end", function() {
      var domNode;

      beforeEach(function() {
        var parent = $("#range-with-highlight-splitting-text-at-end")[0];
        expect(parent).toBeDefined();

        domNode = $("> p", parent).last()[0];
        expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);
      });

      it("should return the *original* index of the DOM node in its parent's children, before the highlight was added", function() {
        var parentBeforeHighlight = $("#range-before-highlight");
        var domNodeBeforeHighlight = $("> p", parentBeforeHighlight).last()[0];

        expect(Halo.NodeIndexer.indexOfNodeInParentWithoutHighlights(domNode)).toEqual(Halo.NodeIndexer.indexOfNodeInParent(domNodeBeforeHighlight));
      });
    });

    describe("when the DOM node has a previous sibling which is a highlight element which has split text nodes at its start and end", function() {
      var domNode;

      beforeEach(function() {
        var parent = $("#range-with-highlight-splitting-text-at-start-and-end")[0];
        expect(parent).toBeDefined();

        domNode = $("> p", parent).last()[0];
        expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);
      });

      it("should return the *original* index of the DOM node in its parent's children, before the highlight was added", function() {
        var parentBeforeHighlight = $("#range-before-highlight");
        var domNodeBeforeHighlight = $("> p", parentBeforeHighlight).last()[0];

        expect(Halo.NodeIndexer.indexOfNodeInParentWithoutHighlights(domNode)).toEqual(Halo.NodeIndexer.indexOfNodeInParent(domNodeBeforeHighlight));
      });
    });

    describe("when the DOM node has a previous sibling which is a split text node", function() {
      var domNode;
      var originalOffset;

      beforeEach(function() {
        var parent = $("#range-before-highlight")[0];
        expect(parent).toBeDefined();

        domNode = $("> p > span", parent)[0];
        expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);

        originalOffset = Halo.NodeIndexer.indexOfNodeInParent(domNode);

        // The only way to split a text node is to insert an element inside
        // it, then remove the element.
        var textNode = domNode.previousSibling;
        expect(textNode.nodeType).toEqual(Node.TEXT_NODE);

        var range = document.createRange();
        range.setStart(textNode, 1);
        range.setEnd(textNode, 3);

        var splittingElement = document.createElement("span");
        splittingElement.id = "splitting";

        range.surroundContents(splittingElement);
        $(splittingElement).contents().unwrap();
      });

      it("should return the *original* index of the DOM node in its parent's children, before the text node split", function() {
        expect(Halo.NodeIndexer.indexOfNodeInParentWithoutHighlights(domNode)).toEqual(originalOffset);
      });
    });

    describe("when the DOM node is a split text node", function() {
      var textNode;
      var originalOffset;

      beforeEach(function() {
        var parent = $("#range-before-highlight")[0];
        expect(parent).toBeDefined();

        textNode = $("> p > span", parent).parent().contents()[0];
        expect(textNode.nodeType).toEqual(Node.TEXT_NODE);

        originalOffset = Halo.NodeIndexer.indexOfNodeInParent(textNode);

        // The only way to split a text node is to insert an element inside
        // it, then remove the element.
        var range = document.createRange();
        range.setStart(textNode, 1);
        range.setEnd(textNode, 3);

        var splittingElement = document.createElement("span");
        splittingElement.id = "splitting";

        range.surroundContents(splittingElement);
        $(splittingElement).contents().unwrap();

        // Re-get the textNode, since the current pointer is pointing at the original unsplit text node.
        textNode = $("> p > span", parent).parent().contents()[2];
      });

      it("should set the childOffset attribute on the root object to be the *original* index of the DOM node in its parent's children, before the text node split", function() {
        expect(Halo.NodeIndexer.indexOfNodeInParentWithoutHighlights(textNode)).toEqual(originalOffset);
      });
    });
  });
});
