Halo.Highlighter = function() {
  var self = {};
  var currentHighlight = null;
  var highlightCount = 0;
  var highlights = {};

  self.highlightSelection = function() {
    if (document.getSelection().rangeCount <= 0) return;
    var range = validHighlightRangeForRange(document.getSelection().getRangeAt(0));

    // Remove selection ranges *before* wrapping the current selection range in
    // a span.  Otherwise the UIWebView selection mechanism appears to get
    // confused and move the selection widget around idiosyncratically.
    document.getSelection().removeAllRanges();

    self.beginHighlighting();
    createHighlightForRange(range);
  };

  self.beginHighlighting = function() {
    currentHighlight = null;
  };

  self.createHighlightWithStartAndEndElements = function(startElement, endElement) {
    if (currentHighlight) {
      self.removeHighlight(--highlightCount);
      currentHighlight = null;
    }

    var range = document.createRange();
    range.setStartBefore(startElement);
    range.setEndAfter(endElement);

    if (range.collapsed) {
      range.setStartBefore(endElement);
      range.setEndAfter(startElement);
    }

    range = validHighlightRangeForRange(range);
    createHighlightForRange(range);
  };

  self.createPersistentHighlightWithStartAndEndElements = function(startElement, endElement) {

    if (currentHighlight) {
      self.removeHighlight(--highlightCount);
      currentHighlight = null;
    }

    var localRange = document.createRange();

    localRange.setStartBefore(startElement);
    localRange.setEndAfter(endElement);

    if (localRange.collapsed) {
      var tempStart = endElement;
      endElement = startElement;
      startElement = tempStart;

      localRange.setStartBefore(startElement);
      localRange.setEndAfter(endElement);
    }
    localRange = validHighlightRangeForRange(localRange);

    if (localRange.startContainer.childNodes[localRange.startOffset] === startElement) {
      startElement = startElement.firstChild;
    } else {
      startElement = localRange.startContainer.childNodes[localRange.startOffset];
    }

    if (localRange.endContainer.childNodes[localRange.endOffset - 1] === endElement) {
      endElement = endElement.firstChild;
    } else {
      endElement = localRange.endContainer.childNodes[localRange.endOffset - 1];
    }

    var newRange = document.createRange();
    var origStartOffset = localRange.startOffset;
    var origEndOffset = localRange.endOffset;

    // remove spans!!
    var paragraph = $(startElement).closest("p, li")[0];
    $(".touchable", paragraph).contents().unwrap();

    if(startElement.nodeType == Node.ELEMENT_NODE) {
      newRange.setStart(localRange.startContainer, origStartOffset);
    } else {
      newRange.setStart(startElement, 0);
    }

    if(endElement.nodeType == Node.ELEMENT_NODE) {
      newRange.setEnd(localRange.endContainer, origEndOffset);
    } else {
      newRange.setEnd(endElement, endElement.textContent.length);
    }

    createHighlightForRange(newRange);
  };
    
  self.hasHighlights = function() {
    return highlightCount > 0;
  }

  self.addHighlight = function(highlight) {
    highlights[highlightCount++] = highlight;
  };

  self.addMarkupForAllHighlights = function() {
    var highlightIndex;
    for (highlightIndex in highlights) {
      if (highlights.hasOwnProperty(highlightIndex)) {
        highlights[highlightIndex].addMarkup();
      }
    }
  };

  self.removeHighlight = function(index) {
    var highlight = highlights[index];
    highlight && highlight.removeMarkup();
  };

  self.__defineGetter__('currentHighlight', function() {
    return currentHighlight;
  });
    
  self.getHighlight = function(index) {
    return highlights[index];
  };

  self.__defineGetter__('precedingSiblingHighlightIndex', function() {
    var $previousSiblingHighlight = $("#" + currentHighlight.id).prev(".highlighted");
    if ($previousSiblingHighlight.length) {
      return $previousSiblingHighlight[0].id.substr(Halo.Highlight.idPrefix.length);
    }
    return '-1';
  });

  self.isSelectionOverlappingExistingHighlight = function() {
    if (document.getSelection().rangeCount <= 0) return true;
    var range = validHighlightRangeForRange(document.getSelection().getRangeAt(0));
    return self.isRangeOverlappingExistingHighlight(range);
  };

  self.isRangeOverlappingExistingHighlight = function(range) {
    return isSelfOrParentHighlighted(range) || containsHighlighted(range)
	  || $(range.startContainer).parents(".bt-wrapper").length > 0;
  };	
	
  self.focusHighlight = function(index) {
    var highlight = highlights[index];
    highlight.focus();
  };

  self.defocusHighlights = function() {
    $('.highlighted.focused').removeClass('focused');
  };

  return self;

  function isSelfOrParentHighlighted(range) {
    return  $(range.startContainer).parents('.highlighted').length > 0 || $(range.startContainer).is('.highlighted')
           || $(range.endContainer).parents('.highlighted').length > 0 || $(range.endContainer).is('.highlighted');
  }

  function containsHighlighted(range) {
    return !!range.cloneContents().querySelector('.highlighted');
  }

  function validHighlightRangeForRange(range) {
    var startContainer = range.startContainer;
    var endContainer = range.endContainer;

    if (startContainer != endContainer) {
      fixOverlyAggressiveEndSelection(range);

      // TODO: extract method
      while (!(startContainer == range.commonAncestorContainer) && !(Node.TEXT_NODE == startContainer.nodeType && startContainer.parentNode == range.commonAncestorContainer)) {
        range.setStartBefore(startContainer);
        startContainer = startContainer.parentNode;
      }

      while (!(endContainer == range.commonAncestorContainer) && !(Node.TEXT_NODE == endContainer.nodeType && endContainer.parentNode == range.commonAncestorContainer)) {
        range.setEndAfter(endContainer);
        endContainer = endContainer.parentNode;
      }
    }

    return range;
  }

  function fixOverlyAggressiveEndSelection(range) {
    // The range object appears to have a bug that causes it to partially
    // select the element following the selection if the selection starts and
    // ends on element boundaries.
    if (Node.ELEMENT_NODE == range.endContainer.nodeType) {
      if (0 == range.endOffset) {
        range.setEndBefore(range.endContainer);
      }
    }
  }

  function createHighlightForRange(range) {
    currentHighlight = new Halo.Highlight(highlightCount, range);
    highlights[highlightCount++] = currentHighlight;

    currentHighlight.addMarkup();
  }

};

$(document).ready(function() {
  if (window.Touch && $("#glossary-page, .answer-page").length == 0) {
                  
    $('body').delegate('.highlighted', 'touchclick', function() {
        var highlightId = this.id.split('-')[1];
        nsBridge.sendEvent('put', 'highlights', highlightId, 'focus');
        event.stopPropagation();
    });
          
    // hack to make text selection work in textbook
    $('span.keywords').bind('touchclick', function() {
        nsBridge.sendEvent('put', 'highlights', '', 'defocus');
        event.stopPropagation();
    });
          
    $('body').bind('touchclick', function(e) {
        if($(e.target).closest('.highlighted').length == 0) nsBridge.sendEvent('put', 'highlights', '', 'defocus');
        return true;
    });

//    $('a').bind('touchclick', function() {
//        nsBridge.sendEvent('put', 'highlights', '', 'defocus');
//        event.stopPropagation();
//    });
  }
});

