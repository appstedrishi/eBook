describe("Highlight", function () {
  var highlight, fakeHighlightRange, fakeHighlightNode;
  var pixelOffset = 125;
  var divHeight = 35;
  var index = 3;

  beforeEach(function() {
    fakeHighlightNode = {};
    fakeHighlightNode.offsetLeft = pixelOffset;
    fakeHighlightNode.offsetTop = pixelOffset;
    fakeHighlightNode.offsetHeight = divHeight;
    fakeHighlightNode.textContent = "some text";
    spyOn(document, 'createElement').andReturn(fakeHighlightNode);

    spyOn(Halo.NodeSerializer, 'serialize');

    fakeHighlightRange = jasmine.createSpyObj('range', ['surroundContents']);
    fakeHighlightRange.startContainer = { previousSibling: null, nodeType: Node.TEXT_NODE };
    fakeHighlightRange.startOffset = 0;
    fakeHighlightRange.endContainer = { previousSibling: null, nodeType: Node.TEXT_NODE };
    fakeHighlightRange.endOffset = 1;

    highlight = new Halo.Highlight(index, fakeHighlightRange);
  });

  describe("#addMarkup", function() {
    beforeEach(function() {
      highlight.addMarkup();
    });

    it("should create a highlight node", function() {
      expect(document.createElement).toHaveBeenCalledWith("div");
    });

    it("should insert the highlight node into the DOM, surrounding the specified range", function() {
      expect(fakeHighlightRange.surroundContents).toHaveBeenCalledWith(fakeHighlightNode);
    });
  });

  describe("#removeMarkup", function() {
    // Tested in highlighter-spec
  });

  describe("#index", function() {
    it("should return the specified index", function() {
      expect(highlight.index).toEqual(index);
    });
  });

  describe("#yOffset", function() {
    describe("before adding markup", function() {
      it("should throw an exception", function() {
        expect(function() { highlight.yOffset; }).toThrow();
      });
    });

    describe("after adding markup", function() {
      beforeEach(function() {
        highlight.addMarkup();
      });

      it("should return the vertical pixel offset of the highlight node from the top of the document", function() {
        expect(highlight.yOffset).toEqual(pixelOffset);
      });
    });
  });
		 
  describe("#xOffset", function() {
    describe("before adding markup", function() {
	  it("should throw an exception", function() {
				expect(function() { highlight.xOffset; }).toThrow();
			});
		});
				
		describe("after adding markup", function() {
			beforeEach(function() {
				highlight.addMarkup();
			});
				 
			it("should return the horizontal pixel offset of the highlight node from the left of the document", function() {
				expect(highlight.xOffset).toEqual(pixelOffset);
			});
		});
	});
		 
  describe("#height", function () {
    describe("before adding markup", function () {
      it("should throw an exception", function() {
        expect(function() { highlight.height; }).toThrow();
      });
    });

    describe("after adding markup", function () {
      beforeEach(function() {
        highlight.addMarkup();
      });

      it("should return height of the highlight node", function() {
        expect(highlight.height).toEqual(divHeight);
      });
    });
  });

  describe("#text", function() {
    var paragraphNode, highlightRange;

    beforeEach(function() {
      $.ajax({
        async:false,
        url:"Spec/Content/fixtures/highlight-sections.html",
        success: function(data) {
          $('#jasmine_content').html(data);
        }
      });

      paragraphNode = $("#section-1-1-para-1")[0];
      document.createElement.andReturn(paragraphNode);
      highlight = new Halo.Highlight(index, fakeHighlightRange);
    });

    describe("before adding markup", function() {
      it("should throw an exception", function() {
        expect(function() { highlight.text; }).toThrow();
      });
    });

    describe("after adding markup", function() {
      beforeEach(function() {
        highlight.addMarkup();
      });

      it("should return the selected text content with whitespace collapsed", function() {
        var expected = 'The promoter of a gene includes within it the transcription start point (the nucleotide where RNA synthesis actually begins) and typically extends several dozen nucleotide pairs "upstream" from the start point. In addition to serving as a binding site for RNA polymerase and ';
        expect(highlight.text).toEqual(expected);
      });
    });
  });

  describe("#section", function() {
    var paragraphNode;

    beforeEach(function() {
      $.ajax({
        async:false,
        url:"Spec/Content/fixtures/highlight-sections.html",
        success: function(data) {
          $('#jasmine_content').html(data);
        }
      });

      paragraphNode = $("#section-1-1-para-1")[0];
      document.createElement.andReturn(paragraphNode);
      highlight = new Halo.Highlight(index, fakeHighlightRange);
    });

    describe("before adding markup", function() {
      it("should throw an exception", function() {
        expect(function() { highlight.section; }).toThrow();
      });
    });

    describe("after adding markup", function() {
      beforeEach(function() {
        highlight.addMarkup();
      });

      it("should return the containing section id", function() {
        expect(highlight.section).toEqual('section1-1');
      });
    });
  });

  describe("#rangeJSON", function() {
    beforeEach(function() {
      Halo.NodeSerializer.serialize.andCallThrough();

      $.ajax({
        async:false,
        url:"Spec/Content/fixtures/ranges.html",
        success: function(data) {
          $('#jasmine_content').html(data);
        }
      });
    });

    describe("when the start container is a text node", function() {
      describe("and the start container has a previous sibling which is a highlighted element", function() {
        describe("and the highlighted element contains only text", function() {
          var $parent;
          var selectionStartOffset = 5;

          beforeEach(function() {
            $parent = $("#range-with-highlight-containing-only-text");
            var lastTextNode = $parent.contents().last()[0];
            expect(lastTextNode.nodeType).toEqual(Node.TEXT_NODE);

            var newSelectionRange = document.createRange();
            newSelectionRange.setStart(lastTextNode, selectionStartOffset);
            newSelectionRange.setEnd(lastTextNode, 7);
            highlight = new Halo.Highlight(1, newSelectionRange);
          });

          it("should add the length of the text nodes inside the highlight element, and any other previous sibling text nodes, to the start offset", function() {
            var expectedOffset = $parent[0].childNodes[0].textContent.length + $parent[0].childNodes[1].textContent.length + selectionStartOffset;
            expect($.parseJSON(highlight.rangeJSON).startOffset).toEqual(expectedOffset);
          });
        });

        describe("and the highlighted element contains text and an element", function() {
          var $parent;
          var selectionStartOffset = 5;

          beforeEach(function() {
            $parent = $("#range-with-highlight-containing-text-and-element");
            var lastTextNode = $parent.contents().last()[0];
            expect(lastTextNode.nodeType).toEqual(Node.TEXT_NODE);

            var newSelectionRange = document.createRange();
            newSelectionRange.setStart(lastTextNode, selectionStartOffset);
            newSelectionRange.setEnd(lastTextNode, 7);
            highlight = new Halo.Highlight(1, newSelectionRange);
          });

          it("should add the length of the text nodes inside the highlight element, and any other previous sibling text nodes, to the start offset", function() {
            var expectedOffset = $parent[0].childNodes[1].childNodes[2].textContent.length + selectionStartOffset;
            expect($.parseJSON(highlight.rangeJSON).startOffset).toEqual(expectedOffset);
          });
        });
      });

      describe("and the highlight range begins after a line break in the text node", function() {
        var $parent, expectedStartOffset, expectedEndOffset;

        beforeEach(function() {
          $parent = $('#paragraph-example-with-line-breaks');
          var textNode = $parent[0].childNodes[1].childNodes[14];

          expect(textNode.nodeType).toEqual(Node.TEXT_NODE);
          expect(textNode.textContent).toContain("3′ end of the");

          var selectionRange = document.createRange();
          expectedStartOffset = 2;
          expectedEndOffset = 30;

          selectionRange.setStart(textNode, expectedStartOffset);
          selectionRange.setEnd(textNode, expectedEndOffset);

          highlight = new Halo.Highlight(1, selectionRange);
        });

        it("should generate expected JSON for persistence", function() {
          expect($.parseJSON(highlight.rangeJSON).startOffset).toEqual(expectedStartOffset);
          expect($.parseJSON(highlight.rangeJSON).endOffset).toEqual(expectedEndOffset);
        });
      });

      describe("and the highlighted text is in a touchable span", function() {
        var parent, selectionRange;
        var startNode, endNode;

        beforeEach(function() {
          parent = $("#range-with-spans-inserted")[0];
          startNode = $("> p > span", parent)[0].firstChild;
          endNode = $("> p > span", parent)[3].firstChild;

          expect(startNode.nodeType).toEqual(Node.TEXT_NODE);
          expect(endNode.nodeType).toEqual(Node.TEXT_NODE);

          unwrapTextChildren($("> p", parent)[0]);

          selectionRange = document.createRange();
          selectionRange.setStart(startNode, 0);
          selectionRange.setEnd(endNode, endNode.textContent.length);

          highlight = new Halo.Highlight(1, selectionRange);
        });

        it("should create a highlight with the expected JSON", function() {
          var expectedOffset = selectionRange.cloneContents().textContent.length;
          expect($.parseJSON(highlight.rangeJSON).endOffset).toEqual(expectedOffset);
        });
      });
    });

    describe("when an element has been selected", function() {
      describe("and the selected element has a previous sibling which is a highlighted element", function() {
        beforeEach(function() {
          var $parent = $("#range-with-highlighted-element");
          var selectedElement = $("> p", $parent).last()[0];

          var newSelectionRange = document.createRange();
          newSelectionRange.selectNode(selectedElement);

          highlight = new Halo.Highlight(1, newSelectionRange);
        });

        it("should return the start offset of the selected node in the start container before any highlights were added", function() {
          var $parentBeforeHighlight = $("#range-before-highlight");
          var selectedElementBeforeHighlight = $("> p", $parentBeforeHighlight).last()[0];

          var expectedOffset = Halo.NodeIndexer.indexOfNodeInParent(selectedElementBeforeHighlight);
          expect($.parseJSON(highlight.rangeJSON).startOffset).toEqual(expectedOffset);
        });
      });
    });
  });

  describe("#toJSON", function() {
    var fromJSON;

    beforeEach(function() {
      delete highlight.section; highlight.section = 'a-section';
    });

    describe("before adding markup", function() {
      it("should throw an exception", function() {
        expect(function() { highlight.toJSON(); }).toThrow();
      });
    });

    describe("after adding markup", function() {
      beforeEach(function() {
        highlight.addMarkup();

        fromJSON = $.parseJSON(highlight.toJSON());
      });

      it("should return a JSON object that contains the range as a JSON string", function() {
        expect(fromJSON.rangeJSON).toEqual(jasmine.any(String));
      });

      it("should return a JSON object that contains the ID", function() {
        expect(fromJSON.id).toEqual(highlight.id);
      });

      it("should return a JSON object that contains the Y offset", function() {
        expect(fromJSON.yOffset).toEqual(pixelOffset);
      });
      
      it("should return a JSON object that contains the X offset", function() {
        expect(fromJSON.xOffset).toEqual(pixelOffset);
      });

      it("should return a JSON object that contains the text", function() {
        expect(fromJSON.text).toEqual(highlight.text);
      });

      it("should return a JSON object that contains the section", function() {
        expect(fromJSON.section).toEqual(highlight.section);
      });
    });
  });

  function unwrapTextChildren(paragraph) {
    $(".touchable", paragraph).contents().unwrap();
  }
});
