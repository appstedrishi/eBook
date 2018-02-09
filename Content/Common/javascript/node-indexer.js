Halo.NodeIndexer = function() {
  var self = {};

  self.indexOfNodeInParent = function(node) {
    var result;
    $(node.parentElement).contents().each(function(index, child) {
      if (child == node) {
        result = index;
      }
    });

    return result;
  };

  self.indexOfNodeInParentWithoutHighlights = function(node) {
    var index = 0;
    var sibling = node;

    while (sibling = sibling.previousSibling) {
      index += indexOfNodeWithoutHighlights(sibling);
    }

//    console.error("=============> indexOfNodeInParentWithoutHighlights: ", index);
    return index;
  };

  self.fixedOffsetForNodeInParentWithoutHighlights = function(parent, offset) {
    var index = 0;

    for (var i = offset - 1; i >= 0; --i) {
      var sibling = parent.childNodes[i];
      index += indexOfNodeWithoutHighlights(sibling);
    }

//    console.error("=============> fixedOffsetForNodeInParentWithoutHighlights: ", index);
    return index;
  };

  return self;

  function indexOfNodeWithoutHighlights(node) {
    var index = 0;

    if (nodeIsTransient(node)) {
      node.normalize();
      index = node.childNodes.length;

      if (transientNodeDidSplitTextAtStart(node) || transientNodeDidSplitTextAtEnd(node)) {
        --index;
        if (transientNodeDidSplitTextAtStartAndEnd(node)) {
          --index;
        }
      }
    } else {
      if (!nodeIsSplitTextNode(node)) {
        ++index;
      }
    }

//    console.error("=============> indexOfNodeWithoutHighlights: ", index);
    return index;
  }

  function nodeIsTransient(node) {
    return node.nodeType == Node.ELEMENT_NODE && $(node).hasClass("highlighted") || $(node).hasClass("touchable");
  }

  function transientNodeDidSplitTextAtStart(node) {
    return node.firstChild.nodeType === Node.TEXT_NODE && (node.previousSibling &&
           node.previousSibling.nodeType === Node.TEXT_NODE) ||
           (node.previousSibling && nodeIsTransient(node.previousSibling) && node.previousSibling.lastChild.nodeType === Node.TEXT_NODE);
  }

  function transientNodeDidSplitTextAtEnd(node) {
    return node.lastChild.nodeType === Node.TEXT_NODE && (node.nextSibling && node.nextSibling.nodeType === Node.TEXT_NODE) ||
           (node.nextSibling && nodeIsTransient(node.nextSibling) && node.nextSibling.firstChild.nodeType === Node.TEXT_NODE);
  }

  function transientNodeDidSplitTextAtStartAndEnd(node) {
    return node.lastChild.nodeType === Node.TEXT_NODE && node.firstChild.nodeType === Node.TEXT_NODE &&
           (node.nextSibling && node.nextSibling.nodeType === Node.TEXT_NODE) &&
           (node.previousSibling && node.previousSibling.nodeType === Node.TEXT_NODE);
  }

  function nodeIsSplitTextNode(node) {
    return node.nodeType == Node.TEXT_NODE && node.nextSibling && node.nextSibling.nodeType == Node.TEXT_NODE;
  }
}();
