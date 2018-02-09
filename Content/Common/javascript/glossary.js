$(document).ready(function() {
	Halo.prepareGlossary(true);
});

Halo.prepareGlossary = function(firstLoad) {
	Halo.prepareGlossaryButtons();
	Halo.prepareKindsOfToggles(firstLoad);
	Halo.prepareInheritanceToggles();
	Halo.formatGlossaryPages();
};

Halo.prepareGlossaryButtons = function() {
	$('#show-graph-button').prependTo($('#glossary-page h2'));
	
	$('#show-cmap').bind('touchstart touchend', function(event) {
		if (event.type == 'touchend') {
			$('#show-cmap').removeClass('active');
		} else {
			$('#show-cmap').addClass('active');
		}
	});
	$('#hide-cmap').live('touchstart touchend', function(event) {
		if (event.type == 'touchend') {
			$('#hide-cmap').removeClass('active');
		} else {
			$('#hide-cmap').addClass('active');
		}
	});
};

Halo.prepareKindsOfToggles = function(firstLoad) {
	
    $('#expList2 > li').each(function(index) {
        var header = $(this);
        var list = $(this).children('ul');
//        if (list.children('li').length < 2) return true; 
        list.hide();

        var getSpeed = function(target){
            return Math.min($(target).find('li, p').length * 80, 300);
        };

        var label = list.children('li').length + " function";
        if (list.children('li').length > 1) label += "s";

        $("<span class='show-button'>" + label + "</span>").insertAfter(header.children('a'))
        .toggle(function(e) {
            var showSpeed = getSpeed(list);
            list.slideDown(showSpeed);
            $(e.currentTarget).parent().addClass('visible');
            $(e.currentTarget).attr('rel', $(e.currentTarget).text());
            $(e.currentTarget).text("hide");
            return false;
        }, function(e) {
            var hideSpeed = getSpeed(list);
            list.slideUp(hideSpeed);
            $(e.currentTarget).parent().removeClass('visible');
            $(e.currentTarget).text($(e.currentTarget).attr('rel'));
            return false;
        });
    });
	
    // set up show/hide buttons for "Types of X" list
    $('#related, #types-of, #kinds-of').each(function(index) { //, #function
                                             
        $(this).cleanWhitespace(true);
                                             
        var list = $(this);
        var CUTOFF = 10;
        if (list.children('ul').children('li').length > CUTOFF) {
            var lis = list.children('ul').children('li');
            if(firstLoad) list.children('ul').hide(); // hidden for aesthetics at load time

            if (list.is('#function')) {
                // also trims functions list, though it's a bit of a hack
                lis.last().after("<li style='list-style:none;'> <span class='showFewerKinds'>hide</span></li>");
                lis.eq(CUTOFF-6).after("<li class='showMoreKinds' style='list-style:none;'><span>show all " + lis.length + "</span></li>");
            } else {
                lis.last().append(" <span class='showFewerKinds'>hide</span>");
                lis.eq(CUTOFF-1).after("<li class='showMoreKinds'>&hellip; <span>show all " + lis.length + "</span></li>");
            }
            list.find(".showMoreKinds").click(function(e) {
                $(this).hide();
                $(this).nextAll("li").fadeIn('fast');
                return false;
            });
            list.find(".showFewerKinds").click(function(e) {
                var $showMore = $(this).parent().parent().children('.showMoreKinds');
                $showMore.nextAll("li").fadeOut('fast', function(){
                     $showMore.show();
                });
                return false;
            });

            if (firstLoad) {
                $(window).load(function() {
                    list.find(".showMoreKinds").nextAll("li").hide();
                    list.children('ul').show();
                });
            } else {
                list.find(".showMoreKinds").nextAll("li").hide();
            }
        }
    });

    // handle subevents (used to do this for functions too, but no more!)
    $('#subevents ul li ul, .roles ul, #expList').each(function(index) { //#function ul li ul,
        var list = $(this);
        var CUTOFF = 2;
        if (list.children('li').length > CUTOFF) {
            var lis = list.children('li');
            lis.last().after("<li style='list-style:none;'> <span class='showFewerKinds'>hide</span></li>");
            lis.eq(CUTOFF-1).after("<li style='list-style:none;' class='showMoreKinds'><span>show all " + lis.length + "</span></li>");
            list.find(".showMoreKinds").nextAll("li").hide();

            list.find(".showMoreKinds").click(function(e) {
                $(this).hide();
                $(this).nextAll("li").fadeIn('fast');
                    return false;
            });
            list.find(".showFewerKinds").click(function(e) {
                var $showMore = $(this).parent().parent().children('.showMoreKinds');
                $showMore.nextAll("li").fadeOut('fast', function(){
                    $showMore.show();
                });
                return false;
            });
        }
    });
};

Halo.prepareInheritanceToggles = function() {
	if($('.glossary-page').length > 0 || $('.answer-page').length > 0) {
		
		var getSpeed = function(target){
			return Math.min($(target).find('li, p').length * 80, 200);
		};
		
/* 		TOGGLE BUTTONS FOR LISTS (PARTS, ETC) */
		$(".toggle > ul").hide();
		$(" <span class='show-button'>show</span>").insertAfter(".toggle .list-title")
		.toggle(function(e) {
			var showSpeed = getSpeed($(e.currentTarget).next("ul"));
			$(e.currentTarget).next("ul").slideDown(showSpeed);
			$(e.currentTarget).parent().addClass('visible');
			$(e.currentTarget).attr('rel', $(e.currentTarget).text());
			$(e.currentTarget).text("hide");
			return false;
		}, function(e) {
			var hideSpeed = getSpeed($(e.currentTarget).next("ul"));
			$(e.currentTarget).next("ul").slideUp(hideSpeed);
			$(e.currentTarget).parent().removeClass('visible');
			$(e.currentTarget).text($(e.currentTarget).attr('rel'));
			return false;
		});
		
/* 		TOGGLE BUTTONS FOR INHERITANCE LISTS  */
        $('.inheritance-list').each(function() {
            $(this).children(".list-title").cleanWhitespace(false);
            if ($(this).find(".sub-list").length > 0) {
                $(this).addClass('has-sub-lists');
                $(this).find(".sub-list").hide();
                var lists = $(this).children(".list-title").siblings('ul').children('.sub-list');
                                    
                var count = $(this).find(".sub-list > ul > li, ul > li:not(.sub-list)").length;
                var label = "show all " + count;
                                    
                if($(this).children(".list-title").siblings('ul').children('li:not(.sub-list)').length == 0) {
                    $(this).addClass('all-hidden');
                    if( $(this).hasClass('properties') && count == 1) {
                        label = "show";
                    } else {
                        label = "show " + count;
                    }
                }
                $(" <span class='show-button'>"+label+"</span>").insertAfter($(this).children(".list-title")).toggle(function(e) {
                    var showSpeed = getSpeed($(lists).children("ul"));
                    $(lists).slideDown(showSpeed);
                    $(e.currentTarget).parent().addClass('visible');
                    $(e.currentTarget).attr('rel', $(e.currentTarget).text());
                    $(e.currentTarget).text("hide inherited");
                    return false;
                }, function(e) {
                    var hideSpeed = getSpeed($(lists).children("ul"));
                    $(lists).slideUp(hideSpeed);
                    $(e.currentTarget).parent().removeClass('visible');
                    $(e.currentTarget).text($(e.currentTarget).attr('rel'));
                    return false;
                });
            }
        });
		
/* 		TOGGLE BUTTONS FOR SUB-PART DROP-DOWNS */
		$(".subpart .details").hide();
		$("<span> </span><span class='show-button'>i</span>").insertBefore(".subpart > .details")
		.toggle(function(e) {
			var showSpeed = getSpeed($(e.currentTarget).next(".details"));
			$(e.currentTarget).next(".details").slideDown(showSpeed);
			$(e.currentTarget).addClass("expanded").text("\u2715");
			return false;
		}, function(e) {
			var hideSpeed = getSpeed($(e.currentTarget).next(".details"));
			$(e.currentTarget).next(".details").slideUp(hideSpeed);
			$(e.currentTarget).removeClass("expanded").text("i");
			return false;
		});
	}
};

Halo.formatGlossaryPages = function(firstLoad) {
	$('.glossary-page ol li').wrapInner('<span> </span>').addClass('ol-li');
	
	if($('.cmap').length > 0) {
		//TODO: remove this when c-maps style themselves better
		$('body').css("background-image", "none");
		return;
	}
	
	if($('#structure h4').next('ul').children('li').not('.toggle').length == 0) {
		// hide the "Parts specific to X" header if there are no specific parts
		$('#structure h4').remove();
	}
	
	if($('.glossary-page #toc li').length == 0) $('.glossary-page #toc').hide();
	
	if ($('#glossary-sidebar').length == 0) {
		// make the sidebar
		if($('#glossary-page').length > 0) {
			var sidebar = $('<div id="glossary-sidebar" />').appendTo($('#definition'));
		} else {
			var sidebar = $('<div id="glossary-sidebar" />').appendTo($('.answer:not(.relationship-answer, .graph-intro, .diff, .sim)'));
		}
		// add figures to sidebar
		var mediaDiv = $('<div id="media" />');
		$('#glossary-page #media .fig, .answer:not(.sim) #media .fig, .answer-page > #media .fig').each(function() {
			var href = $(this).children('a').attr('href');
			var src = $(this).children('a').children('img').attr('src');
			var title = $(this).children('a').children('img').attr('alt');
			$(mediaDiv).append('<a class="fig" href="'+href+'" style="background-image:url('+src+')"><span>'+title+'</span></a>');
		});
		if( $(mediaDiv).is(":empty") == false ) {
			$(sidebar).append(mediaDiv);
		}
		$(sidebar).append($('#suggested-questions').clone());
	}
};

Halo.loadSuggestedQuestionsForConcept = function(concept, server) {
	if ($('#suggested-questions').length == 0) {
		$(document).ready(function() {
			$('#glossary-sidebar, #glossary-page').append('<div id="suggested-questions" class="suggested-questions glossary-section empty"><h3>Related questions</h3><ul></ul></div>');
			$('#toc').append('<li id="sq-toc" class="empty"><a class="toc-link" href="#suggested-questions">Related questions</a></li>');
	
			$.post('http://' + server + '/get_questions_for_glossary', 
				{ concept: concept }, 
				function(xml) {
					var questions = $(xml).find("question");
					if ($(questions).length > 0) {
						$('#sq-toc').removeClass('empty');
						$('.suggested-questions').removeClass('empty');

						$(questions).each(function() {
							 $('<li>' + $(this).text() + '</li>').appendTo('.suggested-questions ul');
						});
						Halo.addShowHideButtonToSuggestedQuestions(false);
					} else {
						$('#sq-toc').slideUp('fast');
						$('.suggested-questions').fadeOut(function(){ $(this).hide(); }); // Safari sometimes fails w/out this callback
					}
				}
			).error(
				function() { 
					$('<li><em>Unable to load suggested questions</em></li>').appendTo('.suggested-questions ul');
					$('.suggested-questions').removeClass('empty');
				}
			);

		});
	}
};

Halo.addShowHideButtonToSuggestedQuestions = function(firstRun) {
	var TO_SHOW = 4;
	$('.suggested-questions').each(function(index, list) {
		if ($(list).find('li').length > TO_SHOW) {
			var lis = $(list).find('li');
			if (!firstRun) $(list).children('ul').hide(); // hidden for aesthetics at load time

			lis.eq(TO_SHOW-1).after("<li class='showMoreKinds sqToggle'><span>show all " + lis.length + "</span></li>");
			lis.last().after("<li class=sqToggle> <span class='showFewerKinds'>hide</span></li>");
			$(list).find(".showMoreKinds > span").click(function(e) {
				$(this).parent().hide();
				$(this).parent().nextAll("li").fadeIn('fast');
				return false;
			});
			$(list).find(".showFewerKinds").click(function(e) {
				var $showMore = $(this).parent().parent().children('.showMoreKinds');
				$showMore.nextAll("li").fadeOut('fast', function(){
					$showMore.show();
				});
				return false;
			});
			
			$(list).find(".showMoreKinds").nextAll("li").hide();
			if (!firstRun) {
				$(list).find(".showMoreKinds").show();
				$(list).children('ul').fadeIn();
			}
		}
	});
};

