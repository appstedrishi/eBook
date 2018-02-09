$(document).ready(function() {
                  Halo.prepareTooltipElements();
                  Halo.clicksOnNonTooltipElementsShouldCloseAnyTooltip();
                  });

Halo.prepareTooltipElements = function() {
    Halo.prepareTooltipElement($('a.keywords'));
}

Halo.prepareTooltipElement = function(element) {
    $("a.keywords").each(function(){
        this.href = this.href.replace(/\s/g,"%20"); // handle errant spaces
     });
    // hack to make text selection work in textbook
    if ($("#glossary-page, .answer-page").length == 0) {
        $(element).each( function(idx) {
                        var href = $(this).attr('href');
                        $(this).replaceWith($('<span class="keywords" href="' +href+ '">' + this.innerHTML + '</span>'));
                        });
        element = $("span.keywords");
    }
    
    $(element).click(function(event) {
                     event.stopPropagation();
                     //    nsBridge.sendEvent('put', 'glossary', $(this).attr('href'), 'showPopup');
                     event.preventDefault();
                     }).bt({
                           trigger: 'touchclick',
                           positions: ['top', 'bottom'],
                           width: '280px',
                           cornerRadius: 0,
                           shadow: true,
                           shadowOffsetX: 0,
                           shadowOffsetY: 2,
                           shadowBlur: 16,
                           shadowColor: 'rgba(0,0,0,.333)',
                           spikeGirth: 30,
                           spikeLength: 15,
                           fill: 'white', //'#55585f',
                           strokeStyle: 'rgba(0,0,0,0.1)', //'rgba(255,255,255,0.85)',
                           strokeWidth: 1,
                           ajaxPath: ["$(this).attr('href')", "div#shortdef"],
                           clickAnywhereToClose: true,
                           overlap: 12,
                           padding: 16,
                           windowMargin: 36,
                           killTitle: false, // don't need it, and it causes trouble with relationship answers
                           ajaxCache: false,
                           ajaxLoading: '',   // Don't show a loading box, since it interferes with animation
                           closeWhenOthersOpen: true,
                           offsetParent: '#top-level',
                           showTip: Halo.animateToolTipShow,
                           hideTip: Halo.animateToolTipHide,
                           preSizeCalculation: Halo.buildTooltipNavigationContent,
                           postShow: function(box){       // function to run after popup is built and displayed
                           nsBridge.sendEvent('put', 'glossary', $(this).attr('href'), 'showPopup');
                           }
                           });
};

Halo.buildTooltipNavigationContent = function(box) {
    if ($('#shortdef', box).length) {
        var href = $(this).attr('href');
        
        // fix &html; entities in the text
        var cleanText = $('.bt-content p', box).text();
        cleanText = $('<div/>').html(cleanText).text();
        $('.bt-content p', box).text(cleanText);
        
        if (cleanText.length > 290) {
            var newtext = cleanText.trim()    // remove leading and trailing spaces
            .substring(0, 290)    // get first 300 characters
            .split(" ")           // separate characters into an array of words
            .slice(0, -1)         // remove the last full or partial word
            .join(" ") + " \u2026"; // combine into a single string and append "…"
            $('.bt-content p', box).text(newtext);
        }
        
        //    $('.bt-content', box).append(" <a class='navigation' href=" + href + ">Read&nbsp;More</a>");
        //    $('.bt-content h3', box).wrapInner("<a href='" + href + "' />");
        $('.bt-content h3', box).prepend(" <a class='navigation' href=" + href + ">more</a>");
        
        // add CSS animations!
        $(box).css('opacity', 0);
        $(box).css('-webkit-transition', 'opacity 0.3s linear');
    }
};

Halo.animateToolTipShow = function(box) {
    /*   $(box).fadeIn(400); */
    $(box).css({
               'visible' : 'visible',
               'display' : 'block'
               });
    $(box).css('opacity', 1);
};

Halo.animateToolTipHide = function(box, callback) {
    /*   $(box).css('-webkit-transition', 'none'); */
    /*   $(box).animate({opacity: 0}, 400, callback); */
    $(box).css('opacity', 0);
    window.setTimeout(function() {  
                      callback();  
                      }, 400);
};

Halo.clicksOnNonTooltipElementsShouldCloseAnyTooltip = function() {
    var $tag = $('body > #top-level');
    if (!$tag[0]) {
        $('body > *').wrapAll('<div id="top-level"></div>');
    }
};

Halo.dismissAllTooltips = function() {
	$(jQuery.bt.vars.clickAnywhereStack).btOff();
};
