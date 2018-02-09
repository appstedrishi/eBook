Halo.Answers = function() {
	var self = this;
    
    self.loadAnswer = function(answer, firstRun) {
        $('#content').html(answer);
        Halo.answers.handleJS(firstRun);
        return "loaded";
    }
	
	self.handleJS = function(firstRun) {
		if(!firstRun) Halo.answers.init();
		if(!firstRun) Halo.prepareTooltipElements();
		if(!firstRun) Halo.prepareGlossary(false);
		if(!firstRun) Halo.answers.finishLoading();
        
        // handle relation graphs, rather hackishly
        if ($('.relationship-answer').length) {
        	self.handleRelationships();
        }
	}
	
	self.init = function() {
        $('#plusButton').bind('touchstart touchend', self.plusButtonClickHandler);
        $('#minusButton').live('touchstart touchend', self.minusButtonClickHandler);
        $('#minusButton').hide();
        $('#detail').hide();
        
        Halo.addShowHideButtonToSuggestedQuestions(true);
        
        $('#show-graph-button').bind('touchstart touchend', self.showGraphButtonHandler);
            
        $(window).load(function() {
            self.finishLoading();
        });
	};
	
	self.finishLoading = function() {
		//	collapsible answer page sections
//        if ($('#definition').length) {
//            var glosarySections = $("#related-entities, #subevents, #structure, #function, #kinds-of, #related, #roles, #properties");
//            $(glosarySections).find("h3").siblings().hide();
//            $(glosarySections).find("h3").prepend(" <span class='show-button'>show</span>");
//
//            $(glosarySections).find("h3 > .show-button").each(function() {
//                var count = $(this).parent().siblings().children('li:not(.parts), p').length + $(this).parent().siblings().find(".parts > ul").children().length;
//                if (count > 0) {
//                    $(this).text("show " + count);
//                } else {
//                    $(this).text("show");
//                }
//                $(this).toggle(function(e) {
//                    var showSpeed = Math.min($(".show-button").parent().siblings().find('li, p').length * 80, 200);
//                    $(e.currentTarget).parent().siblings().slideDown(showSpeed);
//                    $(e.currentTarget).parent().addClass('visible');
//                    $(e.currentTarget).attr('rel', $(e.currentTarget).text());
//                    $(e.currentTarget).text("hide");
//                    return false;
//                }, function(e) {
//                    var hideSpeed = Math.min($(e.currentTarget).parent().siblings().find('li, p').length * 80, 200);
//                    $(e.currentTarget).parent().siblings().slideUp(hideSpeed);
//                    $(e.currentTarget).parent().removeClass('visible');
//                    $(e.currentTarget).text($(e.currentTarget).attr('rel'));
//                    return false;
//                });
//            });
//        }
		
/* 		TOGGLE BUTTONS FOR LISTS (SUBCLASSES, ETC) -- hack for now? */
        var getSpeed = function(target){
            return Math.min($(target).find('li, p').length * 80, 200);
        };
        var unhandledLists = $(".toggle:not(:has(.show-button)) > ul");
        $(" <span class='show-button'>show</span>").insertBefore(unhandledLists)
            .toggle(function(e) {
                var showSpeed = getSpeed($(e.currentTarget).next("ul"));
                $(e.currentTarget).next("ul").slideDown(showSpeed);
                $(e.currentTarget).parent().addClass('visible');
                $(e.currentTarget).text("hide");
                return false;
            }, function(e) {
                var hideSpeed = getSpeed($(e.currentTarget).next("ul"));
                $(e.currentTarget).next("ul").slideUp(hideSpeed);
                $(e.currentTarget).parent().removeClass('visible');
                $(e.currentTarget).text("show");
                return false;
            });
            
        // RENAME BUTTONS FOR types-of-list (also hacky...)
        $('.types-of-list .show-button').each(function() {
            var plural = ($(this).next('ul').children('li').length == 1) ? "" : "s";
            $(this).text("show " + $(this).next('ul').children('li').length + " type"+plural);
        });
        
    	if($('table.sim-diff').length > 0) {
        	self.simDiffFunctions();
        }
    };
    
    self.handleRelationships = function() {
		loadGraph(function() {
            Halo.prepareTooltipElement($('.relationship-answer .descriptions .keywords'));
                  
            // collapse long descriptions to 4 lines (24px each)
            $('.relationship-answer .descriptions p').each(function() {
                if ($(this).height() > 96 && $(this).children('.hellip').length == 0) { 
                    $(this).css('max-height', '96px');
                    $(this).append($('<span class="hellip">&hellip;</span>'));
                }
            });
            
            // add navigation 
			if($('.relationship-answer').length > 1) {            			
				var tabs = $('<ul class="tabs" />').appendTo($('.question').addClass('has-tabs'));
				$('.relationship-answer').each(function(index, value) {
					if(index > 0) {
						$(value).hide();
						$(value).prev('.graph-intro').hide();
					}					
                    if (index < 9) { // ui falls apart if there are more than 9 tabs, so skip those after 9
                        var li = $('<li graph-id="#' + $(value).attr('id') + '" class="tab">' + (index+1) + '</li>').appendTo(tabs);
                        if(index == 0) li.addClass('active');
                        li.click(function() {
                            $('.active').removeClass('active');
                            $(this).addClass('active');
                            $('.relationship-answer').hide();
                            $('.relationship-answer hr').hide();
                            $('.answer-page > .graph-intro').hide();
                            $(li.attr('graph-id')).show().prev('.graph-intro').show();
                        });
                    }
				});
				
				// "all" button and append some <hr> to separate them
				$('<li class="tab">all</li>').appendTo(tabs).click(function() {
					$('.active').removeClass('active');
					$(this).addClass('active');
					$('.relationship-answer').show();
					$('.relationship-answer hr').show();
					$('.graph-intro').show();
				});
           		$('.relationship-answer:not(:last)').append('<hr style="border-bottom:none; border-top:solid 1px gray; margin:40px 0 70px 74px; display:none;" />');
            } //end nav
        });
    };
		
    self.simDiffFunctions = function() {
        
        // enable "show all" button type 1 (split)
        var VISIBLE_CUTOFF = 4;
        $('.sim-diff tr > td > ul').each(function() {
            if ($(this).children('li').length > VISIBLE_CUTOFF && $(this).children('.list-sublist').length == 0) {
                var numHidden = $(this).children('li').length - (VISIBLE_CUTOFF-1);
                $("<li class='parts-title list-split'>plus "+numHidden+" more&hellip;</li>").insertAfter($(this).children('li').get(VISIBLE_CUTOFF-2));
            }
        });
        $('.sim-diff .list-split').each(function() {
            var splitter = $(this);
            $(this).nextAll('li').hide();
            
            var td = $(this).parentsUntil('table', 'tr').children('td').first();
            var button = $(td).find('.show-button');
            if ($(button).length == 0) {
                button = $('<br /><span class="show-button">show all</span>').appendTo(td);
            }
            $(button).toggle(function(e) {
                var showSpeed = Math.min($(splitter).nextAll('li').length * 80, 200);
                $(splitter).hide();
                $(splitter).nextAll('li').fadeIn(showSpeed);
                $(e.currentTarget).text("hide");
                return false;
            }, function(e) {
                var hideSpeed = Math.min($(splitter).nextAll('li').length * 80, 200);
                $(splitter).nextAll('li').fadeOut(hideSpeed, function() {
                        $(splitter).fadeIn('fast');
                });
                $(e.currentTarget).text("show all");
                return false;
            });	
        });
        
        // enable "show all" button type 2 (sublist)
        $('.sim-diff .list-sublist').each(function() {
            var sublist = $(this).children('ul');
            var title = $(this).children('.list-title');
            $(sublist).hide();
            
            var td = $(this).parentsUntil('table', 'tr').children('td').first();
            var button = $(td).find('.show-button');
            if ($(button).length == 0) {
                button = $('<br /><span class="show-button">show all</span>').appendTo(td);
            }
            $(button).toggle(function(e) {
                var showSpeed = Math.min($(sublist).find('li, p').length * 80, 200);
                $(sublist).fadeIn(showSpeed);
                $(title).addClass('visible');
                $(e.currentTarget).text("hide");
                return false;
            }, function(e) {
                var hideSpeed = Math.min($(sublist).find('li, p').length * 80, 200);
                $(sublist).fadeOut(hideSpeed);
                $(title).removeClass('visible');
                $(e.currentTarget).text("show all");
                return false;
            });
        });
        
        // trim long defintions
        $('.sim-diff .human-authored').each(function() {
            if ($(this).height() > 144) { // 6 rows at 24px each
                var current = $(this);
                $(current).css('max-height', '120px'); // show one fewer row, to avoid the "expand to show one row" problem
                
                $('<a href="#" class="defn-more">more&hellip;</a>')
                .insertAfter($(this)).toggle(function(e) {
//                    $(current).animate({maxHeight:'528px'}, 400);
                    $(current).css('display', 'inline');
                    $(this).text("less").css('margin-left','5px');
                    return false;
                 }, function(e) {
//                    $(current).animate({maxHeight:'120px'}, 400, function() {
                     $(this).html("more&hellip;").css('margin-left','0');
                     $(current).css('display', 'block');
//                    });
                    return false;
                });
            }
        });
        
        // handle alignment within similarities rows
        var ONE_COL_WIDTH = $('table.sim-diff .human-authored').first().width();
        var TWO_COL_WIDTH = $('table.sim-diff td[colspan=2]').first().width();
        $('table.sim-diff tr:not(#misc-summary)  td[colspan=2]:not(.media)').wrapInner('<div class="similarities" />');
        $('.sim-diff div.similarities').each(function(){
            var maxWidth = 0;
            $(this).find('li, p, h3').wrapInner('<span />');
            $(this).find('a, span').each(function(i, e){
                maxWidth = Math.max($(e).innerWidth(), maxWidth);
            });
            if(maxWidth == 0) {
                maxWidth = ONE_COL_WIDTH;
            } else if(maxWidth <= ONE_COL_WIDTH) {
                // if the cell has a list or is over half the size of a normal cell, enlarge to normal cell width
                if ($(this).find('ul, ol').length > 0 || maxWidth > ONE_COL_WIDTH/2) maxWidth = ONE_COL_WIDTH;
            } else {
                // cells > than a normal cell width expand to 2 cell widths
                maxWidth = TWO_COL_WIDTH;
            }
            $(this).width(maxWidth);
        });
        $('.sim-diff td[colspan=2].media').find('div.fig').removeClass('fig').addClass('fig-wide');
        
        
        // add "show all" for adjacent similarity rows
//        $('.sim-diff tr:not(.type-of) td[rowspan=2]').each(function() {
//            var td = $(this);
//            var simRow = $(this).parent().next('tr');
//            td.attr('rowspan', '1');
//            simRow.hide();
//            
//            var button = $(td).find('.show-button');
//            if ($(button).length == 0) {
//                button = $('<br /><span class="show-button" rel="show similarities">show similarities</span>').appendTo(td);
//            } else {
//				$(button).attr('rel', $(button).text());
//            }
//            $(button).toggle(function(e) {
//            	td.attr('rowspan', '2');
//            	td.addClass('rowspan');
//                simRow.show();
//                $(e.currentTarget).text("hide");
//                return false;
//            }, function(e) {
//                simRow.hide();
//            	td.removeClass('rowspan');
//            	td.attr('rowspan', '1');
//				$(e.currentTarget).text($(e.currentTarget).attr('rel'));
//                return false;
//            });	
//        });
        
        // HACK: make all one-sided comparisons "uninteresting"
        $('td + td.empty + td, td + td + td.empty, td+td:empty+td, td+td+td:empty').parent().addClass('uninteresting');
       
        
        // hide "uninteresting" rows and add row summarizing them
        var titles = [];
        var uninterestingRows = $('.sim-diff:not(.taxonomic) tr.uninteresting');
        $(uninterestingRows).each(function() {
            $(this).hide();
            titles.push($(this).children('td').first().contents().filter(function() {
                return this.nodeType == Node.TEXT_NODE;
            }).text());
        });
        $('<tr id="misc-summary"><td><span class="show-button">show</span></td><td colspan="2"><h3>' + titles.join(', ') + ' </h3></td></tr>').insertAfter($('.sim-diff:not(.taxonomic) .uninteresting').last());
        $('#misc-summary .show-button').click(function(e) {
                var showSpeed = Math.min($(uninterestingRows).length * 80, 200);
                $(uninterestingRows).fadeIn(showSpeed);
                $('#misc-summary').hide();
                return false;
        });
        
        // add header and tabs
	 	if ($('table.sim-diff').length > 1) {
            
//            // remove bogus sections still left in some answers :-/
//            $('div.answer').not('.diff, .sim').remove();
            
	        // add floating header iff we're running inside Inquire, as noted by "inquire" id on body tag
//            if ($('body.inquire').length > 0) {
//                var header = $('<div class="second-header sim-diff"></div>').insertAfter('.question');
//                $('.question').clone().appendTo($(header));
//                $('table.sim-diff:not(.taxonomic):first thead').clone().appendTo($(header));
//            }
            
	 		// add sim/diff tabs
	 		$('.question').addClass('has-tabs');
            $('.question').append('<ul class="tabs simdiff"><li class="diff tab">differences</li><li class="sim tab">similarities</li></ul>');
            
            if($('.answer.sim, .answer.diff').first().is('.answer.diff')) {
            	$('.tab.diff').addClass('active');
            	$('.answer.sim').hide();
            } else {
            	$('.tab.sim').addClass('active');
            	$('.answer.diff').hide();
            }
            
            $('.tab.sim').click(function() {
                $(this).addClass('active')
                $('.tab.diff').removeClass('active');
                $('.answer.sim').show();
                $('.answer.diff').hide();
            });
            $('.tab.diff').click(function() {
                $(this).addClass('active')
                $('.tab.sim').removeClass('active');
                $('.answer.diff').show();
                $('.answer.sim').hide();
            });
	 	}
    };
		
	self.showGraphButtonHandler = function(event) {
        if (event.type == 'touchstart') {
            $('#show-graph-button').addClass('active');
        } else {
            $('#show-graph-button').removeClass('active');
        }
	};
	
	self.plusButtonClickHandler = function(event) {
        if (event.type == 'touchend') {
            $('#plusButton').removeClass('active');
            $('#plusButton').hide();
            $('#summary').hide();
            $('#minusButton').css('display', 'inline');
            $('#detail').show();
        } else {
            $('#plusButton').addClass('active');
        }
	};
	
	self.minusButtonClickHandler = function(event) {
        if (event.type == 'touchend') {
            $('#minusButton').removeClass('active');
            $('#plusButton').css('display', 'inline');
            $('#summary').show();
            $('#minusButton').hide();
            $('#detail').hide();
        } else {
            $('#minusButton').addClass('active');
        }
	};	

	return self;
};

Halo.getAnswer = function(question, server, uuid) {
	
	//$('#content').prepend('<div id="spinner">answering&hellip;</div>');
	
	$.post('http://' + server + '/answers', 
		{ question: question, uuid: uuid }, 
		function(html) {
            $('#content').html(html);
			Halo.answers.init();
			Halo.prepareTooltipElements();
			Halo.prepareGlossary(false);
			Halo.answers.finishLoading();
			nsBridge.sendEvent('webviewreloaded', '', '', '');
		}
	).error(
		function(msg) { 
			$('#content').html('<div id="failure">' + msg + '</div>');
			nsBridge.sendEvent('webviewreloaded', '', '', '');
		}
	);
};


Halo.answers = new Halo.Answers();

$(document).ready(function() {
	Halo.answers.init();
});


