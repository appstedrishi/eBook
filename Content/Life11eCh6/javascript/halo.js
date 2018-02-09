var Halo = {};

jQuery.fn.cleanWhitespace = function(andTrim) { // recursive and (optionally) trims surrounding whitespaces
    this.contents().filter(function() {
        if (this.nodeType != 3) {
            $(this).cleanWhitespace(andTrim);
            return false;
        }
        else {
            var isEmpty = !/\S/.test(this.nodeValue);
            if(!isEmpty && andTrim) this.nodeValue = $.trim(this.nodeValue);
            return isEmpty;
        }
    }).remove();
    return this;
}

$(document).ready(function() {
	Halo.highlighter = new Halo.Highlighter();
	Halo.touchEventHandler = new Halo.TouchEventHandler(Halo.highlighter);
				  
    // add copyright
	if($('body > .concept, #top-level > .concept, #review, #overview').length > 0) {
		$.ajax({
			url: '../../html/copyright.html',
			success: function(data) {
			   $('body > .concept, #top-level > .concept, .chapter-end, #overview').append(data);
			}
		});
	}
});
