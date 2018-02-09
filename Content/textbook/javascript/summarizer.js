//$(document).ready(function() {
//});

Halo.removeAllUnhighlightedContent = function() {
	$('.sub-section > p, .sub-concept > p').each(function() {
		if ($(this).children('.highlighted:first').prev().length > 0) $(this).prepend('<span class=hellip> &hellip; </span>');
		//if ($(this).children('.highlighted:last').length > 0) $(this).append('<span class=hellip> &hellip; </span>');

		Halo.removeUnhighlightedContent(this);
		if ($(this).is(':empty')) {
            $(this).addClass("hellip");
			$(this).html('paragraph&hellip;');
		} else {
			$(this).contents().not('.hellip').after('<span class=hellip> &hellip; </span>');
		}
	});

//	$('.fig').removeClass('fig').addClass('fig-wide');

	var stylePath = '../../css/textbook-summary.css';
	$('head').append('<link rel="stylesheet" type="text/css" href="' + stylePath + '"/>');
    return true;
};

Halo.removeUnhighlightedContent = function(element) {
	var removedAll = true;
	$(element).contents().filter(function() {
		if (this.nodeType == 3) {
			return true;
		} else {
			if ($(this).hasClass('highlighted') || $(this).hasClass('hellip')) {
				return removedAll = false;
			} else {
				var removedAllChildren = Halo.removeUnhighlightedContent(this);
				removedAll &= removedAllChildren;
				return removedAllChildren;
			}
		}
	}).remove();
	return removedAll;
};