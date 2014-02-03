$(document).ready(function() {
	$("hr").remove();
	$("div[onclick='toggleAllFolders();']").remove();

	$(".folderlabel").each(function(index, item) { 
		$(this).replaceWith("<h3 id='topic" + index + "'>" + $(this).text() + "</h3>");
	});

	$(".spoiler").click(function() {
		$(this).addClass("spoiler-visible");
	});

	$(".twikilink").each(function() {
		var ref = $(this).attr("href").replace("http://tvtropes.org/pmwiki/pmwiki.php/", "tvtropeswiki:");
		$(this).attr("href", ref);
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