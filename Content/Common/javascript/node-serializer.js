Halo.NodeSerializer = function() {
  var self = {};

  self.serialize = function(domNode) {
    if (domNode.id) {
      return {
        id: domNode.id
      };
    } else {
      return {
        parentElement: self.serialize(domNode.parentElement),
        childOffset: Halo.NodeIndexer.indexOfNodeInParentWithoutHighlights(domNode)
      };
    }
  };

  self.deserialize = function(serialized) {
    if (serialized.id) {
      return $("#" + serialized.id)[0];
    } else {
      return self.deserialize(serialized.parentElement).childNodes[serialized.childOffset];
    }
  };

  return self;
}();
