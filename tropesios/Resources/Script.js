$(document).ready(function() {
	$("hr").remove();
	$("div[onclick='toggleAllFolders();']").remove();

	$(".folderlabel").each(function(index, item) { 
		$(this).replaceWith("<h3 id='topic" + index + "'>" + $(this).text() + "</h3>");
	});

	$(".spoiler").click(function() {
		$(this).addClass("spoiler-visible");
	});

	$("a").each(function() {
		var href = $(this).attr("href");
		
		if (href.indexOf("http://tvtropes.org/pmwiki/pmwiki.php/") == 0) {
			href = href.replace("http://tvtropes.org/pmwiki/pmwiki.php/", "tvtropeswiki:");
			$(this).attr("href", href);
		}
	});
});

function showSpoilers(show) {
	$(".spoiler").toggleClass("spoiler-visible", show);
}

function fontSize(size) {
	$("body").css("font-size", (size * 100) + "%");
}

function fontSerif(serif) {
	$("body").toggleClass("font-serif", serif);
}

function scrollToTopic(topicId) {
	window.location.hash = topicId == -1 ? "" : "#topic" + topicId;
};