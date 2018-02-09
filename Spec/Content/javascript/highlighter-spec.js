describe("Highlighter", function () {
  var highlighter;

  beforeEach(function() {
    loadFixtureDocument();
    highlighter = new Halo.Highlighter();
    spyOn(document, 'getSelection');
  });

  describe("beginHighlighting", function() {
    beforeEach(function() {
      // Current highlight needs to be non-null.
      var textNode = document.getElementById("para07").firstChild;
      var range = document.createRange();
      range.setStart(textNode, 2);
      range.setEnd(textNode, 9);
      setSelectionRange(range);
      highlighter.highlightSelection();
      expect(highlighter.currentHighlight).toBeTruthy();
    });

    it("should set the current highlight to null", function() {
      highlighter.beginHighlighting();
      expect(highlighter.currentHighlight).toBeNull();
    });
  });

  describe("#createPersistentHighlightWithStartAndEndElements", function() {
    var paragraph;

    beforeEach(function() {
      paragraph = document.getElementById("para07-with-spans");
      expect(paragraph).toBeDefined();
    });

    describe("with no current highlight", function() {
      var startElement, endElement, expectedText;

      describe("when the user starts and ends on touchable elements", function() {
        describe("when the start element and end element are sibling elements", function() {
          beforeEach(function() {
            startElement = $(".touchable", paragraph)[0];
            endElement = $(".touchable", paragraph)[1];

            expectedText = startElement.textContent + endElement.textContent;

            highlighter.createPersistentHighlightWithStartAndEndElements(startElement, endElement);
          });

          it("should create a highlight with the expected range", function() {
            var highlight = $("#highlight-0", paragraph)[0];
            expect(highlight.textContent).toEqual(expectedText);
          });
        });

        describe("when the user starts outside an existing sub-element and ends inside the element", function() {
          beforeEach(function() {
            startElement = $(".touchable", paragraph)[1];
            endElement = $(".touchable", ".emphasis", paragraph)[0];

            expectedText = startElement.textContent + $(".emphasis", paragraph).text().replace(/\s+/mg, ' ');

            highlighter.createPersistentHighlightWithStartAndEndElements(startElement, endElement);
          });

          it("should create a highlight with the expected range", function() {
            var highlight = $("#highlight-0", paragraph)[0];
            expect(highlight.textContent.replace(/\s+/mg, ' ')).toEqual(expectedText);
          });
        });

        describe("when the user starts inside an existing sub-element and ends outside the element", function() {
          beforeEach(function() {
            startElement = $(".touchable", ".emphasis", paragraph)[1];
            endElement = $(".touchable", paragraph)[4];

            expectedText = $(".emphasis", paragraph).text() + endElement.textContent;

            highlighter.createPersistentHighlightWithStartAndEndElements(startElement, endElement);
          });

          it("should highlight the expected text", function() {
            var highlight = $("#highlight-0", paragraph)[0];
            expect(highlight.textContent.replace(/\s+/mg, ' ')).toEqual(expectedText.replace(/\s+/mg, ' '));
          });
        });

        describe("when the end element occurs before the start element", function() {
          beforeEach(function() {
            startElement = $(".touchable")[1];
            endElement = $(".touchable")[0];
          });

          it("should swap the start and end elements and create a highlight", function() {
            var range = document.createRange();

            spyOn(range, 'setStartBefore').andCallThrough();
            spyOn(range, 'setEndAfter').andCallThrough();
            spyOn(document, 'createRange').andReturn(range);

            highlighter.createPersistentHighlightWithStartAndEndElements(startElement, endElement);
            expect(range.setStartBefore).toHaveBeenCalledWith(endElement);
            expect(range.setEndAfter).toHaveBeenCalledWith(startElement);
          });
        });
      });
    });
  });

  describe("#createHighlightWithStartAndEndElements", function () {
    var paragraph;

    beforeEach(function() {
      paragraph = document.getElementById("para07-with-spans");
    });

    describe("with a current highlight", function() {
      var startElement, endElement, firstHighlightIndex;

      beforeEach(function() {
        startElement = $(".touchable")[0];
        endElement = $(".touchable")[1];

        highlighter.createHighlightWithStartAndEndElements(startElement, endElement);
        firstHighlightIndex = highlighter.currentHighlight.index;
      });

      it("should reuse the index of the current highlight", function() {
        highlighter.createHighlightWithStartAndEndElements(startElement, endElement);
        expect(highlighter.currentHighlight.index).toEqual(firstHighlightIndex);
      });

      it("should remove the previous highlight markup", function() {
        spyOn(highlighter, 'removeHighlight');
        highlighter.createHighlightWithStartAndEndElements(startElement, endElement);
        expect(highlighter.removeHighlight).toHaveBeenCalledWith(firstHighlightIndex);
      });
    });

    describe("with no current highlight", function() {
      var startElement, endElement, firstHighlightIndex;

      beforeEach(function() {
        startElement = $(".touchable")[0];
        endElement = $(".touchable")[1];

        highlighter.createHighlightWithStartAndEndElements(startElement, endElement);
        firstHighlightIndex = highlighter.currentHighlight.index;

        // Set current highlight to null.
        highlighter.beginHighlighting();
      });

      it("should assign a unique index to a new highlight", function() {
        highlighter.createHighlightWithStartAndEndElements(startElement, endElement);

        expect(highlighter.currentHighlight.index).not.toEqual(firstHighlightIndex);
      });
    });

    describe("when the selection start element is a child of a sub-element", function () {
      var subElement, startElement, endElement;

      beforeEach(function() {
        subElement = $(".emphasis", paragraph)[0];
        startElement = $(".touchable", subElement)[0];
        endElement = $(subElement).next(".touchable")[0];
      });

      it("should wrap the selected text, including the entire sub-element, in a div.highlighted element", function() {
        highlighter.createHighlightWithStartAndEndElements(startElement, endElement);
        expect($("#highlight-0", paragraph)[0].innerText).toEqual("inner text middle");
      });
    });

    describe("when the selection end element is a child of a sub-element", function () {
      var subElement, startElement, endElement

      beforeEach(function() {
        subElement = $(".emphasis", paragraph)[0];
        endElement = $(".touchable", subElement)[0];
        startElement = $(subElement).prev(".touchable")[0];
      });

      it("should wrap the selected text, including the entire sub-element, in a div.highlighted element", function() {
        highlighter.createHighlightWithStartAndEndElements(startElement, endElement);

        expect($("#highlight-0", paragraph)[0].innerText).toEqual("text inner text");
      });
    });

    describe("when the selection start node and end node are children of different sub-elements", function () {
      var startSubElement, endSubElement, startElement, endElement;

      beforeEach(function() {
        startSubElement = $(".emphasis", paragraph)[0];
        endSubElement = $(".emphasis2", paragraph)[0];
        startElement = $(".touchable", startSubElement)[0];
        endElement = $(".touchable", endSubElement)[0];
      });

      it("should wrap the selected text, including the entirety of both sub-elements and everything in between, in a div.highlighted element", function() {
        highlighter.createHighlightWithStartAndEndElements(startElement, endElement);

        expect($("#highlight-0", paragraph)[0].innerText).toEqual("inner text middle text inner text 2");
      });
    });

    describe("when the end element occurs before the start element", function() {
      var startElement, endElement;

      beforeEach(function() {
        startElement = $(".touchable")[1];
        endElement = $(".touchable")[0];
      });

      it("should swap the start and end elements and create a highlight", function() {
        var range = document.createRange();

        spyOn(range, 'setStartBefore').andCallThrough();
        spyOn(range, 'setEndAfter').andCallThrough();
        spyOn(document, 'createRange').andReturn(range);

        highlighter.createHighlightWithStartAndEndElements(startElement, endElement);
        expect(range.setStartBefore).toHaveBeenCalledWith(endElement);
        expect(range.setEndAfter).toHaveBeenCalledWith(startElement);
      });
    });
  });

  describe("#highlightSelection", function () {
    var paragraph;

    beforeEach(function() {
      paragraph = document.getElementById("para07");
    });

    it("should assign a unique index to each highlight", function() {
      var textNode = paragraph.firstChild;
      var range = document.createRange();
      range.setStart(textNode, 2);
      range.setEnd(textNode, 9);
      setSelectionRange(range);

      highlighter.highlightSelection();
      var firstHighlight = highlighter.currentHighlight;

      highlighter.highlightSelection();
      var secondHighlight = highlighter.currentHighlight;

      expect(firstHighlight.index).not.toEqual(secondHighlight.index);
    });

    describe("with only text selected", function () {
      var textNode;

      beforeEach(function() {
        textNode = paragraph.firstChild;
        expect(textNode.childNodes.length).toEqual(0);

        var range = document.createRange();
        range.setStart(textNode, 2);
        range.setEnd(textNode, 9);

        setSelectionRange(range);
      });

      it("should wrap the selected text in a div.highlighted element", function() {
        highlighter.highlightSelection();

        expect(paragraph.innerHTML).toContain("st<div id=\"highlight-0\" class=\"highlighted\">art tex</div>t");
      });
    });

    describe("when the selection start node is a child of a sub-element", function () {
      var startSubElement, startTextNode, endTextNode;

      beforeEach(function() {
        var range = document.createRange();

        startSubElement = paragraph.getElementsByTagName("span")[0];
        startTextNode = startSubElement.firstChild;
        expect(startTextNode.childNodes.length).toEqual(0);
        range.setStart(startTextNode, 2);

        endTextNode = startSubElement.nextSibling;
        expect(endTextNode.childNodes.length).toEqual(0);
        range.setEnd(endTextNode, 5);

        setSelectionRange(range);
      });

      it("should wrap the selected text, including the entire sub-element, in a div.highlighted element", function() {
        highlighter.highlightSelection();

        expect(paragraph.innerHTML).toContain("<div id=\"highlight-0\" class=\"highlighted\"><span class=\"emphasis\">inner text</span>middl</div>");
      });
    });

    describe("when the selection end node is a child of a sub-element", function () {
      var endSubElement, startTextNode, endTextNode;

      beforeEach(function() {
        var range = document.createRange();

        endSubElement = paragraph.getElementsByTagName("span")[0];
        endTextNode = endSubElement.firstChild;
        expect(endTextNode.childNodes.length).toEqual(0);
        range.setEnd(endTextNode, 5);

        startTextNode = endSubElement.previousSibling;
        expect(startTextNode.childNodes.length).toEqual(0);
        range.setStart(startTextNode, 3);

        setSelectionRange(range);
      });

      it("should wrap the selected text, including the entire sub-element, in a div.highlighted element", function() {
        highlighter.highlightSelection();

        expect(paragraph.innerHTML).toContain("<div id=\"highlight-0\" class=\"highlighted\">rt text<span class=\"emphasis\">inner text</span></div>");
      });
    });

    describe("when the selection start node and end node are children of different sub-elements", function () {
      var startSubElement, endSubElement, startTextNode, endTextNode;

      beforeEach(function() {
        var range = document.createRange();

        startSubElement = paragraph.getElementsByTagName("span")[0];
        startTextNode = startSubElement.firstChild;
        expect(startTextNode.childNodes.length).toEqual(0);
        range.setStart(startTextNode, 2);

        endSubElement = paragraph.getElementsByTagName("span")[1];
        endTextNode = endSubElement.firstChild;
        expect(endTextNode.childNodes.length).toEqual(0);
        range.setEnd(endTextNode, 4);

        setSelectionRange(range);
      });

      it("should wrap the selected text, including the entirety of both sub-elements and everything in between, in a div.highlighted element", function() {
        highlighter.highlightSelection();

        expect(paragraph.innerHTML).toContain("<div id=\"highlight-0\" class=\"highlighted\"><span class=\"emphasis\">inner text</span>middle text<span class=\"emphasis2\">inner text 2</span></div>");
      });
    });

    describe("when the selection surrounds an element", function () {
      var selectedElement;

      beforeEach(function() {
        selectedElement = paragraph.getElementsByTagName('span')[0];

        var range = document.createRange();
        range.selectNode(selectedElement);

        setSelectionRange(range);
      });

      it("should wrap the selected element in a div.highlighted element", function() {
        highlighter.highlightSelection();

        expect(paragraph.innerHTML).toContain("<div id=\"highlight-0\" class=\"highlighted\"><span class=\"emphasis\">inner text</span></div>");
      });
    });

    describe("when the selection surrounds an img element at any nest level", function () {
      var startElement, endElement;

      beforeEach(function() {
        startElement = paragraph.getElementsByTagName('span')[1];
        endElement = paragraph.getElementsByTagName('img')[0];

        var range = document.createRange();
        range.setStartBefore(startElement);
        range.setEndAfter(endElement);

        setSelectionRange(range);
      });

      it("should wrap the selected elements in a div.highlighted.block element", function() {
        highlighter.highlightSelection();

        expect(paragraph.innerHTML).toContain("<div id=\"highlight-0\" class=\"highlighted block\"><span class=\"emphasis2\">inner text 2</span>end text<img src=\"something.png\" alt=\"something\"></div>");
      });
    });

    describe("when the selection contains a block element", function () {
      var allContent, blockElement;

      beforeEach(function() {
        allContent = document.getElementById("jasmine_content");
        blockElement = allContent.getElementsByTagName("div")[0];

        var range = document.createRange();
        range.selectNode(blockElement);

        setSelectionRange(range);
      });

      it("should wrap the selected element in a div.highlighted.block element", function() {
        highlighter.highlightSelection();

        expect(allContent.innerHTML).toContain("<div id=\"highlight-0\" class=\"highlighted block\"><div>block text</div></div>");
      });
    });
  });

  describe("#currentHighlight", function () {
    describe("with nothing highlighted", function () {
      it("should return null", function() {
        expect(highlighter.currentHighlight).toBeNull();
      });
    });

    describe("after the user adds a highlight", function () {
      beforeEach(function() {
        var range = document.createRange();
        range.selectNode($('img')[0]);
        setSelectionRange(range);

        highlighter.highlightSelection();
      });

      it("should return the most recent highlight", function() {
        expect(highlighter.currentHighlight).not.toBeNull();
      });
    });
  });

  describe("#precedingSiblingHighlightIndex", function() {
    var parent;

    beforeEach(function() {
      parent = $('#several-highlights')[0];
    });

    describe("with no preceding highlights", function() {
      beforeEach(function() {
        var range = document.createRange();
        range.selectNode($("> p", parent)[0]);

        setSelectionRange(range);
        Halo.highlighter.highlightSelection();
      });

      it("should return -1", function() {
        expect(Halo.highlighter.precedingSiblingHighlightIndex).toEqual('-1');
      });
    });

    describe("with a preceding sibling highlight", function() {
      beforeEach(function() {
        var range = document.createRange();
        range.selectNode($("#sibling-after-highlight", parent)[0]);

        setSelectionRange(range);
        Halo.highlighter.highlightSelection();
      });

      it("should return the index of the preceding sibling highlight", function() {
        expect(Halo.highlighter.precedingSiblingHighlightIndex).toEqual('3');
      });
    });

    describe("with a preceding highlight that is not a sibling", function() {
      beforeEach(function() {
        var range = document.createRange();
        range.selectNode($("#non-sibling-after-highlight", parent)[0]);

        setSelectionRange(range);
        Halo.highlighter.highlightSelection();
      });

      it("should return -1", function() {
        expect(Halo.highlighter.precedingSiblingHighlightIndex).toEqual('-1');
      });
    });
  });

  describe("#addHighlight", function() {
    var highlight;

    beforeEach(function() {
      var paragraph = document.getElementById("para07");
      var textNode = paragraph.firstChild;
      expect(textNode.nodeType).toEqual(Node.TEXT_NODE);

      var range = document.createRange();
      range.setStart(textNode, 2);
      range.setEnd(textNode, 9);

      setSelectionRange(range);
      highlighter.highlightSelection();
      highlight = highlighter.currentHighlight;
      delete highlight.section;
      highlight.section = 'a-section';
      var rangeJSON = highlight.rangeJSON;

      loadFixtureDocument();
      highlighter = new Halo.Highlighter();

      var newIndex = 7;
      var highlight2 = Halo.Highlight.fromJSON(newIndex, rangeJSON);
      highlighter.addHighlight(highlight2);
    });

    it("should not add the markup for the highlight", function() {
      var paragraph = document.getElementById("para07");
      expect(paragraph.innerHTML).not.toContain("class=\"highlighted\"");
    });

    it("should not set the current highlight", function() {
      expect(highlighter.currentHighlight).toBeNull();
    });

    it("should increment the highlight counter", function() {
      highlighter.highlightSelection();

      expect(highlighter.currentHighlight.index).toEqual(1);
    });
  });

  describe("#addMarkupForAllHighlights", function() {
    var highlights;

    beforeEach(function() {
      highlights = [];

      var index;
      for (index = 0; index < 3; ++index) {
        var mockHighlight = jasmine.createSpyObj('highlight', ['addMarkup']);
        mockHighlight.index = index;
        highlights.push(mockHighlight);
        highlighter.addHighlight(mockHighlight);
      }

      highlighter.addMarkupForAllHighlights();
    });

    it("should add markup for all highlights (duh)", function() {
      var index;
      for (index = 0; index < highlights.length; ++index) {
        expect(highlights[index].addMarkup).toHaveBeenCalled();
      }
    });
  });

  describe("#removeHighlight()", function () {
    var paragraph;

    beforeEach(function() {
      paragraph = document.getElementById("para07");
    });

    describe("with a highlight that contains only text", function () {
      var textNode;

      beforeEach(function() {
        textNode = paragraph.firstChild;
        expect(textNode.childNodes.length).toEqual(0);

        var range = document.createRange();
        range.setStart(textNode, 2);
        range.setEnd(textNode, 9);

        setSelectionRange(range);

        highlighter.highlightSelection();
        expect(paragraph.innerHTML).toContain("st<div id=\"highlight-0\" class=\"highlighted\">art tex</div>t");
      });

      it("should remove the highlight element with the specified index", function() {
        highlighter.removeHighlight(0);

        expect(paragraph.innerHTML).not.toContain("<div id=\"highlight-0\" class=\"highlighted\">");
        expect(paragraph.innerHTML).toContain("start text");
      });

      it("should not remove any other highlight elements", function() {
        highlighter.removeHighlight(1);

        expect(paragraph.innerHTML).toContain("st<div id=\"highlight-0\" class=\"highlighted\">");
      });
    });

    describe("when the selection surrounds an element", function () {
      var selectedElement;

      beforeEach(function() {
        selectedElement = paragraph.getElementsByTagName('span')[0];

        var range = document.createRange();
        range.selectNode(selectedElement);

        setSelectionRange(range);
        highlighter.highlightSelection();
      });

      it("should remove the highlight element with the specified index", function() {
        highlighter.removeHighlight(0);

        expect(paragraph.innerHTML).not.toContain("<div id=\"highlight-0\" class=\"highlighted\">");
        expect(paragraph.innerHTML).toContain("<span class=\"emphasis\">inner text</span>");
      });

      it("should not remove any other highlight elements", function() {
        highlighter.removeHighlight(1);

        expect(paragraph.innerHTML).toContain("<div id=\"highlight-0\" class=\"highlighted\"><span class=\"emphasis\">inner text</span></div>");
      });
    });
  });

  describe("#isSelectionOverlappingExistingHighlight", function () {
    var paragraph, newRange;

    beforeEach(function() {
      paragraph = document.getElementById("para07");
      newRange = document.createRange();
    });

    describe("with only text selected", function () {
      var textNode;

      beforeEach(function() {
        textNode = paragraph.firstChild;
        expect(textNode.childNodes.length).toEqual(0);

        var range = document.createRange();
        range.setStart(textNode, 2);
        range.setEnd(textNode, 9);

        setSelectionRange(range);
        highlighter.highlightSelection();
      });

      it("should return true if new selection is entirely inside highlighted section", function() {
        var highlightNode = paragraph.childNodes[1].childNodes[0];
        newRange.setStart(highlightNode, 2);
        newRange.setEnd(highlightNode, 5);

        setSelectionRange(newRange);

        expect(highlighter.isSelectionOverlappingExistingHighlight()).toBe(true);
      });

      it("should return true if new selection starts before and ends inside highlighted section", function() {
        newRange.setStart(paragraph.childNodes[0], 1);
        newRange.setEnd(paragraph.childNodes[1].childNodes[0], 4);

        setSelectionRange(newRange);

        expect(highlighter.isSelectionOverlappingExistingHighlight()).toBe(true);
      });

      it("should return true if new selection starts inside and ends outside highlighted section", function() {
        newRange.setStart(paragraph.childNodes[1].childNodes[0], 4);
        newRange.setEnd(paragraph.childNodes[2], 1);

        setSelectionRange(newRange);

        expect(highlighter.isSelectionOverlappingExistingHighlight()).toBe(true);
      });

      it("should return true if new selection spans highlighted section", function() {
        newRange.setStart(paragraph.childNodes[0], 1);
        newRange.setEnd(paragraph.childNodes[2], 1);

        setSelectionRange(newRange);

        expect(highlighter.isSelectionOverlappingExistingHighlight()).toBe(true);
      });
    });

    describe("with just an image selected", function() {
      it("should return true of the new selection is a previously highlighted image", function() {
        newRange.setStart($('img')[0].previousSibling, 8);
        newRange.setEnd($('img')[0].nextSibling, 0);
        setSelectionRange(newRange);
        highlighter.highlightSelection();

        newRange.setStart($('img')[0].parentNode, 0);
        newRange.setEnd($('img')[0].parentNode.nextSibling, 0);

        setSelectionRange(newRange);

        expect(highlighter.isSelectionOverlappingExistingHighlight()).toBe(true);
      });
    });
  });

  describe("when tapping on an existing highlight", function() {
    var paragraph;
    var textNode;

    beforeEach(function() {
      spyOn(nsBridge, "sendEvent");
      createOneHighlight(highlighter);

      $('#highlight-0').click();
    });

    it("should tell obj-c to focus the current highlight", function() {
      expect(nsBridge.sendEvent).toHaveBeenCalledWith('put', 'highlights', '0', 'focus');
    });
  });

  describe("when tapping on anything", function () {
    beforeEach(function() {
      spyOn(nsBridge, "sendEvent");
      $('body').click();
    });

    it("should tell obj-c to defocus any focused highlights", function() {
      expect(nsBridge.sendEvent).toHaveBeenCalledWith('put', 'highlights', '', 'defocus');
    });
  });

  describe("#focusHighlight", function () {
    beforeEach(function() {
      createOneHighlight(highlighter);

      expect($('#highlight-0').length).toBeGreaterThan(0);
      expect($('#highlight-0').hasClass('focused')).toBe(false);
    });

    it("should add class 'focused' to the current highlight", function() {
      Halo.highlighter.focusHighlight(0);
      expect($('#highlight-0').hasClass('focused')).toBe(true);
    });
  });

  describe("#defocusHighlights", function () {
    beforeEach(function() {
      createOneHighlight(highlighter);

      Halo.highlighter.focusHighlight(0);

      expect($('#highlight-0').hasClass('focused')).toBeTruthy();
    });

    it("should remove the focused class from all highlights", function() {
      Halo.highlighter.defocusHighlights();
      expect($('#highlight-0').hasClass('focused')).toBe(false);
    });
  });
});

function loadFixtureDocument() {
  $.ajax({
    async:false,
    url:"Spec/Content/fixtures/highlight-targets.html",
    success: function(data) {
      $('#jasmine_content').html(data);
    }
  });
}

function setSelectionRange(range) {
  var selection = jasmine.createSpyObj('selection', ['getRangeAt', 'removeAllRanges']);
  selection.getRangeAt.andReturn(range);
  document.getSelection.andReturn(selection);
}

function createOneHighlight(highlighter) {
  var paragraph = document.getElementById("para07");
  var range = document.createRange();
  var textNode = paragraph.firstChild;
  range.setStart(textNode, 2);
  range.setEnd(textNode, 9);

  setSelectionRange(range);
  highlighter.highlightSelection();
  expect(paragraph.innerHTML).toContain("st<div id=\"highlight-0\" class=\"highlighted\">art tex</div>t");
}
