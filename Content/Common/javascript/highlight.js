Halo.Highlight = function(index, highlightRange) {
  initialize();

  var highlightNode, highlightRangeJSON;
  var self = {};

  self.__defineGetter__("id", function() {
    return Halo.Highlight.idPrefix + self.index;
  });

  self.__defineGetter__("index", function() {
    return index;
  });

  self.__defineGetter__("yOffset", function() {
    checkWasApplied();
    return highlightNode.offsetTop;
  });

  self.__defineGetter__("xOffset", function() {
    checkWasApplied();
    return highlightNode.offsetLeft;
  });

  self.__defineGetter__("height", function() {
    checkWasApplied();
    return highlightNode.offsetHeight;
  });

  self.__defineGetter__("text", function() {
    checkWasApplied();
    return highlightNode.textContent.replace(/\s+/g, ' ');
  });

  self.__defineGetter__("section", function() {
    checkWasApplied();
    return $(highlightNode).parents().filter(function() {
      return this.id.match(/section[0-9-]+/);
    })[0].id;
  });

  self.__defineGetter__("rangeJSON", function() {
    return highlightRangeJSON;
  });

  self.addMarkup = function() {
    highlightNode = document.createElement("div");
    $(highlightNode).attr('id', self.id);
    $(highlightNode).addClass("highlighted");
      
    highlightRange.surroundContents(highlightNode);
    if (highlightContainsBlockElements() || highlightContainsImageElements()) {
      $(highlightNode).addClass("block");
    }
  };

  self.removeMarkup = function() {
    $('#' + self.id).contents().unwrap();
  };

  self.focus = function() {
    $('#' + self.id).addClass('focused');
  };

  self.toJSON = function() {
    return $.toJSON({
      id: self.id,
      xOffset: self.xOffset,
      yOffset: self.yOffset,
      text: self.text,
      section: self.section,
      rangeJSON: self.rangeJSON
    });
  };

  return self;

  function initialize() {
    // Save the highlight range as JSON *before* adding the highlight node,
    // since adding the new node affects the range's offsets.
    try {
      serializeHighlightRange();
		//console.log("Created highlight range with JSON: " + highlightRangeJSON);
    } catch(x) {
      console.error("=============> Highlight.js FAIL!:" + x + "(" + highlightRange + ")");
    }
  }

  function checkWasApplied() {
    if (!highlightNode) {
      throw "Highlight with index '" + index + "' has been instantiated, but not applied to the DOM.";
    }
  }

  function serializeHighlightRange() {
    highlightRangeJSON = $.toJSON({
      startContainer: Halo.NodeSerializer.serialize(highlightRange.startContainer),
      startOffset: calculateAdditionalOffsetFromPreviousTextNodesAndHighlightElements(highlightRange.startContainer, highlightRange.startOffset),
      endContainer: Halo.NodeSerializer.serialize(highlightRange.endContainer),
      endOffset: calculateAdditionalOffsetFromPreviousTextNodesAndHighlightElements(highlightRange.endContainer, highlightRange.endOffset)
    });
  }

  function calculateAdditionalOffsetFromPreviousTextNodesAndHighlightElements(container, offset) {
    if (container.nodeType == Node.TEXT_NODE) {
      return offset + additionalTextOffsetAndContinue(container).additionalOffset;
    } else {
      return Halo.NodeIndexer.fixedOffsetForNodeInParentWithoutHighlights(container, offset);
    }
  }

  function additionalTextOffsetAndContinue(container, includeContainer) {
    var sibling = container;
    var additionalOffset = 0;
    var onlyTextNodesFound = true;

    if (!includeContainer) {
      sibling = sibling.previousSibling;
    }

    while (sibling && onlyTextNodesFound) {
      if (sibling.nodeType == Node.TEXT_NODE) {
        additionalOffset += sibling.textContent.length;
      } else if (isTransientElement(sibling)) {
        var result = additionalTextOffsetAndContinue(sibling.lastChild, true);
        additionalOffset += result.additionalOffset;
        onlyTextNodesFound = onlyTextNodesFound && result.onlyTextNodesFound;
      } else {
        onlyTextNodesFound = false;
      }
      sibling = sibling.previousSibling;
    }
    return { additionalOffset: additionalOffset, onlyTextNodesFound: onlyTextNodesFound };
  }

  function isTransientElement(element) {
    return $(element).hasClass('highlighted') || $(element).hasClass('touchable');
  }

  function highlightContainsBlockElements() {
    return $.grep($("> *", highlightNode), function(childNode) {
      return "block" == window.getComputedStyle(childNode).display;
    }).length;
  }

  function highlightContainsImageElements() {
    return $("img", highlightNode).length;
  }
};

Halo.Highlight.fromJSON = function(index, rangeJSON) {
  var rangeFromJSON = $.parseJSON(rangeJSON);

  var documentRange = document.createRange();
  documentRange.setStart(Halo.NodeSerializer.deserialize(rangeFromJSON.startContainer), rangeFromJSON.startOffset);
  documentRange.setEnd(Halo.NodeSerializer.deserialize(rangeFromJSON.endContainer), rangeFromJSON.endOffset);

  return new Halo.Highlight(index, documentRange);
};

Halo.Highlight.idPrefix = "highlight-";
