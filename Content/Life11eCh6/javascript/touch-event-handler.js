Halo.TouchEventHandler = function(highlighter) {
  var paragraph, startElement, endElement;

  var self = {};

  self.__defineGetter__("endElement", function() {
    return endElement;
  });

  self.touchesBeganAtPoint = function(x, y) {
    if (paragraph = $(document.elementFromPoint(x, y)).closest("p, li")[0]) {
      if ($(paragraph).is("li") && $(paragraph).parents("#glossary-page").length > 0) return "false"; //TODO: handle glossary highlighting better
      wrapTextChildrenInSpans(paragraph);
      return "true";
    } else {
      return "false";
    }
  };

  self.startHighlightAtPoint = function(x, y) {
    var touchedElement = document.elementFromPoint(x, y);
    if ($(touchedElement).hasClass("touchable") && !elementIsInsideHighlight(touchedElement)) {
      startElement = touchedElement;
      highlighter.beginHighlighting();
      return "true";
    } else {
      return "false";
    }
  };

  self.updateHighlightFeedbackToPoint = function(x, y) {
    var touchedElement = document.elementFromPoint(x, y);
    if ($(touchedElement).hasClass("touchable") && !rangeContainsHighlight(startElement, touchedElement)){
      endElement = touchedElement;
      highlighter.createHighlightWithStartAndEndElements(startElement, endElement);
      highlighter.currentHighlight.focus();
    }
  };

  self.touchesEnded = function() {
    if (startElement && endElement) {
      highlighter.createPersistentHighlightWithStartAndEndElements(startElement, endElement);
    }
    unwrapTextChildren();
    startElement = null;
    endElement = null;
  };

  return self;
	
	
  function elementIsInsideHighlight(element) {
    var highlightedParents = $(element).parents('.highlighted');
    return (highlightedParents != null && highlightedParents.length > 0);
  }
  
  function rangeContainsHighlight(startElement, endElement) {
    var range = document.createRange();
    range.setStartBefore(startElement);
    range.setEndAfter(endElement);
    if (range.collapsed) {
      range.setStartBefore(endElement);
      range.setEndAfter(startElement);
    }
    
    var overlapping = isRangeOverlappingExistingHighlight(range);
    return overlapping;
  }


  function isRangeOverlappingExistingHighlight(range) {
    return (range.startContainer == range.endContainer && isSelfOrParentHighlighted(range)) || containsHighlighted(range);
  }
  
  
  function isSelfOrParentHighlighted(range) {
    return ($(range.startContainer.parentNode).hasClass('highlighted') && range.startContainer.parentNode.id != highlighter.currentHighlight.id)
    || ($(range.startContainer).hasClass('highlighted') && range.startContainer.id != highlighter.currentHighlight.id);
  }

  function containsHighlighted(range) {
    var highlights = range.cloneContents().querySelectorAll('.highlighted');
    if (highlights.length > 1) {
      return true;
    }
    else if (highlights.length == 1) {
      return highlights[0].id != highlighter.currentHighlight.id;
    }
    return false;
  }

  function wrapTextChildrenInSpans(element) {
    for (var i = 0; i < element.childNodes.length; ++i) {

      if (element.childNodes[i].nodeType === Node.TEXT_NODE) {
        var node = element.childNodes[i];
        var words = node.textContent.match(/\s*\S+\s?/gm);
        if (!words) {
          continue;
        }
        for (var j = 0; j < words.length; ++j) {
          var span = document.createElement("SPAN");
          var innerText = document.createTextNode(words[j]);
          span.className = "touchable";
          span.appendChild(innerText);
          element.insertBefore(span, node);
        }

        element.removeChild(node);

      } else if (element.childNodes[i].className !== "touchable") {
        wrapTextChildrenInSpans(element.childNodes[i]);
      }
    }
  }

  function unwrapTextChildren() {
    $(".touchable", paragraph).contents().unwrap();
  }
};
