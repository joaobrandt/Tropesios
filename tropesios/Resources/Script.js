$(document).ready(function() {
	$("hr").remove();

	$(".folderlabel").each(function() {
		$(this).replaceWith("<h3>" + $(this).text() + "</h3>");
	});

	$(".spoiler").click(function() {
		$(this).toggleClass("spoiler-visible");
	});
});

function showAllSpoilers() {
	$(".spoiler").addClass("spoiler-visible");
};

function hideAllSpoilers() {
	$(".spoiler").removeClass("spoiler-visible");
};