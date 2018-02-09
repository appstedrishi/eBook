$(document).ready(function() {
    // We have several click actions in the book content; a click can focus a highlight, display a pop-up, or follow a
    // link.  We want to be able to manage which of these happens, and in which order, when more than one event is
    // the possible response to a click (e.g. when the user taps a link inside a highlight).
    $("a").click(function(event) {
    event.stopPropagation();
    });
                  
    // enable tapping anywhere on a figure box to activate the thumbnail link; requires form submit to trigger uiwebview events correctly
   $(".fig, .fig-wide").click(function(event) {
        var href = $(this).children('a').attr('href');
        if (href) {
           event.stopPropagation();
           $('<form>').attr({action: href, method: 'GET'}).appendTo($('body')).submit();
           event.preventDefault();
        }
    });

});
