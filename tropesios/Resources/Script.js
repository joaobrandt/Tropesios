$(document).ready(function() {
	$("hr").remove();
	$("div[onclick='toggleAllFolders();']").remove();

	$(".folderlabel").each(function() {
		$(this).replaceWith("<h3>" + $(this).text() + "</h3>");
	});

	$(".spoiler").click(function() {
		$(this).toggleClass("spoiler-visible");
	});

	$(".twikilink").each(function() {
		var ref = $(this).attr("href").replace("http://tvtropes.org/pmwiki/pmwiki.php/", "tvtropeswiki:");
		$(this).attr("href", ref);
	});
});

function showAllSpoilers() {
	$(".spoiler").addClass("spoiler-visible");
};

function hideAllSpoilers() {
	$(".spoiler").removeClass("spoiler-visible");
};