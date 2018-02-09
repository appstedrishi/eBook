describe("NodeSerializer", function() {
  beforeEach(function() {
    $.ajax({
      async:false,
      url:"Spec/Content/fixtures/ranges.html",
      success: function(data) {
        $('#jasmine_content').html(data);
      }
    });
  });

  describe("serialize", function() {
    var serialized;

    describe("when the first parent with an ID contains no highlights", function() {
      var id = "range-before-highlight";

      describe("when the DOM node is an element with an ID", function() {
        beforeEach(function() {
          var domNode = $("#" + id)[0];
          expect(domNode).toBeDefined();

          serialized = Halo.NodeSerializer.serialize(domNode);
        });

        it("should return an object that specifies that ID", function() {
          expect(serialized.id).toEqual(id);
        });

        it("should have no parent element", function() {
          expect(serialized.parentElement).not.toBeDefined();
        });
      });

      describe("when the DOM node's parent has an ID", function() {
        var domNode, parent;

        beforeEach(function() {
          parent = $("#" + id)[0];
          expect(parent).toBeDefined();

          domNode = $("> p", parent)[0];
          expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);

          serialized = Halo.NodeSerializer.serialize(domNode);
        });

        it("should not set the ID on the root object", function() {
          expect(serialized.id).not.toBeDefined();
        });

        it("should set a parentElement on the root object", function() {
          expect(serialized.parentElement).toEqual(jasmine.any(Object));
        });

        it("should set the ID attribute on the parentElement object to the parent ID", function() {
          expect(serialized.parentElement.id).toEqual(id);
        });

        it("should set the childOffset attribute on the root object to be the index of the DOM node in its parent's children", function() {
          expect(serialized.childOffset).toEqual(Halo.NodeIndexer.indexOfNodeInParent(domNode));
        });
      });

      describe("when the DOM node is a text element", function() {
        var parent, textNode;

        beforeEach(function() {
          parent = $("#" + id + " > p")[0];
          expect(parent).toBeDefined();

          textNode = parent.childNodes[0];
          expect(textNode.nodeType).toEqual(Node.TEXT_NODE);

          serialized = Halo.NodeSerializer.serialize(textNode);
        });

        it("should not set the ID on the root object", function() {
          expect(serialized.id).not.toBeDefined();
        });

        it("should set the childOffset attribute on the root object to be the index of the DOM node in its parent's children", function() {
          expect(serialized.childOffset).toEqual(Halo.NodeIndexer.indexOfNodeInParent(textNode));
        });
      });
    });

    describe("when the first parent with an ID contains a highlight element", function() {
      var id = "range-with-highlighted-element";

      describe("when the DOM node is an element with an ID", function() {
        beforeEach(function() {
          var domNode = $("#" + id)[0];
          expect(domNode).toBeDefined();

          serialized = Halo.NodeSerializer.serialize(domNode);
        });

        // TODO: <shared>
        it("should return an object that specifies that ID", function() {
          expect(serialized.id).toEqual(id);
        });

        it("should have no parent element", function() {
          expect(serialized.parentElement).not.toBeDefined();
        });
        // TODO: </shared>
      });

      describe("when the DOM node has a previous sibling which is a highlight element", function() {
        var domNode, parent;

        beforeEach(function() {
          parent = $("#" + id)[0];
          expect(parent).toBeDefined();

          domNode = $("> p", parent).last()[0];
          expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);

          serialized = Halo.NodeSerializer.serialize(domNode);
        });

        // TODO: <shared>
        it("should not set the ID on the root object", function() {
          expect(serialized.id).not.toBeDefined();
        });

        it("should set a parentElement on the root object", function() {
          expect(serialized.parentElement).toEqual(jasmine.any(Object));
        });

        it("should set the ID attribute on the parentElement object to the parent ID", function() {
          expect(serialized.parentElement.id).toEqual(id);
        });
        // TODO: </shared>

        it("should set the childOffset attribute on the root object to be the *original* index of the DOM node in its parent's children, before the highlight was added", function() {
          var parentBeforeHighlight = $("#range-before-highlight");
          var domNodeBeforeHighlight = $("> p", parentBeforeHighlight).last()[0];

          expect(serialized.childOffset).toEqual(Halo.NodeIndexer.indexOfNodeInParent(domNodeBeforeHighlight));
        });
      });
    });

    describe("when the first parent with an ID contains highlighted text", function() {
      describe("when the DOM node has a previous sibling which is a highlight element which has split a text node at its start", function() {
        var id = "range-with-highlight-splitting-text-at-start";
        var domNode, parent;

        beforeEach(function() {
          parent = $("#" + id)[0];
          expect(parent).toBeDefined();

          domNode = $("> p", parent).last()[0];
          expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);

          serialized = Halo.NodeSerializer.serialize(domNode);
        });

        it("should set the childOffset attribute on the root object to be the *original* index of the DOM node in its parent's children, before the highlight was added, taking into account the split text node", function() {
          var parentBeforeHighlight = $("#range-before-highlight");
          var domNodeBeforeHighlight = $("> p", parentBeforeHighlight).last()[0];

          expect(serialized.childOffset).toEqual(Halo.NodeIndexer.indexOfNodeInParent(domNodeBeforeHighlight));
        });
      });

      describe("when the DOM node has a previous sibling which is a highlight element which has split a text node at its end", function() {
        var id = "range-with-highlight-splitting-text-at-end";
        var domNode, parent;

        beforeEach(function() {
          parent = $("#" + id)[0];
          expect(parent).toBeDefined();

          domNode = $("> p", parent).last()[0];
          expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);

          serialized = Halo.NodeSerializer.serialize(domNode);
        });

        it("should set the childOffset attribute on the root object to be the *original* index of the DOM node in its parent's children, before the highlight was added, taking into account the split text node", function() {
          var parentBeforeHighlight = $("#range-before-highlight");
          var domNodeBeforeHighlight = $("> p", parentBeforeHighlight).last()[0];

          expect(serialized.childOffset).toEqual(Halo.NodeIndexer.indexOfNodeInParent(domNodeBeforeHighlight));
        });
      });

      describe("when the DOM node has a previous sibling which is a highlight element which has split text nodes at its start and end", function() {
        var id = "range-with-highlight-splitting-text-at-start-and-end";
        var domNode, parent;

        beforeEach(function() {
          parent = $("#" + id)[0];
          expect(parent).toBeDefined();

          domNode = $("> p", parent).last()[0];
          expect(domNode.nodeType).toEqual(Node.ELEMENT_NODE);

          serialized = Halo.NodeSerializer.serialize(domNode);
        });

        it("should set the childOffset attribute on the root object to be the *original* index of the DOM node in its parent's children, before the highlight was added, taking into account the split text node", function() {
          var parentBeforeHighlight = $("#range-before-highlight");
          var domNodeBeforeHighlight = $("> p", parentBeforeHighlight).last()[0];

          expect(serialized.childOffset).toEqual(Halo.NodeIndexer.indexOfNodeInParent(domNodeBeforeHighlight));
        });
      });
    });

    describe("when the first parent with an ID contains a split text node", function() {
      describe("when the DOM node has a previous sibling which is a split text node", function() {
        var id = "range-before-highlight";
        var domNode, parent;
        var originalOffset;

        beforeEach(function() {
          parent = $("#" + id)[0];
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

          serialized = Halo.NodeSerializer.serialize(domNode);
        });

        it("should set the childOffset attribute on the root object to be the *original* index of the DOM node in its parent's children, before the text node split", function() {
          expect(serialized.childOffset).toEqual(originalOffset);
        });
      });

      describe("when the DOM node is a split text node", function() {
        var id = "range-before-highlight";
        var textNode, parent;
        var originalOffset;

        beforeEach(function() {
          parent = $("#" + id)[0];
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
          serialized = Halo.NodeSerializer.serialize(textNode);
        });

        it("should set the childOffset attribute on the root object to be the *original* index of the DOM node in its parent's children, before the text node split", function() {
          expect(serialized.childOffset).toEqual(originalOffset);
        });
      });
    });
  });

  describe("deserialize", function() {
    var original, deserialized;

    describe("when the first parent with an ID contains no highlights", function() {
      var id = "range-before-highlight";

      describe("when the DOM node is an element with an ID", function() {
        beforeEach(function() {
          original = $("#" + id)[0];
          expect(original).toBeDefined();

          var serialized = Halo.NodeSerializer.serialize(original);
          deserialized = Halo.NodeSerializer.deserialize(serialized);
        });

        it("should return the original element", function() {
          expect(deserialized).toEqual(original);
        });
      });

      describe("when the DOM node's parent has an ID", function() {
        var parent;

        beforeEach(function() {
          parent = $("#" + id)[0];
          expect(parent).toBeDefined();

          original = $("> p", parent)[0];
          expect(original.nodeType).toEqual(Node.ELEMENT_NODE);

          var serialized = Halo.NodeSerializer.serialize(original);
          deserialized = Halo.NodeSerializer.deserialize(serialized);
        });

        it("should return the original element", function() {
          expect(deserialized).toEqual(original);
        });
      });

      describe("when the DOM node is a text element", function() {
        var parent;

        beforeEach(function() {
          parent = $("#" + id + " > p")[0];
          expect(parent).toBeDefined();

          original = parent.childNodes[0];
          expect(original.nodeType).toEqual(Node.TEXT_NODE);

          var serialized = Halo.NodeSerializer.serialize(original);
          deserialized = Halo.NodeSerializer.deserialize(serialized);
        });

        it("should return the original element", function() {
          expect(deserialized).toEqual(original);
        });
      });
    });
  });
});
